%ECGのデータを解析するプログラム
close all;
clear();
clc;



Fs = 50;
Ts = 1 / Fs;
FontSize = 20;

ECGFolder = 'ECG\';
fileNameECG = '20181201longtime.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);

ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));
dECG = trimSig(dECG,Fs,60*60);
dECGTime = (0:length(dECG)-1) * Ts;

figure();
plot(dECGTime,dECG);

FFTLength = 512;
Overlap = 256;
peakHeight = 50;
peakDistance = 0.4;
plotIs = false;
[ECGSpectrum,freq,ECGSpectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 


slidingSpectrumTime = spectrumTimeSlidingEndTime(ECGSpectrumTime,Ts);
realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime,peakHeight,peakDistance,plotIs);
figure();
plot(slidingSpectrumTime,realHR);
xlim([0 3600]);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('HeartRate(beats / min.)','FontSize',FontSize);
set(gca,'FontSize',FontSize);

transitionHR = diff(realHR);

figure();
histogram(transitionHR);
pd = fitdist(transitionHR,'Normal');
ci = paramci(pd);
ciXMin = ci(1,1);
ciXMax = ci(2,1);
xMin = min(transitionHR)*1.5;
xMax = max(transitionHR)*1.5;
xVal = xMin:0.1:xMax;
cdf = cdf(pd,xVal);
xlabel('Transition Heart Rate(beat / min.)','FontSize',FontSize);
ylabel('Count','FontSize',FontSize);
set(gca,'FontSize',FontSize);
figure();
plot(xVal,cdf);
figure();
y = pdf(pd,xVal);
plot(xVal,y);
axes = gca;
yAxes = axes.YLim;
yMax = max(yAxes);
% rectangle('Position',[ciXMin 0 ciXMax-ciXMin yMax]);
xlabel('Transition Heart Rate(beat / min.)','FontSize',FontSize);
ylabel('Probability','FontSize',FontSize);
set(gca,'FontSize',FontSize);
