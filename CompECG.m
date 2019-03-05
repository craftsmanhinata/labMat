%RRIÇ∆PIÇÃî‰ärÇÇ∑ÇÈ
%éËèá;ECGÇ¬ÇØÇÈ,Å@ÇµÇŒÇÁÇ≠ë“Ç¬, PPGÇ¬ÇØÇÈ, PPGè¡Ç∑, ECGè¡Ç∑
close all;
clear();
clc();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '2018111702_stay.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);


ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));


dECGTime = (0:1:length(dECG)-1)'*Ts;

figure();
subplot(2,1,1);
plot(dECGTime,dECG);
hold on;

set(gca,'FontSize',40);

[dECGPks,dECGPksTime] = findpeaks(dECG,dECGTime,'MinPeakHeight',20,'MinPeakDistance',0.3);
plot(dECGPksTime,dECGPks,'ko');



[dRRI,anomalydECGPoint,anomalydECGLocs] = diffPeakAnomalyDetect(dECGPks,dECGPksTime,1.5);
plot(anomalydECGLocs,anomalydECGPoint,'ro');

procTime = 180;
procPoint = ( procTime / Ts );
offset = 120;

PPGFolder = 'PPG\';
fileNamePPG = '20181117_204639_DataStay2_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);


fhc = 1.4; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.2;
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
% 
D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
FilteredPPG = filtfilt(Hd.numerator,1,PPG);
FilteredPPG = FilteredPPG(end-procPoint-offset:end-offset);
PPG = PPG(end-procPoint-offset:end-offset);
PPGTime = (0:1:length(FilteredPPG)-1)'*Ts;

if PPGInvOn
    FilteredPPG = FilteredPPG * -1;
end
% PPGSig = filter(Hd,PPGSig);

subplot(2,1,2);
plot(PPGTime,FilteredPPG);

[PPGPks,PPGPksTime] = findpeaks(FilteredPPG,PPGTime,'MinPeakDistance',min(dRRI)*0.9);
hold on;
set(gca,'FontSize',40);
plot(PPGPksTime,PPGPks,'ko');
[PI,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGPks,PPGPksTime,1.5);
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');

disp(strcat('ïbç∑:',num2str(abs(length(dECG)-length(PPG))*Ts)));




[R,P,D]=movingCorrcoef(PI,dRRI);
disp(strcat('movingÇ…ÇÊÇÈëää÷åWêî:',num2str(R(1,2))));

figure();
plot(PI);
alignedRRI = dRRI(D:D+length(PI)-1);
hold on;
plot(alignedRRI);
legend('PI','RRI');

figure();
plot(PPGTime,PPG);
hold on;
plot(PPGTime,FilteredPPG);