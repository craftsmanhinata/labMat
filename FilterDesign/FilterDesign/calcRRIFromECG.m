close all;
clear();
clc();

ECGFolder = 'ECG\';
fileNameECG = '0001~aa~0628.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);
ECGFs = 1000;
ECGTs = 1 / ECGFs;
ECGTime = (0:1:length(ECG)-1)'*ECGTs;
figure();
plot(ECGTime,ECG);

hold on;

xlabel('Time[sec]');
ylabel('Voltage[mV]');
title('ECG Signal');
[ECGPks,ECGLocs] = findpeaks(ECG,ECGFs,'MinPeakHeight',0.11,'MinPeakDistance',0.5);
plot(ECGLocs,ECGPks,'b*');
[diffECGPks,anomalyECGPoint,anomalyECGLocs] = diffPeakAnomalyDetect(ECGPks,ECGLocs,1.2);
plot(anomalyECGLocs,anomalyECGPoint,'ro');

freqECG = diffECGPks.^-1;
f_ECG = fit(ECGLocs(2:end),freqECG,'smoothingspline');

PPGFs = 50;
PPGTs = 1 / PPGFs;

PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPG = detrend(PPG);
PPGTime = (0:1:length(PPG)-1)'*PPGTs;

fhc = 3; %unit:[Hz]
NFhc = fhc/(PPGFs/2);
flc = 0.7;
NFlc = flc/(PPGFs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 1.1;
lowFreqMargin = 1.1;
Ap = 1.0;

D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
fvtool(Hd,'Fs',PPGFs);

FilteredPPG = filtfilt(Hd.numerator,1,PPG);
figure();
plot(PPGTime,FilteredPPG);
hold on;
[PPGPks,PPGLocs] = findpeaks(-1*FilteredPPG,PPGTime,'MinPeakDistance',0.5);
plot(PPGLocs,-1*PPGPks,'b*');
[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGPks,PPGLocs,1.2);
plot(anomalyPPGLocs,-1*anomalyPPGPoint,'ro');
freqPPG = diffPPGPks.^-1;

figure();
plot(freqPPG);
hold on;
plot(freqECG);

[alignedECG,alignedPPG] = forceAligned(freqECG,freqPPG);
figure();
plot(alignedECG);
hold on;
plot(alignedPPG);
