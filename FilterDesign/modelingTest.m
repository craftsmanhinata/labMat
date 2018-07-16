close all;
clear();
clc();

Fs = 50;
Ts = 1/Fs;

PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

fhc = 3; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.7;
NFlc = flc/(Fs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 1.1;
lowFreqMargin = 1.16;
Ap = 1.0;

D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
FilteredPPG = filtfilt(Hd.numerator,1,PPG);



trainingInput = [FilteredPPG(1:ceil(end/3)-1) PPGTime(1:ceil(end/3)-1)];
trainingOutput = FilteredPPG(2:ceil(end/3));

rng default;


net = fitnet(1000);
net = train(net,trainingInput',trainingOutput');


pValue = zeros(length(FilteredPPG),2);
pValue(1) = FilteredPPG(1);
pValue(:,2) = PPGTime;
for index = 1:length(FilteredPPG)-1
    pValue(index+1) = net([pValue(index,1) mod(pValue(index,2),trainingInput(end,2))]');
end

figure();
plot(pValue(:,2),pValue(:,1));
hold
