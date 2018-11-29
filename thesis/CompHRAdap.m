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
b = fir1(450,[NFlc NFhc]);
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

xAngleFromGyro = angleSpeedIntegral(xGyro,Fs);
yAngleFromGyro = angleSpeedIntegral(yGyro,Fs);
zAngleFromGyro = angleSpeedIntegral(zGyro,Fs);

[xAngleFromAcc,yAngleFromAcc,zAngleFromAcc] = calcAngleFromAcc(xAcc,yAcc,zAcc);

lowFreq = 3;
inWindowNum = 50;

windowTime = 1 / lowFreq * inWindowNum;
windowPoint = ceil(windowTime / Ts);

[Cxy,F] = mscohere(xAngleFromGyro,xAngleFromAcc,hann(windowPoint),...
    ceil(windowPoint*0.8),windowPoint,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence X acc, X gyro');
xlabel('Frequency (Hz)');
grid;
coheFreqRange = [0.7 3.0];
xlim(coheFreqRange);
xPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);

[Cxy,F] = mscohere(yAngleFromGyro,yAngleFromAcc,hann(windowPoint),...
    ceil(windowPoint*0.8),windowPoint,Fs);
yPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence Y acc, Y gyro');
xlabel('Frequency (Hz)');
grid;
xlim(coheFreqRange);

[Cxy,F] = mscohere(zAngleFromGyro,zAngleFromAcc,hann(windowPoint),...
    ceil(windowPoint*0.8),windowPoint,Fs);
zPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence Z acc, Z gyro');
xlabel('Frequency (Hz)');
grid;
xlim(coheFreqRange);

filterOrder = 2900;

highXPass = fir1(filterOrder,xPeakFreq/(Fs/2),'high');
lowXPass = fir1(filterOrder,xPeakFreq/(Fs/2),'low');

highYPass = fir1(filterOrder,yPeakFreq/(Fs/2),'high');
lowYPass = fir1(filterOrder,yPeakFreq/(Fs/2),'low');

highZPass = fir1(filterOrder,zPeakFreq/(Fs/2),'high');
lowZPass = fir1(filterOrder,zPeakFreq/(Fs/2),'low');

FilteredXAngleFromAcc  = filtfilt(lowXPass,1,xAngleFromAcc);
FilteredXAngleFromGyro = filtfilt(highXPass,1,xAngleFromGyro);
FilteredYAngleFromAcc  = filtfilt(lowYPass,1,yAngleFromAcc);
FilteredYAngleFromGyro = filtfilt(highYPass,1,yAngleFromGyro);
FilteredZAngleFromAcc  = filtfilt(lowZPass,1,zAngleFromAcc);
FilteredZAngleFromGyro = filtfilt(highZPass,1,zAngleFromGyro);

XAngle = FilteredXAngleFromAcc + FilteredXAngleFromGyro';
YAngle = FilteredYAngleFromAcc + FilteredYAngleFromGyro';
ZAngle = FilteredZAngleFromAcc + FilteredZAngleFromGyro';
figure();
plot(dECGTime,rad2deg(XAngle));
hold on;
plot(dECGTime,rad2deg(YAngle));
plot(dECGTime,rad2deg(ZAngle));
legend('XAngle','YAngle','ZAngle');


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

mixedNLMSAccSpectrum = zeros([size(adaptLMSPPGXAccSpectrum) 3]);
mixedNLMSAccSpectrum(:,:,1) = adaptLMSPPGXAccSpectrum;
mixedNLMSAccSpectrum(:,:,2) = adaptLMSPPGYAccSpectrum;
mixedNLMSAccSpectrum(:,:,3) = adaptLMSPPGZAccSpectrum;

