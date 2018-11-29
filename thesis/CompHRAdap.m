%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

close all;
clear();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;

ECGFolder = 'ECG\';
fileNameECG = '2018112405move02.csv';
fileNamePPG = '20181124_200643_Move02.csv';
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
[adaptLMSPPGXAccSpectrum,adaptLMSPPGXAcc]= GetSpectrumUsingLMSFilt(xAcc,PPG,FFTLength,Overlap,Fs);
[estimateLMSAdaptXAccPulseRate]= getHRFromSpectrum(adaptLMSPPGXAccSpectrum,freq,freqRange,RHR);
estimateLMSAdaptXAccPulseRate = estimateLMSAdaptXAccPulseRate * 60;
adaptLMSXAccError = sqrt(immse(estimateLMSAdaptXAccPulseRate,realHR));
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateLMSAdaptXAccPulseRate);
legend('HR estimated from STFT','HR calculated from peaks','PR estimated from STFT(Raw data)','PR estimated from STFT using FIR filter',...
    'PR estimated from STFT using NLMS(xAcc Only)');
disp(strcat('STFT(using NLMS xAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSXAccError)));

[adaptLMSPPGYAccSpectrum,adaptLMSPPGYAcc]= GetSpectrumUsingLMSFilt(yAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSYAccPulseRate]= getHRFromSpectrum(adaptLMSPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYAccPulseRate = estimateAdaptLMSYAccPulseRate * 60;
adaptLMSYAccError = sqrt(immse(estimateAdaptLMSYAccPulseRate,realHR));
disp(strcat('STFT(using NLMS yAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSYAccError)));

[adaptLMSPPGZAccSpectrum,adaptLMSPPGZAcc]= GetSpectrumUsingLMSFilt(zAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSZAccPulseRate]= getHRFromSpectrum(adaptLMSPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZAccPulseRate = estimateAdaptLMSZAccPulseRate * 60;
adaptLMSZAccError = sqrt(immse(estimateAdaptLMSZAccPulseRate,realHR));
disp(strcat('STFT(using NLMS zAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSZAccError)));

[adaptLMSPPGXGyroSpectrum,adaptLMSPPGXGyro]= GetSpectrumUsingLMSFilt(xGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSXGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSXGyroPulseRate = estimateAdaptLMSXGyroPulseRate * 60;
adaptLMSXGyroError = sqrt(immse(estimateAdaptLMSXGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS xGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSXGyroError)));

[adaptLMSPPGYGyroSpectrum,adaptLMSPPGYGyro]= GetSpectrumUsingLMSFilt(yGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSYGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYGyroPulseRate = estimateAdaptLMSYGyroPulseRate * 60;
adaptLMSYGyroError = sqrt(immse(estimateAdaptLMSYGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS yGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSYGyroError)));

[adaptLMSPPGZGyroSpectrum,adaptLMSPPGZGyro]= GetSpectrumUsingLMSFilt(zGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSZGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZGyroPulseRate = estimateAdaptLMSZGyroPulseRate * 60;
adaptLMSZGyroError = sqrt(immse(estimateAdaptLMSZGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS zGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSZGyroError)));

[adaptRLSPPGXAccSpectrum,adaptRLSPPGXAcc]= GetSpectrumUsingRLSFilt(xAcc,PPG,FFTLength,Overlap,Fs);
[estimateRLSAdaptXAccPulseRate]= getHRFromSpectrum(adaptRLSPPGXAccSpectrum,freq,freqRange,RHR);
estimateRLSAdaptXAccPulseRate = estimateRLSAdaptXAccPulseRate * 60;
adaptRLSXAccError = sqrt(immse(estimateRLSAdaptXAccPulseRate,realHR));
disp(strcat('STFT(using RLS xAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSXAccError)));

[adaptRLSPPGYAccSpectrum,adaptRLSPPGYAcc]= GetSpectrumUsingRLSFilt(yAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSYAccPulseRate]= getHRFromSpectrum(adaptRLSPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYAccPulseRate = estimateAdaptRLSYAccPulseRate * 60;
adaptRLSYAccError = sqrt(immse(estimateAdaptRLSYAccPulseRate,realHR));
disp(strcat('STFT(using RLS yAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSYAccError)));

[adaptRLSPPGZAccSpectrum,adaptRLSPPGZAcc]= GetSpectrumUsingRLSFilt(zAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSZAccPulseRate]= getHRFromSpectrum(adaptRLSPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZAccPulseRate = estimateAdaptRLSZAccPulseRate * 60;
adaptRLSZAccError = sqrt(immse(estimateAdaptRLSZAccPulseRate,realHR));
disp(strcat('STFT(using RLS zAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSZAccError)));

[adaptRLSPPGXGyroSpectrum,adaptRLSPPGXGyro]= GetSpectrumUsingRLSFilt(xGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSXGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSXGyroPulseRate = estimateAdaptRLSXGyroPulseRate * 60;
adaptRLSXGyroError = sqrt(immse(estimateAdaptRLSXGyroPulseRate,realHR));
disp(strcat('STFT(using RLS xGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSXGyroError)));

[adaptRLSPPGYGyroSpectrum,adaptRLSPPGYGyro]= GetSpectrumUsingRLSFilt(yGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSYGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYGyroPulseRate = estimateAdaptRLSYGyroPulseRate * 60;
adaptRLSYGyroError = sqrt(immse(estimateAdaptRLSYGyroPulseRate,realHR));
disp(strcat('STFT(using RLS yGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSYGyroError)));

[adaptFFTPPGXAccSpectrum,adaptFFTPPGXAcc]= GetSpectrumUsingFFTFilt(xAcc,PPG,FFTLength,Overlap,Fs);
[estimateFFTAdaptXAccPulseRate]= getHRFromSpectrum(adaptFFTPPGXAccSpectrum,freq,freqRange,RHR);
estimateFFTAdaptXAccPulseRate = estimateFFTAdaptXAccPulseRate * 60;
adaptFFTXAccError = sqrt(immse(estimateFFTAdaptXAccPulseRate,realHR));
disp(strcat('STFT(using FFT xAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTXAccError)));

[adaptFFTPPGYAccSpectrum,adaptFFTPPGYAcc]= GetSpectrumUsingFFTFilt(yAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTYAccPulseRate]= getHRFromSpectrum(adaptFFTPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYAccPulseRate = estimateAdaptFFTYAccPulseRate * 60;
adaptFFTYAccError = sqrt(immse(estimateAdaptFFTYAccPulseRate,realHR));
disp(strcat('STFT(using FFT yAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTYAccError)));

[adaptFFTPPGZAccSpectrum,adaptFFTPPGZAcc]= GetSpectrumUsingFFTFilt(zAcc,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTZAccPulseRate]= getHRFromSpectrum(adaptFFTPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZAccPulseRate = estimateAdaptFFTZAccPulseRate * 60;
adaptFFTZAccError = sqrt(immse(estimateAdaptFFTZAccPulseRate,realHR));
disp(strcat('STFT(using FFT zAcc Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTZAccError)));

[adaptFFTPPGXGyroSpectrum,adaptFFTPPGXGyro]= GetSpectrumUsingFFTFilt(xGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTXGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTXGyroPulseRate = estimateAdaptFFTXGyroPulseRate * 60;
adaptFFTXGyroError = sqrt(immse(estimateAdaptFFTXGyroPulseRate,realHR));
disp(strcat('STFT(using FFT xGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTXGyroError)));

[adaptFFTPPGYGyroSpectrum,adaptFFTPPGYGyro]= GetSpectrumUsingFFTFilt(yGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTYGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYGyroPulseRate = estimateAdaptFFTYGyroPulseRate * 60;
adaptFFTYGyroError = sqrt(immse(estimateAdaptFFTYGyroPulseRate,realHR));
disp(strcat('STFT(using FFT yGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTYGyroError)));

[adaptFFTPPGZGyroSpectrum,adaptFFTPPGZGyro]= GetSpectrumUsingFFTFilt(zGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTZGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZGyroPulseRate = estimateAdaptFFTZGyroPulseRate * 60;
adaptFFTZGyroError = sqrt(immse(estimateAdaptFFTZGyroPulseRate,realHR));
disp(strcat('STFT(using FFT zGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTZGyroError)));

[adaptRLSPPGZGyroSpectrum,adaptRLSPPGZGyro]= GetSpectrumUsingRLSFilt(zGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSZGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZGyroPulseRate = estimateAdaptRLSZGyroPulseRate * 60;
adaptRLSZGyroError = sqrt(immse(estimateAdaptRLSZGyroPulseRate,realHR));
disp(strcat('STFT(using RLS zGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSZGyroError)));
