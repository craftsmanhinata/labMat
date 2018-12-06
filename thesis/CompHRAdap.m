%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

close all;
clear();
clc;

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;

FilterLength = 100;
disp(strcat('フィルタ長:',num2str(FilterLength)));
LMSStepSize = 0.1;
ForgettingFactor = 1;
FFTStepSize = 0.1;
disp(strcat('LMSステップサイズ:',num2str(LMSStepSize)));
disp(strcat('RLS忘却係数:',num2str(ForgettingFactor)));
disp(strcat('FFTステップサイズ:',num2str(FFTStepSize)));



ECGFolder = 'ECG\';
fileNameECG = 'ECG20181204_04.csv';
fileNamePPG = '20181204_Data04_Res.csv';
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
peakHeight = 30;
peakDistance = 0.4;
plotIs = true;

[ECGSpectrum,freq,ECGSpectrumTime] = spectrogram(dECG,hann(FFTLength),Overlap,FFTLength,Fs); 
ECGSpectrum = convertOneSidedSpectrum(ECGSpectrum,FFTLength);

[estimateHeartRate]= getHRFromSpectrum(ECGSpectrum,freq,freqRange,RHR);
estimateHeartRate = estimateHeartRate * 60;

HRFig = figure();
plot(ECGSpectrumTime,estimateHeartRate);
slidingSpectrumTime = spectrumTimeSlidingEndTime(ECGSpectrumTime,Ts);

realHR = calcRealHR(dECGTime,dECG,slidingSpectrumTime,peakHeight,peakDistance,plotIs);

figure(HRFig);
hold on;

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


fhc = 1.4; %unit:[Hz]
% fhc = max(freqRange);
NFhc = fhc/(Fs/2);
flc = 1.1;
% flc = min(freqRange);
NFlc = flc/(Fs/2);
%orig 3000
b = fir1(FilterLength-1,[NFlc NFhc]);
FilteredPPG = filter(b,1,PPG);
[FilteredPPGSpectrum,~,FilteredPPGSpectrumTime] = spectrogram(FilteredPPG,hann(FFTLength),Overlap,FFTLength,Fs); 
FilteredPPGSpectrum = convertOneSidedSpectrum(FilteredPPGSpectrum,FFTLength);
[estimateFilteredPulseRate]= getHRFromSpectrum(FilteredPPGSpectrum,freq,freqRange,RHR);
estimateFilteredPulseRate = estimateFilteredPulseRate * 60;
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateFilteredPulseRate);
PRFError = sqrt(immse(estimateFilteredPulseRate,realHR));
disp(strcat('FIRのRMSE:',num2str(PRFError)));
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

[Cxy,F] = mscohere(xAngleFromGyro,xAngleFromAcc,hann(FFTLength),...
    Overlap,FFTLength,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence X acc, X gyro');
xlabel('Frequency (Hz)');
grid;
coheFreqRange = [0.7 3.0];
xlim(coheFreqRange);
xPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);

[Cxy,F] = mscohere(yAngleFromGyro,yAngleFromAcc,hann(FFTLength),...
    Overlap,FFTLength,Fs);
yPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence Y acc, Y gyro');
xlabel('Frequency (Hz)');
grid;
xlim(coheFreqRange);

[Cxy,F] = mscohere(zAngleFromGyro,zAngleFromAcc,hann(FFTLength),...
    Overlap,FFTLength,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence Z acc, Z gyro');
xlabel('Frequency (Hz)');
grid;
xlim(coheFreqRange);
zPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);


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
ylabel('Angle (degree)');
xlabel('time (sec.)')

%dは観測信号, xは外乱, eを脈波として使用する
[adaptLMSPPGXAccSpectrum,adaptLMSPPGXAcc]= GetSpectrumUsingLMSFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateLMSAdaptXAccPulseRate]= getHRFromSpectrum(adaptLMSPPGXAccSpectrum,freq,freqRange,RHR);
estimateLMSAdaptXAccPulseRate = estimateLMSAdaptXAccPulseRate * 60;
adaptLMSXAccError = sqrt(immse(estimateLMSAdaptXAccPulseRate,realHR));
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateLMSAdaptXAccPulseRate);
legend('HR estimated from STFT','HR calculated from peaks','PR estimated from STFT(Raw data)','PR estimated from STFT using FIR filter',...
    'PR estimated from STFT using NLMS(xAcc Only)');
