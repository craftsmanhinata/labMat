%RRIÇ∆PIÇÃî‰ärÇÇ∑ÇÈ
%éËèá;ECGÇ¬ÇØÇÈ,Å@ÇµÇŒÇÁÇ≠ë“Ç¬, PPGÇ¬ÇØÇÈ, PPGè¡Ç∑, ECGè¡Ç∑

close all;
clear();

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

procTime = 180;
procPoint = procTime / Ts;
dECG = dECG(1:procPoint);

dECGTime = (0:length(dECG)-1) * Ts;

freqRange = [0.3 3.0];

allECGFigure = figure();
plot(dECGTime,dECG);

title('ECG');


FFTLength = 512;
Overlap = 256;
[spectrum,freq,spectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 
spectrum = abs(spectrum/FFTLength);
spectrum(2:end-1,:) = 2 * spectrum(2:end-1,:);

[estimateHeartRate]= getHRFromSpectrum(spectrum,freq,freqRange,69);
estimateHeartRate = estimateHeartRate * 60;

figure();
plot(spectrumTime,estimateHeartRate);
slidingSpectrumTime = spectrumTimeSlidingEndTime(spectrumTime);
%realHR = calcRealHR(dECGTime,dECG,spectrumTime);
realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime);
hold on;

% plot(spectrumTime,realHR);
plot(slidingSpectrumTime,realHR);
legend('HR estimated from STFT','HR calculated from peaks');
HRError = sqrt(immse(estimateHeartRate,realHR));
disp(strcat('STFTÇ∆peakÇ©ÇÁÇÃHRÇÃïΩãœìÒèÊåÎç∑:',num2str(HRError)));


