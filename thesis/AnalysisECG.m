close all;
clear();
clc;



Fs = 50;
Ts = 1 / Fs;

fileNameECG = '';
ECGData = csvread(fileNameECG);
ECG = ECGData(:,2);

ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));

FFTLength = 512;
Overlap = 256;
[ECGSpectrum,freq,ECGSpectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 


slidingSpectrumTime = spectrumTimeSlidingEndTime(ECGSpectrumTime);
realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime);