disp(strcat('NLMS(xAcc Only)のRMSE:',num2str(adaptLMSXAccError)));

[adaptLMSPPGYAccSpectrum,adaptLMSPPGYAcc]= GetSpectrumUsingLMSFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYAccPulseRate]= getHRFromSpectrum(adaptLMSPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYAccPulseRate = estimateAdaptLMSYAccPulseRate * 60;
adaptLMSYAccError = sqrt(immse(estimateAdaptLMSYAccPulseRate,realHR));
disp(strcat('NLMS(yAcc Only)のRMSE:',num2str(adaptLMSYAccError)));

[adaptLMSPPGZAccSpectrum,adaptLMSPPGZAcc]= GetSpectrumUsingLMSFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZAccPulseRate]= getHRFromSpectrum(adaptLMSPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZAccPulseRate = estimateAdaptLMSZAccPulseRate * 60;
adaptLMSZAccError = sqrt(immse(estimateAdaptLMSZAccPulseRate,realHR));
disp(strcat('NLMS(zAcc Only)のRMSE:',num2str(adaptLMSZAccError)));

mixedNLMSAccSpectrum = zeros([size(adaptLMSPPGXAccSpectrum) 3]);
mixedNLMSAccSpectrum(:,:,1) = adaptLMSPPGXAccSpectrum;
mixedNLMSAccSpectrum(:,:,2) = adaptLMSPPGYAccSpectrum;
mixedNLMSAccSpectrum(:,:,3) = adaptLMSPPGZAccSpectrum;

[estimateAdaptNLMSTriAccPulseRate]= getHRFromMixedSpectrums(mixedNLMSAccSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriAccPulseRate = estimateAdaptNLMSTriAccPulseRate * 60;
estimateAdaptNLMSTriAccPulseError = sqrt(immse(estimateAdaptNLMSTriAccPulseRate,realHR));
disp(strcat('NLMS(Acc all Axis)のRMSE:',num2str(estimateAdaptNLMSTriAccPulseError)));


[adaptLMSPPGXGyroSpectrum,adaptLMSPPGXGyro]= GetSpectrumUsingLMSFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSXGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSXGyroPulseRate = estimateAdaptLMSXGyroPulseRate * 60;
adaptLMSXGyroError = sqrt(immse(estimateAdaptLMSXGyroPulseRate,realHR));
disp(strcat('NLMS(xGyro Only)のRMSE:',num2str(adaptLMSXGyroError)));

[adaptLMSPPGYGyroSpectrum,adaptLMSPPGYGyro]= GetSpectrumUsingLMSFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYGyroPulseRate = estimateAdaptLMSYGyroPulseRate * 60;
adaptLMSYGyroError = sqrt(immse(estimateAdaptLMSYGyroPulseRate,realHR));
disp(strcat('NLMS(yGyro Only)のRMSE:',num2str(adaptLMSYGyroError)));

[adaptLMSPPGZGyroSpectrum,adaptLMSPPGZGyro]= GetSpectrumUsingLMSFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZGyroPulseRate]= getHRFromSpectrum(adaptLMSPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZGyroPulseRate = estimateAdaptLMSZGyroPulseRate * 60;
adaptLMSZGyroError = sqrt(immse(estimateAdaptLMSZGyroPulseRate,realHR));
disp(strcat('NLMS(zGyro Only)のRMSE:',num2str(adaptLMSZGyroError)));

mixedNLMSGyroSpectrum = zeros([size(adaptLMSPPGXGyroSpectrum) 3]);
mixedNLMSGyroSpectrum(:,:,1) = adaptLMSPPGXGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,2) = adaptLMSPPGYGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,3) = adaptLMSPPGZGyroSpectrum;

