close all;
clear();
clc;



Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '20181201longtime.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);

ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));
dECGTime = (0:length(dECG)-1) * Ts;

figure();
plot(dECGTime,dECG);

FFTLength = 512;
Overlap = 256;
peakHeight = 50;
peakDistance = 0.4;
plotIs = false;
[ECGSpectrum,freq,ECGSpectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 


slidingSpectrumTime = spectrumTimeSlidingEndTime(ECGSpectrumTime);
realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime,peakHeight,peakDistance,plotIs);
