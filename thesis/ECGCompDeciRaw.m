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

ECGTime =  (0:1:length(ECG)-1)'*ECGTs;
dECGTime = (0:1:length(dECG)-1)'*Ts;

origFig = figure();
plot(dECGTime,dECG);
hold on;
plot(ECGTime,ECG);

set(gca,'FontSize',40);

[dECGPks,dECGPksTime] = findpeaks(dECG,dECGTime,'MinPeakHeight',0.03,'MinPeakDistance',0.3);
plot(dECGPksTime,dECGPks,'ko');



[dRRI,anomalydECGPoint,anomalydECGLocs] = diffPeakAnomalyDetect(dECGPks,dECGPksTime,1.5);
plot(anomalydECGLocs,anomalydECGPoint,'ro');

[ECGPks,ECGPksTime] = findpeaks(ECG,ECGTime,'MinPeakHeight',0.1,'MinPeakDistance',0.3);
[RRI,anomalyECGPoint,anomalyECGLocs] = diffPeakAnomalyDetect(ECGPks,ECGPksTime,1.5);
plot(ECGPksTime,ECGPks,'ko');
plot(anomalyECGLocs,anomalyECGPoint,'ro');

figure();
plot(RRI);
hold on;
plot(dRRI);
legend('Fs=1000Hz','Fs=50Hz');
corrcoef(RRI,dRRI)