[estimateAdaptNLMSTriGyroPulseRate]= getHRFromMixedSpectrums(mixedNLMSGyroSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriGyroPulseRate = estimateAdaptNLMSTriGyroPulseRate * 60;
estimateAdaptNLMSTriGyroPulseError = sqrt(immse(estimateAdaptNLMSTriGyroPulseRate,realHR));
disp(strcat('NLMS(Gyro all Axis)のRMSE:',num2str(estimateAdaptNLMSTriGyroPulseError)));


[adaptLMSPPGXAngleSpectrum,adaptLMSPPGXAngle]= GetSpectrumUsingLMSFilt(XAngle,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSXAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSXAnglePulseRate = estimateAdaptLMSXAnglePulseRate * 60;
adaptLMSXAngleError = sqrt(immse(estimateAdaptLMSXAnglePulseRate,realHR));
disp(strcat('NLMS(XAngle Only)のRMSE:',num2str(adaptLMSXAngleError)));

[adaptLMSPPGYAngleSpectrum,adaptLMSPPGYAngle]= GetSpectrumUsingLMSFilt(YAngle,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSYAnglePulseRate = estimateAdaptLMSYAnglePulseRate * 60;
adaptLMSYAngleError = sqrt(immse(estimateAdaptLMSYAnglePulseRate,realHR));
disp(strcat('NLMS(YAngle Only)のRMSE:',num2str(adaptLMSYAngleError)));

[adaptLMSPPGZAngleSpectrum,adaptLMSPPGZAngle]= GetSpectrumUsingLMSFilt(ZAngle,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZAnglePulseRate]= getHRFromSpectrum(adaptLMSPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptLMSZAnglePulseRate = estimateAdaptLMSZAnglePulseRate * 60;
adaptLMSZAngleError = sqrt(immse(estimateAdaptLMSZAnglePulseRate,realHR));
disp(strcat('NLMS(ZAngle Only)のRMSE:',num2str(adaptLMSZAngleError)));


mixedNLMSAngleSpectrum = zeros([size(adaptLMSPPGXAngleSpectrum) 3]);
mixedNLMSAngleSpectrum(:,:,1) = adaptLMSPPGXAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,2) = adaptLMSPPGYAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,3) = adaptLMSPPGZAngleSpectrum;

[estimateAdaptNLMSTriAnglePulseRate]= getHRFromMixedSpectrums(mixedNLMSAngleSpectrum,freq,freqRange,RHR);
estimateAdaptNLMSTriAnglePulseRate = estimateAdaptNLMSTriAnglePulseRate * 60;
estimateAdaptNLMSTriAnglePulseError = sqrt(immse(estimateAdaptNLMSTriAnglePulseRate,realHR));
disp(strcat('NLMS(Angle all Axis)のRMSE:',num2str(estimateAdaptNLMSTriAnglePulseError)));




[adaptRLSPPGXAccSpectrum,adaptRLSPPGXAcc]= GetSpectrumUsingRLSFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateRLSAdaptXAccPulseRate]= getHRFromSpectrum(adaptRLSPPGXAccSpectrum,freq,freqRange,RHR);
estimateRLSAdaptXAccPulseRate = estimateRLSAdaptXAccPulseRate * 60;
adaptRLSXAccError = sqrt(immse(estimateRLSAdaptXAccPulseRate,realHR));
disp(strcat('RLS(xAcc Only)のRMSE:',num2str(adaptRLSXAccError)));

[adaptRLSPPGYAccSpectrum,adaptRLSPPGYAcc]= GetSpectrumUsingRLSFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYAccPulseRate]= getHRFromSpectrum(adaptRLSPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYAccPulseRate = estimateAdaptRLSYAccPulseRate * 60;
adaptRLSYAccError = sqrt(immse(estimateAdaptRLSYAccPulseRate,realHR));
disp(strcat('RLS(yAcc Only)のRMSE:',num2str(adaptRLSYAccError)));

[adaptRLSPPGZAccSpectrum,adaptRLSPPGZAcc]= GetSpectrumUsingRLSFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZAccPulseRate]= getHRFromSpectrum(adaptRLSPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZAccPulseRate = estimateAdaptRLSZAccPulseRate * 60;
adaptRLSZAccError = sqrt(immse(estimateAdaptRLSZAccPulseRate,realHR));
disp(strcat('RLS(zAcc Only)のRMSE:',num2str(adaptRLSZAccError)));


mixedRLSAccSpectrum = zeros([size(adaptRLSPPGXAccSpectrum) 3]);
mixedRLSAccSpectrum(:,:,1) = adaptRLSPPGXAccSpectrum;
mixedRLSAccSpectrum(:,:,2) = adaptRLSPPGYAccSpectrum;
mixedRLSAccSpectrum(:,:,3) = adaptRLSPPGZAccSpectrum;

[estimateAdaptRLSTriAccPulseRate]= getHRFromMixedSpectrums(mixedRLSAccSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriAccPulseRate = estimateAdaptRLSTriAccPulseRate * 60;
estimateAdaptRLSTriAccPulseError = sqrt(immse(estimateAdaptRLSTriAccPulseRate,realHR));
disp(strcat('RLS(Acc all Axis)のRMSE:',num2str(estimateAdaptRLSTriAccPulseError)));




[adaptRLSPPGXGyroSpectrum,adaptRLSPPGXGyro]= GetSpectrumUsingRLSFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSXGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSXGyroPulseRate = estimateAdaptRLSXGyroPulseRate * 60;
adaptRLSXGyroError = sqrt(immse(estimateAdaptRLSXGyroPulseRate,realHR));
disp(strcat('RLS(xGyro Only)のRMSE:',num2str(adaptRLSXGyroError)));

[adaptRLSPPGYGyroSpectrum,adaptRLSPPGYGyro]= GetSpectrumUsingRLSFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYGyroPulseRate = estimateAdaptRLSYGyroPulseRate * 60;
adaptRLSYGyroError = sqrt(immse(estimateAdaptRLSYGyroPulseRate,realHR));
disp(strcat('RLS(yGyro Only)のRMSE:',num2str(adaptRLSYGyroError)));

[adaptRLSPPGZGyroSpectrum,adaptRLSPPGZGyro]= GetSpectrumUsingRLSFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZGyroPulseRate]= getHRFromSpectrum(adaptRLSPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZGyroPulseRate = estimateAdaptRLSZGyroPulseRate * 60;
adaptRLSZGyroError = sqrt(immse(estimateAdaptRLSZGyroPulseRate,realHR));
disp(strcat('RLS(zGyro Only)のRMSE',num2str(adaptRLSZGyroError)));


mixedRLSGyroSpectrum = zeros([size(adaptRLSPPGXGyroSpectrum) 3]);
mixedRLSGyroSpectrum(:,:,1) = adaptRLSPPGXGyroSpectrum;
mixedRLSGyroSpectrum(:,:,2) = adaptRLSPPGYGyroSpectrum;
mixedRLSGyroSpectrum(:,:,3) = adaptRLSPPGZGyroSpectrum;

[estimateAdaptRLSTriGyroPulseRate]= getHRFromMixedSpectrums(mixedRLSGyroSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriGyroPulseRate = estimateAdaptRLSTriGyroPulseRate * 60;
estimateAdaptRLSTriGyroPulseError = sqrt(immse(estimateAdaptRLSTriGyroPulseRate,realHR));
disp(strcat('RLS(Gyro all Axis)のRMSE:',num2str(estimateAdaptRLSTriGyroPulseError)));



[adaptRLSPPGXAngleSpectrum,adaptRLSPPGXAngle]= GetSpectrumUsingRLSFilt(XAngle,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSXAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSXAnglePulseRate = estimateAdaptRLSXAnglePulseRate * 60;
adaptRLSXAngleError = sqrt(immse(estimateAdaptRLSXAnglePulseRate,realHR));
disp(strcat('RLS(XAngle Only)のRMSE:',num2str(adaptRLSXAngleError)));

[adaptRLSPPGYAngleSpectrum,adaptRLSPPGYAngle]= GetSpectrumUsingRLSFilt(YAngle,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSYAnglePulseRate = estimateAdaptRLSYAnglePulseRate * 60;
adaptRLSYAngleError = sqrt(immse(estimateAdaptRLSYAnglePulseRate,realHR));
disp(strcat('RLS(YAngle Only)のRMSE:',num2str(adaptRLSYAngleError)));

[adaptRLSPPGZAngleSpectrum,adaptRLSPPGZAngle]= GetSpectrumUsingRLSFilt(ZAngle,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZAnglePulseRate]= getHRFromSpectrum(adaptRLSPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSZAnglePulseRate = estimateAdaptRLSZAnglePulseRate * 60;
adaptRLSZAngleError = sqrt(immse(estimateAdaptRLSZAnglePulseRate,realHR));
disp(strcat('RLS(ZAngle Only)のRMSE:',num2str(adaptRLSZAngleError)));


mixedRLSAngleSpectrum = zeros([size(adaptRLSPPGXAngleSpectrum) 3]);
mixedRLSAngleSpectrum(:,:,1) = adaptRLSPPGXAngleSpectrum;
mixedRLSAngleSpectrum(:,:,2) = adaptRLSPPGYAngleSpectrum;
mixedRLSAngleSpectrum(:,:,3) = adaptRLSPPGZAngleSpectrum;

[estimateAdaptRLSTriAnglePulseRate]= getHRFromMixedSpectrums(mixedRLSAngleSpectrum,freq,freqRange,RHR);
estimateAdaptRLSTriAnglePulseRate = estimateAdaptRLSTriAnglePulseRate * 60;
estimateAdaptRLSTriAnglePulseError = sqrt(immse(estimateAdaptRLSTriAnglePulseRate,realHR));
disp(strcat('RLS(Angle all Axis)のRMSE:',num2str(estimateAdaptRLSTriAnglePulseError)));



[adaptFFTPPGXAccSpectrum,adaptFFTPPGXAcc]= GetSpectrumUsingFFTFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateFFTAdaptXAccPulseRate]= getHRFromSpectrum(adaptFFTPPGXAccSpectrum,freq,freqRange,RHR);
estimateFFTAdaptXAccPulseRate = estimateFFTAdaptXAccPulseRate * 60;
adaptFFTXAccError = sqrt(immse(estimateFFTAdaptXAccPulseRate,realHR));
disp(strcat('FFT(xAcc Only)のRMSE:',num2str(adaptFFTXAccError)));

[adaptFFTPPGYAccSpectrum,adaptFFTPPGYAcc]= GetSpectrumUsingFFTFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYAccPulseRate]= getHRFromSpectrum(adaptFFTPPGYAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYAccPulseRate = estimateAdaptFFTYAccPulseRate * 60;
adaptFFTYAccError = sqrt(immse(estimateAdaptFFTYAccPulseRate,realHR));
disp(strcat('FFT(yAcc Only)のRMSE:',num2str(adaptFFTYAccError)));

[adaptFFTPPGZAccSpectrum,adaptFFTPPGZAcc]= GetSpectrumUsingFFTFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZAccPulseRate]= getHRFromSpectrum(adaptFFTPPGZAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZAccPulseRate = estimateAdaptFFTZAccPulseRate * 60;
adaptFFTZAccError = sqrt(immse(estimateAdaptFFTZAccPulseRate,realHR));
disp(strcat('FFT(zAcc Only)のRMSE:',num2str(adaptFFTZAccError)));


mixedFFTAccSpectrum = zeros([size(adaptFFTPPGXAccSpectrum) 3]);
mixedFFTAccSpectrum(:,:,1) = adaptFFTPPGXAccSpectrum;
mixedFFTAccSpectrum(:,:,2) = adaptFFTPPGYAccSpectrum;
mixedFFTAccSpectrum(:,:,3) = adaptFFTPPGZAccSpectrum;

[estimateAdaptFFTTriAccPulseRate]= getHRFromMixedSpectrums(mixedFFTAccSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriAccPulseRate = estimateAdaptFFTTriAccPulseRate * 60;
estimateAdaptFFTTriAccPulseError = sqrt(immse(estimateAdaptFFTTriAccPulseRate,realHR));
disp(strcat('FFT(Acc all Axis)のRMSE:',num2str(estimateAdaptFFTTriAccPulseError)));






[adaptFFTPPGXGyroSpectrum,adaptFFTPPGXGyro]= GetSpectrumUsingFFTFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTXGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGXGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTXGyroPulseRate = estimateAdaptFFTXGyroPulseRate * 60;
adaptFFTXGyroError = sqrt(immse(estimateAdaptFFTXGyroPulseRate,realHR));
disp(strcat('FFT(xGyro Only)のRMSE:',num2str(adaptFFTXGyroError)));

[adaptFFTPPGYGyroSpectrum,adaptFFTPPGYGyro]= GetSpectrumUsingFFTFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGYGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYGyroPulseRate = estimateAdaptFFTYGyroPulseRate * 60;
adaptFFTYGyroError = sqrt(immse(estimateAdaptFFTYGyroPulseRate,realHR));
disp(strcat('FFT(yGyro Only)のRMSE:',num2str(adaptFFTYGyroError)));

[adaptFFTPPGZGyroSpectrum,adaptFFTPPGZGyro]= GetSpectrumUsingFFTFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZGyroPulseRate]= getHRFromSpectrum(adaptFFTPPGZGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZGyroPulseRate = estimateAdaptFFTZGyroPulseRate * 60;
adaptFFTZGyroError = sqrt(immse(estimateAdaptFFTZGyroPulseRate,realHR));
disp(strcat('FFT(zGyro Only)のRMSE:',num2str(adaptFFTZGyroError)));


mixedFFTGyroSpectrum = zeros([size(adaptFFTPPGXGyroSpectrum) 3]);
mixedFFTGyroSpectrum(:,:,1) = adaptFFTPPGXGyroSpectrum;
mixedFFTGyroSpectrum(:,:,2) = adaptFFTPPGYGyroSpectrum;
mixedFFTGyroSpectrum(:,:,3) = adaptFFTPPGZGyroSpectrum;

[estimateAdaptFFTTriGyroPulseRate]= getHRFromMixedSpectrums(mixedFFTGyroSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriGyroPulseRate = estimateAdaptFFTTriGyroPulseRate * 60;
estimateAdaptFFTTriGyroPulseError = sqrt(immse(estimateAdaptFFTTriGyroPulseRate,realHR));
disp(strcat('FFT(Gyro all Axis)のRMSE:',num2str(estimateAdaptFFTTriGyroPulseError)));


[adaptFFTPPGXAngleSpectrum,adaptFFTPPGXAngle]= GetSpectrumUsingFFTFilt(XAngle,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTXAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGXAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTXAnglePulseRate = estimateAdaptFFTXAnglePulseRate * 60;
adaptFFTXAngleError = sqrt(immse(estimateAdaptFFTXAnglePulseRate,realHR));
disp(strcat('FFT(XAngle Only)のRMSE:',num2str(adaptFFTXAngleError)));

[adaptFFTPPGYAngleSpectrum,adaptFFTPPGYAngle]= GetSpectrumUsingFFTFilt(YAngle,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGYAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTYAnglePulseRate = estimateAdaptFFTYAnglePulseRate * 60;
adaptFFTYAngleError = sqrt(immse(estimateAdaptFFTYAnglePulseRate,realHR));
disp(strcat('FFT(YAngle Only)のRMSE:',num2str(adaptFFTYAngleError)));

[adaptFFTPPGZAngleSpectrum,adaptFFTPPGZAngle]= GetSpectrumUsingFFTFilt(ZAngle,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZAnglePulseRate]= getHRFromSpectrum(adaptFFTPPGZAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTZAnglePulseRate = estimateAdaptFFTZAnglePulseRate * 60;
adaptFFTZAngleError = sqrt(immse(estimateAdaptFFTZAnglePulseRate,realHR));
disp(strcat('FFT(ZAngle Only)のRMSE:',num2str(adaptFFTZAngleError)));


mixedFFTAngleSpectrum = zeros([size(adaptFFTPPGXAngleSpectrum) 3]);
mixedFFTAngleSpectrum(:,:,1) = adaptFFTPPGXAngleSpectrum;
mixedFFTAngleSpectrum(:,:,2) = adaptFFTPPGYAngleSpectrum;
mixedFFTAngleSpectrum(:,:,3) = adaptFFTPPGZAngleSpectrum;

[estimateAdaptFFTTriAnglePulseRate]= getHRFromMixedSpectrums(mixedFFTAngleSpectrum,freq,freqRange,RHR);
estimateAdaptFFTTriAnglePulseRate = estimateAdaptFFTTriAnglePulseRate * 60;
estimateAdaptFFTTriAnglePulseError = sqrt(immse(estimateAdaptFFTTriAnglePulseRate,realHR));
disp(strcat('FFT(Angle all Axis)のRMSE:',num2str(estimateAdaptFFTTriAnglePulseError)));

