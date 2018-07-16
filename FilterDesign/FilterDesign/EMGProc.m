close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;
fhc = 1; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.1; %unit:[Hz]
NFlc = flc/(Fs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 3;
lowFreqMargin = 5;
Ap = 1.0;


EMGFolder = 'ECG\';
fileNameEMG = '0001~aa~tri2.csv';
EMGData = csvread(strcat(EMGFolder,fileNameEMG));
EMG = EMGData(:,2);
EMGFs = 1000;
dEMG = decimate(EMG,EMGFs / (Fs));

dEMGTime = (0:1:length(dEMG)-1)'*Ts;

D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'cheby2');
fvtool(Hd);

dFilteredEMG = filter(Hd,dEMG);

% [acor,lag] = xcorr(dEMGFilt,dPPGSigFilt);
% [~,timeIndex] = max(abs(acor));
% lagDiff = lag(timeIndex);

lagDiff = 1;

figure();
plot(dEMGTime(lagDiff:end),dFilteredEMG(lagDiff:end));
[EMGpks,EMGlocs] = findpeaks(dFilteredEMG(lagDiff:end),dEMGTime(lagDiff:end),'MinPeakWidth',0.2);
hold on;
plot(EMGlocs,EMGpks,'b*');
xlabel('Time[sec]');
ylabel('Voltage[mV]');
title('EMG Signal');
diffEMGPksTime = diff(EMGlocs);