[estimateAdaptNLMSTriAccPulseRate]= getHRFromMixedSpectrums(mixedNLMSAccSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriAccPulseRate = estimateAdaptNLMSTriAccPulseRate * 60;
estimateAdaptNLMSTriAccPulseError = sqrt(immse(estimateAdaptNLMSTriAccPulseRate,realHR));
disp(strcat('STFT(using NLMS Acc all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptNLMSTriAccPulseError)));


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

mixedNLMSGyroSpectrum = zeros([size(adaptLMSPPGXGyroSpectrum) 3]);
mixedNLMSGyroSpectrum(:,:,1) = adaptLMSPPGXGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,2) = adaptLMSPPGYGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,3) = adaptLMSPPGZGyroSpectrum;

[estimateAdaptNLMSTriGyroPulseRate]= getHRFromMixedSpectrums(mixedNLMSGyroSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriGyroPulseRate = estimateAdaptNLMSTriGyroPulseRate * 60;
estimateAdaptNLMSTriGyroPulseError = sqrt(immse(estimateAdaptNLMSTriGyroPulseRate,realHR));
disp(strcat('STFT(using NLMS Gyro all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptNLMSTriGyroPulseError)));


[adaptLMSPPGXAngleSpectrum,adaptLMSPPGXAngle]= GetSpectrumUsingLMSFilt(XAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSXAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSXAnglePulseRate = estimateAdaptLMSXAnglePulseRate * 60;
adaptLMSXAngleError = sqrt(immse(estimateAdaptLMSXAnglePulseRate,realHR));
disp(strcat('STFT(using NLMS XAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSXAngleError)));

[adaptLMSPPGYAngleSpectrum,adaptLMSPPGYAngle]= GetSpectrumUsingLMSFilt(YAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSYAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYAnglePulseRate = estimateAdaptLMSYAnglePulseRate * 60;
adaptLMSYAngleError = sqrt(immse(estimateAdaptLMSYAnglePulseRate,realHR));
disp(strcat('STFT(using NLMS YAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSYAngleError)));

[adaptLMSPPGZAngleSpectrum,adaptLMSPPGZAngle]= GetSpectrumUsingLMSFilt(ZAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptLMSZAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZAnglePulseRate = estimateAdaptLMSZAnglePulseRate * 60;
adaptLMSZAngleError = sqrt(immse(estimateAdaptLMSZAnglePulseRate,realHR));
disp(strcat('STFT(using NLMS ZAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptLMSZAngleError)));


mixedNLMSAngleSpectrum = zeros([size(adaptLMSPPGXAngleSpectrum) 3]);
mixedNLMSAngleSpectrum(:,:,1) = adaptLMSPPGXAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,2) = adaptLMSPPGYAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,3) = adaptLMSPPGZAngleSpectrum;

[estimateAdaptNLMSTriAnglePulseRate]= getHRFromMixedSpectrums(mixedNLMSAngleSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriAnglePulseRate = estimateAdaptNLMSTriAnglePulseRate * 60;
estimateAdaptNLMSTriAnglePulseError = sqrt(immse(estimateAdaptNLMSTriAnglePulseRate,realHR));
disp(strcat('STFT(using NLMS Angle all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptNLMSTriAnglePulseError)));




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


mixedRLSAccSpectrum = zeros([size(adaptRLSPPGXAccSpectrum) 3]);
mixedRLSAccSpectrum(:,:,1) = adaptRLSPPGXAccSpectrum;
mixedRLSAccSpectrum(:,:,2) = adaptRLSPPGYAccSpectrum;
mixedRLSAccSpectrum(:,:,3) = adaptRLSPPGZAccSpectrum;

[estimateAdaptRLSTriAccPulseRate]= getHRFromMixedSpectrums(mixedRLSAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriAccPulseRate = estimateAdaptRLSTriAccPulseRate * 60;
estimateAdaptRLSTriAccPulseError = sqrt(immse(estimateAdaptRLSTriAccPulseRate,realHR));
disp(strcat('STFT(using RLS Acc all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptRLSTriAccPulseError)));




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

[adaptRLSPPGZGyroSpectrum,adaptRLSPPGZGyro]= GetSpectrumUsingRLSFilt(zGyro,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSZGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZGyroPulseRate = estimateAdaptRLSZGyroPulseRate * 60;
adaptRLSZGyroError = sqrt(immse(estimateAdaptRLSZGyroPulseRate,realHR));
disp(strcat('STFT(using RLS zGyro Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSZGyroError)));


mixedRLSGyroSpectrum = zeros([size(adaptRLSPPGXGyroSpectrum) 3]);
mixedRLSGyroSpectrum(:,:,1) = adaptRLSPPGXGyroSpectrum;
mixedRLSGyroSpectrum(:,:,2) = adaptRLSPPGYGyroSpectrum;
mixedRLSGyroSpectrum(:,:,3) = adaptRLSPPGZGyroSpectrum;

[estimateAdaptRLSTriGyroPulseRate]= getHRFromMixedSpectrums(mixedRLSGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriGyroPulseRate = estimateAdaptRLSTriGyroPulseRate * 60;
estimateAdaptRLSTriGyroPulseError = sqrt(immse(estimateAdaptRLSTriGyroPulseRate,realHR));
disp(strcat('STFT(using RLS Gyro all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptRLSTriGyroPulseError)));



[adaptRLSPPGXAngleSpectrum,adaptRLSPPGXAngle]= GetSpectrumUsingRLSFilt(XAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSXAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSXAnglePulseRate = estimateAdaptRLSXAnglePulseRate * 60;
adaptRLSXAngleError = sqrt(immse(estimateAdaptRLSXAnglePulseRate,realHR));
disp(strcat('STFT(using RLS XAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSXAngleError)));

[adaptRLSPPGYAngleSpectrum,adaptRLSPPGYAngle]= GetSpectrumUsingRLSFilt(YAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSYAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYAnglePulseRate = estimateAdaptRLSYAnglePulseRate * 60;
adaptRLSYAngleError = sqrt(immse(estimateAdaptRLSYAnglePulseRate,realHR));
disp(strcat('STFT(using RLS YAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSYAngleError)));

[adaptRLSPPGZAngleSpectrum,adaptRLSPPGZAngle]= GetSpectrumUsingRLSFilt(ZAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptRLSZAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZAnglePulseRate = estimateAdaptRLSZAnglePulseRate * 60;
adaptRLSZAngleError = sqrt(immse(estimateAdaptRLSZAnglePulseRate,realHR));
disp(strcat('STFT(using RLS ZAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptRLSZAngleError)));


mixedRLSAngleSpectrum = zeros([size(adaptRLSPPGXAngleSpectrum) 3]);
mixedRLSAngleSpectrum(:,:,1) = adaptRLSPPGXAngleSpectrum;
mixedRLSAngleSpectrum(:,:,2) = adaptRLSPPGYAngleSpectrum;
mixedRLSAngleSpectrum(:,:,3) = adaptRLSPPGZAngleSpectrum;

[estimateAdaptRLSTriAnglePulseRate]= getHRFromMixedSpectrums(mixedRLSAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriAnglePulseRate = estimateAdaptRLSTriAnglePulseRate * 60;
estimateAdaptRLSTriAnglePulseError = sqrt(immse(estimateAdaptRLSTriAnglePulseRate,realHR));
disp(strcat('STFT(using RLS Angle all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptRLSTriAnglePulseError)));



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


mixedFFTAccSpectrum = zeros([size(adaptFFTPPGXAccSpectrum) 3]);
mixedFFTAccSpectrum(:,:,1) = adaptFFTPPGXAccSpectrum;
mixedFFTAccSpectrum(:,:,2) = adaptFFTPPGYAccSpectrum;
mixedFFTAccSpectrum(:,:,3) = adaptFFTPPGZAccSpectrum;

[estimateAdaptFFTTriAccPulseRate]= getHRFromMixedSpectrums(mixedFFTAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriAccPulseRate = estimateAdaptFFTTriAccPulseRate * 60;
estimateAdaptFFTTriAccPulseError = sqrt(immse(estimateAdaptFFTTriAccPulseRate,realHR));
disp(strcat('STFT(using FFT Acc all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptFFTTriAccPulseError)));






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


mixedFFTGyroSpectrum = zeros([size(adaptFFTPPGXGyroSpectrum) 3]);
mixedFFTGyroSpectrum(:,:,1) = adaptFFTPPGXGyroSpectrum;
mixedFFTGyroSpectrum(:,:,2) = adaptFFTPPGYGyroSpectrum;
mixedFFTGyroSpectrum(:,:,3) = adaptFFTPPGZGyroSpectrum;

[estimateAdaptFFTTriGyroPulseRate]= getHRFromMixedSpectrums(mixedFFTGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriGyroPulseRate = estimateAdaptFFTTriGyroPulseRate * 60;
estimateAdaptFFTTriGyroPulseError = sqrt(immse(estimateAdaptFFTTriGyroPulseRate,realHR));
disp(strcat('STFT(using FFT Gyro all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptFFTTriGyroPulseError)));


[adaptFFTPPGXAngleSpectrum,adaptFFTPPGXAngle]= GetSpectrumUsingFFTFilt(XAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTXAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTXAnglePulseRate = estimateAdaptFFTXAnglePulseRate * 60;
adaptFFTXAngleError = sqrt(immse(estimateAdaptFFTXAnglePulseRate,realHR));
disp(strcat('STFT(using FFT XAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTXAngleError)));

[adaptFFTPPGYAngleSpectrum,adaptFFTPPGYAngle]= GetSpectrumUsingFFTFilt(YAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTYAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYAnglePulseRate = estimateAdaptFFTYAnglePulseRate * 60;
adaptFFTYAngleError = sqrt(immse(estimateAdaptFFTYAnglePulseRate,realHR));
disp(strcat('STFT(using FFT YAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTYAngleError)));

[adaptFFTPPGZAngleSpectrum,adaptFFTPPGZAngle]= GetSpectrumUsingFFTFilt(ZAngle,PPG,FFTLength,Overlap,Fs);
[estimateAdaptFFTZAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZAnglePulseRate = estimateAdaptFFTZAnglePulseRate * 60;
adaptFFTZAngleError = sqrt(immse(estimateAdaptFFTZAnglePulseRate,realHR));
disp(strcat('STFT(using FFT ZAngle Only)とpeakからのPRの平均二乗誤差:',num2str(adaptFFTZAngleError)));


mixedFFTAngleSpectrum = zeros([size(adaptFFTPPGXAngleSpectrum) 3]);
mixedFFTAngleSpectrum(:,:,1) = adaptFFTPPGXAngleSpectrum;
mixedFFTAngleSpectrum(:,:,2) = adaptFFTPPGYAngleSpectrum;
mixedFFTAngleSpectrum(:,:,3) = adaptFFTPPGZAngleSpectrum;

[estimateAdaptFFTTriAnglePulseRate]= getHRFromMixedSpectrums(mixedFFTAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriAnglePulseRate = estimateAdaptFFTTriAnglePulseRate * 60;
estimateAdaptFFTTriAnglePulseError = sqrt(immse(estimateAdaptFFTTriAnglePulseRate,realHR));
disp(strcat('STFT(using FFT Angle all Axis)とpeakからのPRの平均二乗誤差:',num2str(estimateAdaptFFTTriAnglePulseError)));

