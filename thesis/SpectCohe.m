%スペクトルコヒーレンスを求めるプログラムの例
close all;
clear();
clc();
Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'PPG\';
fileNamePPG = '20181117_204639_DataStay2_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);

xAcc = PPGData(:,2);
yAcc = PPGData(:,3);
zAcc = PPGData(:,4);

xGyro = PPGData(:,5);
yGyro = PPGData(:,6);
zGyro = PPGData(:,7);

[spectXAcc,freq] = FFTAuto(xAcc,Fs);
powerSpectXAcc = abs(spectXAcc);
powerSpectXAcc(2:end-1) = 2 * powerSpectXAcc(2:end-1);
figure;
plot(freq,powerSpectXAcc);



[spectXGyro,freq] = FFTAuto(xGyro,Fs);
powerSpectXGyro = abs(spectXGyro);
powerSpectXGyro(2:end-1) = 2 * powerSpectXGyro(2:end-1);
hold on;
plot(freq,powerSpectXGyro);

%スペクトルコヒーレンスを求めるためのパラメータ
lowFreq = 3;
inWindowNum = 50;

windowTime = 1 / lowFreq * inWindowNum;
windowPoint = ceil(windowTime / Ts);
windowPoint = 500;

[Cxy,F] = mscohere(xAcc,xGyro,hamming(windowPoint),...
    ceil(windowPoint*0.8),windowPoint,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence');
xlabel('Frequency (Hz)');
grid;
xlim([0 10])
