close all;
clear();
clc();
accCoeff = 9.80665;
fileName = '20180528_145049_Test.csv';
folderName = '.\FilterData\';
saveName = 'filter.csv';
% fileName = '20180524_174921_Test.csv';
%'20180524_154753_Test.csv'
%fileName = '20180518_204711_Test.csv';
%fileName = '20180518_203203_Test.csv';
%fileName = '20180518_202004_Test.csv';
%fileName = '20180518_175500_Test.csv';
%fileName = '20180518_173037_Test.csv';
%fileName = '20180518_155405_Test.csv';
%fileName = '20180515_173138_Test.csv';
%fileName = '20180515_183219_Test.csv';
data = csvread(fileName);
ppgSig = data(:,1);
xAcc = data(:,2)*accCoeff/1000;
yAcc = data(:,3)*accCoeff/1000;
zAcc = data(:,4)*accCoeff/1000;

xAccOffset =  20*accCoeff/1000;
yAccOffset = -40*accCoeff/1000;
zAccOffset = 150*accCoeff/1000;

xAcc = xAcc - xAccOffset;
yAcc = yAcc - yAccOffset;
zAcc = zAcc - zAccOffset;

Fs = 200;
Ts = 1 / Fs;
time = (0:1:length(data)-1)';
time = Ts * time;
gReso = 4;
dmaBuf = 128;
% figure();
% plot(time,ppgSig)

bufA = ppgSig(1:dmaBuf);
bufB = ppgSig(dmaBuf+1:dmaBuf*2);



adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = 1;
minResVoldb = minResVoldb + margin;

scale = 4;
FilterTap = scale * 2 - 1;
D = fdesign.lowpass('N,Fc,Ap,Ast',FilterTap,1/scale,1,-1*minResVoldb);
%designmethods(D)
Hd = design(D,'equiripple');
Hd.Arithmetic = 'fixed';
Hd.CoeffWordLength = 16;
fvtool(Hd);
output = filter(Hd,ppgSig);

filterGroupDelay = grpdelay(Hd,100,Fs);
filterGroupDelay = mean(filterGroupDelay);
filterDelayTime = Ts * filterGroupDelay;
% figure();
% plot(time,output);
% title("fdesign method");

% b = fir1(40-1,1/scale,'low');
% fvtool(b);
% output2 = filter(b,1,ppgSig);
% figure();
% plot(time,output2);
% title("fir1 method");


dPPGSig = downSampling(output,scale,filterGroupDelay);

dTime =(0:1:length(dPPGSig)-1)'*Ts*scale;
figure();

% 
filtFc = 1;
filtFs = Fs / scale;
[b,a] = butter(6-1,filtFc/(filtFs/2));

dPPGSig = filter(b,a,dPPGSig);
plot(dTime,dPPGSig);
[pks,locs] = findpeaks(dPPGSig,dTime);
hold on;
% plot(locs,pks,'b*');
% title('Filterd PPG');
% xlabel('Time[sec]');
% ylabel('PPG [a.u.]');
interval = diff(locs);
RRFreq = interval.^-1;
% fvtool(b,a);


%要求:線形位相でそこそこ性能の良いFIRローパス

for index = 1:length(locs)
    if index == length(locs)
        locs(index) = [];
        break;
    end
    locs(index) = locs(index) + locs(index+1);
end
locs = locs/2;

% figure();
% plot(locs,RRFreq);
% xlabel('Time[sec]');
% ylabel('Freq.[Hz]');
% 

fractFilt = float2Fract(Hd.Numerator);
filtHexStr = fract2HexStr(fractFilt);

figure();
plot(time(1:dmaBuf),bufA);
hold on;
dOutSim = filter(Hd,bufA);
OutSim = dOutSim;
dOutSim = downSampling(dOutSim,scale,filterGroupDelay);

InSim = float2Fract(bufA);
InSimStr = fract2HexStr(InSim);


dOutSim = float2Fract(dOutSim);
dOutSimStr = fract2HexStr(dOutSim);


OutSim = float2Fract(OutSim);
OutSimStr = fract2HexStr(OutSim);

fileName2 = 'OutSim.csv';
tableData = readtable(fileName2,'Delimiter',',','Format','%s%s%s');

hexSimDataStr = tableData(:,2);
hexSimDataStr = string(table2array(hexSimDataStr));
hexSimDataStr = hex2Mathex(hexSimDataStr);
hexSimData = str2Fract(hexSimDataStr);

plot(dTime(1:length(dOutSim)),dOutSim);
hold on;
plot(dTime(1:length(hexSimData)),hexSimData);
legend('Orig','Matlab Filterd','dsPIC Filterd');

%memo:delay 2.5ms delay