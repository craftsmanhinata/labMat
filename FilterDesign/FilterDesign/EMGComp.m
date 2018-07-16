close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;
fc = 1; %unit:[Hz]


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

gReso = 4;
accCoeff = 9.80665;

PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
%PPG = detrend(PPG);
PPGTime = (0:1:length(PPG)-1)'*Ts;


EMGFolder = 'ECG\';
fileNameEMG = '0001~aa~0628.csv';
EMGData = csvread(strcat(EMGFolder,fileNameEMG));
EMG = EMGData(:,2);
EMGFs = 1000;
dEMG = decimate(EMG,EMGFs / (Fs));


D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
%D = fdesign.lowpass('Fp,Fst,Ap,Ast',NFhc,NFhc*highFreqMargin,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
fvtool(Hd,'Fs',Fs);

EMGTime = (0:1:length(dEMG)-1)'*Ts;
[EMGTime,dEMG] = trimSig(EMGTime,dEMG,1,181);
FilteredPPG = filtfilt(Hd.numerator,1,PPG);


figure();
subplot(2,1,1);
%plot(alignedTime,alignedEMG);
%plot(EMGTime,dFilteredEMG);
plot(EMGTime,dEMG);
hold on;

xlabel('Time[sec]');
ylabel('Voltage[mV]');
title('EMG Signal');
%xlim([alignedTime(1) alignedTime(end)]);
[EMGpks,EMGlocs] = findpeaks(dEMG,Fs,'MinPeakHeight',0.02);
 [EMGpks,EMGlocs] = evenDel(EMGpks,EMGlocs);
plot(EMGlocs,EMGpks,'b*');
[diffEMGPks,anomalyEMGPoint,anomalyEMGLocs] = diffPeakAnomalyDetect(EMGpks,EMGlocs,1.5);
plot(anomalyEMGLocs,anomalyEMGPoint,'ro');

subplot(2,1,2);
plot(PPGTime,FilteredPPG);
hold on;
%plot(diffTime,diffFilteredPPG);
title('PPG Signal');
xlabel('Time[sec]');
ylabel('PPG [a.u.]');

% xlim([alignedTime(1) alignedTime(end)]);
[PPGpks,PPGlocs] = findpeaks(1*FilteredPPG,PPGTime,'MinPeakDistance',0.5);
%[diffePPGpks,diffePPGlocs] = findpeaks(diffFilteredPPG,diffTime,'MinPeakDistance',0.4);
plot(PPGlocs,1*PPGpks,'b*');
%plot(diffePPGlocs,diffePPGpks,'r*');
[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGpks,PPGlocs,1.2);
%[diffDiffePPGPks,anomalyDiffePPGPoint,anomalyDiffePPGLocs] = diffPeakAnomalyDetect(diffePPGpks,diffePPGlocs,1.2);

%plot(anomalyPPGLocs,anomalyPPGPoint,'ro');
%plot(anomalyDiffePPGLocs,anomalyDiffePPGPoint,'bo');

% [alignedEMG,alignedPPG] = forceAligned(diffEMGPks,diffPPGPks);
% R = corrcoef(alignedEMG,alignedPPG)
% figure();
% plot(alignedEMG);
% hold on;
% plot(alignedPPG);
% legend('EMG','PPG');

freqPPG = diffPPGPks.^-1;
freqEMG = diffEMGPks.^-1;
[R,P,D]=movingCorrcoef(freqEMG,freqPPG);
figure();
plot(2:1:length(freqEMG)+1,freqEMG.^-1);
hold on;
alignedPPG = freqPPG(D:D+length(freqEMG)-1).^-1;
ylabel('RR Interval(sec)');
xlabel('pulse count');
yyaxis right;
plot(2:1:length(alignedPPG)+1,alignedPPG);
ylabel('Pulse Interval(sec)');
ylim([0.75 1.05]);
%R = corrcoef(alignedEMG-mean(alignedEMG),alignedPPG-mean(alignedPPG))