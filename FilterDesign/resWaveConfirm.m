close all;
clear();
clc();
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\Data\resWaveProto.mat');

Fs = 50;
Ts = 1 / Fs;
fc = 1; %unit:[Hz]
PPG = timeArray2;
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

plot(PPGTime,FilteredPPG);
hold on;
[PPGpks,PPGlocs] = findpeaks(1*FilteredPPG,PPGTime,'MinPeakDistance',0.5);
plot(PPGlocs,1*PPGpks,'b*');


[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGpks,PPGlocs,1.2);
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');

title('PPG Signal','FontSize',22);
xlabel('Time[sec.]','FontSize',22);
ylabel('PPG [a.u.]','FontSize',22);
%xlim([0 180]);
set(gca,'FontSize',20);