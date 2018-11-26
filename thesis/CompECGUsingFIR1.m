%RRIÇ∆PIÇÃî‰ärÇÇ∑ÇÈ
%éËèá;ECGÇ¬ÇØÇÈ,Å@ÇµÇŒÇÁÇ≠ë“Ç¬, PPGÇ¬ÇØÇÈ, PPGè¡Ç∑, ECGè¡Ç∑
close all;
clear();
clc();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '2018112404stay03.csv';
fileNamePPG = '20181124_200114_Stay03.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);


ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));


dECGTime = (0:1:length(dECG)-1)'*Ts;

origFig = figure();
subplot(2,1,1);
plot(dECGTime,dECG);
hold on;

set(gca,'FontSize',40);

[dECGPks,dECGPksTime] = findpeaks(dECG,dECGTime,'MinPeakHeight',0.03,'MinPeakDistance',0.3);
plot(dECGPksTime,dECGPks,'ko');



[dRRI,anomalydECGPoint,anomalydECGLocs] = diffPeakAnomalyDetect(dECGPks,dECGPksTime,1.5);
plot(anomalydECGLocs,anomalydECGPoint,'ro');

procTime = 180;
procPoint = ( procTime / Ts );
offset = 0;

PPGFolder = 'PPG\';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = detrend(PPGData(:,1));


% fhc = 1.4; %unit:[Hz]
fhc = 1.5;
NFhc = fhc/(Fs/2);
% flc = 1.1;
flc = 1.0;
NFlc = flc/(Fs/2);

b = fir1(3000,[NFlc NFhc]);
fvtool(b,'Fs',Fs);

FilteredPPG = filtfilt(b,1,PPG);
FilteredPPG = FilteredPPG(end-procPoint-offset:end-offset);
PPG = PPG(end-procPoint-offset:end-offset);
PPGTime = (0:1:length(FilteredPPG)-1)'*Ts;

if PPGInvOn
    FilteredPPG = FilteredPPG * -1;
end
% PPGSig = filter(Hd,PPGSig);
figure(origFig);
subplot(2,1,2);
plot(PPGTime,FilteredPPG);

[PPGPks,PPGPksTime] = findpeaks(FilteredPPG,PPGTime,'MinPeakDistance',min(dRRI)*0.9);
set(gca,'FontSize',40);
hold on;
plot(PPGPksTime,PPGPks,'ko');
[PI,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGPks,PPGPksTime,1.5);
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');

disp(strcat('ïbç∑:',num2str(abs(length(dECG)-length(PPG))*Ts)));




[R,P,D]=movingCorrcoef(PI,dRRI);
disp(strcat('movingÇ…ÇÊÇÈëää÷åWêî:',num2str(R(1,2))));

figure();
plot(PI);
[alignedRRI,outputECG] = getECGfromRRI(dECG,dRRI,PI,dECGPksTime,D,Fs);
hold on;
plot(alignedRRI);
legend('PI','RRI');

figure();
plot(PPGTime,PPG);
hold on;
plot(PPGTime,FilteredPPG);


figure();
plot(PPGTime,FilteredPPG);
yyaxis right;
plot((0:1:length(outputECG)-1)*Ts,outputECG);

