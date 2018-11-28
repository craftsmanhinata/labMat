%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

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
disp(strcat('STFTとpeakからのHRの平均二乗誤差:',num2str(HRError)));

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
disp(strcat('STFTとpeakからのPRの平均二乗誤差:',num2str(PRError)));


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
PRFError = sqrt(immse(estimateFilteredPulseRate,realHR));
disp(strcat('STFT(using FIR)とpeakからのPRの平均二乗誤差:',num2str(PRFError)));
ylabel('beats per minute(bpm)');
xlabel('time(sec.)');


xAcc = PPGData(:,2);
xAcc = trimSig(xAcc,Fs,procTime);
yAcc = PPGData(:,3);
yAcc = trimSig(yAcc,Fs,procTime);
zAcc = PPGData(:,4);
zAcc = trimSig(zAcc,Fs,procTime);

xGyro = PPGData(:,5);
xGyro = trimSig(xGyro,Fs,procTime);
yGyro = PPGData(:,6);
yGyro = trimSig(yGyro,Fs,procTime);
zGyro = PPGData(:,7);
zGyro = trimSig(zGyro,Fs,procTime);

%dは観測信号, xは外乱, eを脈波として使用する
LMSFilterLength = 64;
LMSStepSize = 0.01;
lmsXAcc = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGXAcc] = lmsXAcc(xAcc,PPG);
[adaptPPGXAccSpectrum,~,~] = spectrogram(adaptPPGXAcc,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGXAccSpectrum = convertOneSidedSpectrum(adaptPPGXAccSpectrum,FFTLength);
[estimateAdaptXAccPulseRate]= getHRFromSpectrum(adaptPPGXAccSpectrum,freq,freqRange,RHR);
estimateAdaptXAccPulseRate = estimateAdaptXAccPulseRate * 60;
adaptXAccError = sqrt(immse(estimateAdaptXAccPulseRate,realHR));
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateAdaptXAccPulseRate);
legend('HR estimated from STFT','HR calculated from peaks','PR estimated from STFT(Raw data)','PR estimated from STFT using FIR filter',...
    'PR estimated from STFT using NLMS(xAcc Only)');
disp(strcat('STFT(using NLMS xAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptXAccError)));

lmsYAcc = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGYAcc] = lmsYAcc(yAcc,PPG);
[adaptPPGYAccSpectrum,~,~] = spectrogram(adaptPPGYAcc,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGYAccSpectrum = convertOneSidedSpectrum(adaptPPGYAccSpectrum,FFTLength);
[estimateAdaptYAccPulseRate]= getHRFromSpectrum(adaptPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptYAccPulseRate = estimateAdaptYAccPulseRate * 60;
adaptYAccError = sqrt(immse(estimateAdaptYAccPulseRate,realHR));
disp(strcat('STFT(using NLMS yAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptYAccError)));

lmsZAcc = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGZAcc] = lmsZAcc(zAcc,PPG);
[adaptPPGZAccSpectrum,~,~] = spectrogram(adaptPPGZAcc,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGZAccSpectrum = convertOneSidedSpectrum(adaptPPGZAccSpectrum,FFTLength);
[estimateAdaptZAccPulseRate]= getHRFromSpectrum(adaptPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptZAccPulseRate = estimateAdaptZAccPulseRate * 60;
adaptZAccError = sqrt(immse(estimateAdaptZAccPulseRate,realHR));
disp(strcat('STFT(using NLMS zAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptZAccError)));

lmsXGyro = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGXGyro] = lmsXGyro(xGyro,PPG);
[adaptPPGXGyroSpectrum,~,~] = spectrogram(adaptPPGXGyro,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGXGyroSpectrum = convertOneSidedSpectrum(adaptPPGXGyroSpectrum,FFTLength);
[estimateAdaptXGyroPulseRate]= getHRFromSpectrum(adaptPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptXGyroPulseRate = estimateAdaptXGyroPulseRate * 60;
adaptXGyroError = sqrt(immse(estimateAdaptXGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS xGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptXGyroError)));

lmsYGyro = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGYGyro] = lmsYGyro(yGyro,PPG);
[adaptPPGYGyroSpectrum,~,~] = spectrogram(adaptPPGYGyro,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGYGyroSpectrum = convertOneSidedSpectrum(adaptPPGYGyroSpectrum,FFTLength);
[estimateAdaptYGyroPulseRate]= getHRFromSpectrum(adaptPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptYGyroPulseRate = estimateAdaptYGyroPulseRate * 60;
adaptYGyroError = sqrt(immse(estimateAdaptYGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS yGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptYGyroError)));

lmsZGyro = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptPPGZGyro] = lmsZGyro(zGyro,PPG);
[adaptPPGZGyroSpectrum,~,~] = spectrogram(adaptPPGZGyro,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptPPGZGyroSpectrum = convertOneSidedSpectrum(adaptPPGZGyroSpectrum,FFTLength);
[estimateAdaptZGyroPulseRate]= getHRFromSpectrum(adaptPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptZGyroPulseRate = estimateAdaptZGyroPulseRate * 60;
adaptZGyroError = sqrt(immse(estimateAdaptZGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS yGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptZGyroError)));

