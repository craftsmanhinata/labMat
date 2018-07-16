close all;
clear();
clc();
accCoeff = 9.80665;
fileName = '20180528_145049_Test.csv';
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

Fs = 100;
Ts = 1 / Fs;
time = (0:1:length(data)-1)';
time = Ts * time;
gReso = 4;

scale = 20;
dPPGSig = decimate(ppgSig,scale,'fir');
dXAcc = decimate(xAcc,scale,'fir');
dYAcc = decimate(yAcc,scale,'fir');
dZAcc = decimate(zAcc,scale,'fir');
dTime =(0:1:length(dPPGSig)-1)'*Ts*scale;
detPPGSig = detrend(dPPGSig);
figure();
subplot(5,1,1);
plot(dTime,dPPGSig);
%findpeaks(dPPGSig,Fs/scale,'MinPeakDistance',1);
%[pks,locs] = findpeaks(dPPGSig,Fs/scale,'MinPeakDistance',1);
title('Downsampling PPG Signal');
xlabel('Time[sec]');
ylabel('PPG [a.u.]');
subplot(5,1,2);
plot(dTime,dXAcc);
title('X Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);
subplot(5,1,3);
plot(dTime,dYAcc);
title('Y Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);
subplot(5,1,4);
plot(dTime,dZAcc);
title('Z Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);


filtFc = 1;
filtFs = Fs / scale;
[b,a] = butter(6,filtFc/(filtFs/2));
% freqz(b,a)
dPPGSigFilt = filter(b,a,dPPGSig);
subplot(5,1,5);
plot(dTime,dPPGSigFilt);
title('Filtered PPG Signal');
xlabel('Time[sec]');
ylabel('PPG [a.u.]');


Length = 2^10;
dPPGSigSpect = fft(dPPGSigFilt,Length);
dPPGSigSpectP2 = abs(dPPGSigSpect/Length);
dPPGSigSpectP1 = dPPGSigSpectP2(1:Length/2+1);
dPPGSigSpectP1(2:end-1) = 2*dPPGSigSpectP1(2:end-1);
freq = Fs/scale * (0:(Length/2))/Length;
figure();
plot(freq,dPPGSigSpectP1);

ECGFolder = 'ECG\';
fileNameECG = '0001~aa~test3.csv';
data2 = csvread(strcat(ECGFolder,fileNameECG));
ECG = data2(:,2);
ECGFs = 1000;
dECG = decimate(ECG,ECGFs / (Fs / scale),'fir');
dECGFilt = filter(b,a,dECG);
dECGTime = (0:1:length(dECG)-1)'*Ts*scale;

[acor,lag] = xcorr(dECGFilt,dPPGSigFilt);
[~,timeIndex] = max(abs(acor));
lagDiff = lag(timeIndex);


figure();
plot(dECGTime(lagDiff:end),dECGFilt(lagDiff:end));
[ECGpks,ECGlocs] = findpeaks(dECGFilt(lagDiff:end),dECGTime(lagDiff:end));
hold on;
plot(ECGlocs,ECGpks,'b*');
% hold on;
% yyaxis left;
% plot(dTime,dPPGSigFilt);
% [pks,locs] = findpeaks(dPPGSigFilt,dTime);
% hold on;
% plot(locs,pks,'*');
xlabel('Time[sec]');

