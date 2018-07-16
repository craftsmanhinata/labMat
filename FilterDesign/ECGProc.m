close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '0001~aa~20180626.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);
ECGFs = 1000;
dECG = decimate(ECG,ECGFs / (Fs));

ECGTime = (0:1:length(dECG)-1)'*Ts;
figure();
plot(ECGTime,dECG);
hold on;
xlabel('Time[sec]');
ylabel('Voltage[mV]');
title('ECG Signal');
[ECGpks,ECGlocs] = findpeaks(dECG,Fs,'MinPeakDistance',0.56,'MinPeakHeight',0.05);
plot(ECGlocs,ECGpks,'b*');
% [wt,f,coi] = cwt(dECG,'morse',Fs,'TimeBandwidth',120,'VoicesPerOctave',48);
%cwt(dECG,'morse',Fs,'TimeBandwidth',120,'VoicesPerOctave',48);

%ECGlocsIndex = ceil(ECGlocs / Ts);
% wtCopy = zeros(length(wt(:,1)),length(wt));
% for index = 1:length(ECGlocsIndex)
%     wtCopy(:,ECGlocsIndex(index)) = wt(:,ECGlocsIndex(index));
% end
% 
% wave = icwt(wtCopy,'morse');
% hold on;
% plot(ECGTime,wave);
% [Wavepks,Wavelocs] = findpeaks(wave,Fs,'MinPeakDistance',0.56);
% hold on;
% plot(Wavelocs,Wavepks,'b*');
% cwt(wave,'morse',Fs,'TimeBandwidth',120,'VoicesPerOctave',48);

[diffECGPks,anomalyECGPoint,anomalyECGLocs] = diffPeakAnomalyDetect(ECGpks,ECGlocs,1.5);
figure();
plot(diffECGPks);