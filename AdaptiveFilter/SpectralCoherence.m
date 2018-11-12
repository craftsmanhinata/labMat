clear;
close all;
clc;

Fs = 50;
Ts = 1 / Fs;
dataPoint = 5000;
time = (0:1:(dataPoint-1))*Ts;
SinFreq1 = 5;
data = sin(2 * pi * SinFreq1 * time) + 0.8*randn(1,dataPoint);

figure;
plot(time,data);

[spect1,freq1] = FFTAuto(data,Fs);
powerSpect1 = abs(spect1);
powerSpect1(2:end-1) = 2 * powerSpect1(2:end-1);

figure;
plot(freq1,powerSpect1);


anotherData = sin(2 * pi * SinFreq1 * time);
SinFreq2 = 10;
anotherData = anotherData + sin(2 * pi * SinFreq2 * time);
anotherData = anotherData + 0.5*randn(1,dataPoint);
[spect2,freq2] = FFTAuto(anotherData,Fs);
powerSpect2 = abs(spect2);
powerSpect2(2:end-1) = 2 * powerSpect2(2:end-1);

figure;
plot(freq2,powerSpect2);

%スペクトルコヒーレンスを求めるためのパラメータ
lowFreq = 10;
inWindowNum = 100;

windowTime = 1 / lowFreq * inWindowNum;
windowPoint = windowTime / Ts;

[Cxy,F] = mscohere(data,anotherData,hamming(windowPoint),...
    ceil(windowPoint*0.8),windowPoint,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence');
xlabel('Frequency (Hz)');
grid;

[pks,locs] = findpeaks(Cxy,F,'NPeaks',5,'SortStr','descend');
hold on;
plot(locs,pks,'O');

multiDWT(data,anotherData,Fs,0.1);
