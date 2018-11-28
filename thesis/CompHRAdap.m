%RRIÇ∆PIÇÃî‰ärÇÇ∑ÇÈ
%éËèá;ECGÇ¬ÇØÇÈ,Å@ÇµÇŒÇÁÇ≠ë“Ç¬, PPGÇ¬ÇØÇÈ, PPGè¡Ç∑, ECGè¡Ç∑

close all;
clear();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;

ECGFolder = 'ECG\';
fileNameECG = '2018112403move01.csv';
fileNamePPG = '20181124_195525_Move01.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);

ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));

procTime = 180;
dECG = trimSig(dECG,Fs,procTime);

dECGTime = (0:length(dECG)-1) * Ts;

freqRange = [0.7 3.0];

allECGFigure = figure();
plot(dECGTime,dECG);

title('ECG');


FFTLength = 512;
Overlap = 256;
[ECGSpectrum,freq,ECGSpectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 
ECGSpectrum = convertOneSidedSpectrum(ECGSpectrum,FFTLength);

[estimateHeartRate]= getHRFromSpectrum(ECGSpectrum,freq,freqRange,RHR);
estimateHeartRate = estimateHeartRate * 60;

HRFig = figure();
plot(ECGSpectrumTime,estimateHeartRate);
slidingSpectrumTime = spectrumTimeSlidingEndTime(ECGSpectrumTime);
%realHR = calcRealHR(dECGTime,dECG,spectrumTime);
realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime);
hold on;

% plot(spectrumTime,realHR);
plot(slidingSpectrumTime,realHR);
HRError = sqrt(immse(estimateHeartRate,realHR));
disp(strcat('STFTÇ∆peakÇ©ÇÁÇÃHRÇÃïΩãœìÒèÊåÎç∑:',num2str(HRError)));

PPGFolder = 'PPG\';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPG = trimSig(PPG,Fs,procTime);
[PPGSpectrum,~,PPGSpectrumTime] = spectrogram(PPG,hann(FFTLength),Overlap,FFTLength,Fs); 
PPGSpectrum = convertOneSidedSpectrum(PPGSpectrum,FFTLength);
[estimatePulseRate]= getHRFromSpectrum(PPGSpectrum,freq,freqRange,RHR);
estimatePulseRate = estimatePulseRate * 60;
figure(HRFig);
plot(PPGSpectrumTime,estimatePulseRate);
PRError = sqrt(immse(estimatePulseRate,realHR));
disp(strcat('STFTÇ∆peakÇ©ÇÁÇÃPRÇÃïΩãœìÒèÊåÎç∑:',num2str(PRError)));


fhc = 1.4; %unit:[Hz]
% fhc = max(freqRange);
NFhc = fhc/(Fs/2);
flc = 1.1;
% flc = min(freqRange);
NFlc = flc/(Fs/2);
%orig 3000
b = fir1(2900,[NFlc NFhc]);
FilteredPPG = filtfilt(b,1,PPG);
[FilteredPPGSpectrum,~,FilteredPPGSpectrumTime] = spectrogram(FilteredPPG,hann(FFTLength),Overlap,FFTLength,Fs); 
FilteredPPGSpectrum = convertOneSidedSpectrum(FilteredPPGSpectrum,FFTLength);
[estimateFilteredPulseRate]= getHRFromSpectrum(FilteredPPGSpectrum,freq,freqRange,RHR);
estimateFilteredPulseRate = estimateFilteredPulseRate * 60;
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateFilteredPulseRate);
legend('HR estimated from STFT','HR calculated from peaks','PR estimated from STFT(Raw data)','PR estimated from STFT using FIR filter');
PRFError = sqrt(immse(estimateFilteredPulseRate,realHR));
disp(strcat('STFT(using FIR)Ç∆peakÇ©ÇÁÇÃPRÇÃïΩãœìÒèÊåÎç∑:',num2str(PRFError)));
ylabel('beats per minute(bpm)');
xlabel('time(sec.)');


