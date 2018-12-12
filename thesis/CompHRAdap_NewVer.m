%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

close all;
clear();
clc;

load('.\ECG\ECGTransitionPd.mat');

percentage = 0;

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;
FontSize = 20;
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
fileNameECG = 'ECG20181204_10.csv';
fileNamePPG = '20181204_Data10_Res.csv';
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

[estimateHeartRate]= getHRFromSpectrumPd(ECGSpectrum,freq,freqRange,RHR,pd,percentage);
estimateHeartRate = estimateHeartRate * 60;

HRFig = figure();
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
[estimatePulseRate]= getHRFromSpectrumPd(PPGSpectrum,freq,freqRange,RHR,pd,percentage);
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
[estimateFilteredPulseRate]= getHRFromSpectrumPd(FilteredPPGSpectrum,freq,freqRange,RHR,pd,percentage);
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


figure();
plot(dECGTime,PPG);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('PPG Signal(a. u.)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);

FontSize = 16;
figure();
xAccAx = subplot(3,1,1);
plot(dECGTime,xAcc);
title('X Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Acceleration(m/s^{2})','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
yAccAx = subplot(3,1,2);
plot(dECGTime,yAcc);
title('Y Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Acceleration(m/s^{2})','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
zAccAx = subplot(3,1,3);
plot(dECGTime,zAcc);
title('Z Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Acceleration(m/s^{2})','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
linkaxes([xAccAx,yAccAx,zAccAx],'xy');

FontSize = 16;
figure();
xGyroAx = subplot(3,1,1);
plot(dECGTime,xGyro);
title('X Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
yGyroAx = subplot(3,1,2);
plot(dECGTime,yGyro);
title('Y Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
zGyroAx = subplot(3,1,3);
plot(dECGTime,zGyro);
title('Z Axis','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
linkaxes([xGyroAx,yGyroAx,zGyroAx],'xy');

FontSize = 20;
cutoffFreq = 1.064;


filterOrder = 2900;

highPass = fir1(filterOrder,cutoffFreq/(Fs/2),'high');
lowPass = fir1(filterOrder,cutoffFreq/(Fs/2),'low');

FilteredXGyro = filtfilt(highPass,1,xGyro);
FilteredYGyro = filtfilt(highPass,1,yGyro);
FilteredZGyro = filtfilt(highPass,1,zGyro);
FilteredXAcc = filtfilt(lowPass,1,xAcc);
FilteredYAcc = filtfilt(lowPass,1,yAcc);
FilteredZAcc = filtfilt(lowPass,1,zAcc);

[roll, pitch] = calcRollPitchFromAcc([FilteredXAcc FilteredYAcc FilteredZAcc]);
[rollSpeed,pitchSpeed,yawSpeed] = calcAngleSpeed([FilteredXGyro FilteredYGyro FilteredZGyro],roll,pitch);





FontSize = 16;
figure();
rollAngleAx = subplot(3,1,1);
plot(dECGTime,rollSpeed);
title('Roll Angle','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
pitchAngleAx = subplot(3,1,2);
plot(dECGTime,pitchSpeed);
title('Pitch Angle','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
yawAngleAx = subplot(3,1,3);
plot(dECGTime,yawSpeed);
title('Yaw Angle','FontSize',FontSize);
xlabel('Time(sec.)','FontSize',FontSize);
ylabel('Angle Speed(rad/s)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
xlim([0 180]);
linkaxes([rollAngleAx,pitchAngleAx,yawAngleAx],'xy');

FontSize = 20;


[Cxy,F] = mscohere(FilteredXAcc,rollSpeed,hann(FFTLength),...
    Overlap,FFTLength,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence X Axis Acceleration, Roll Angle Speed','FontSize',FontSize);
xlabel('Frequency (Hz)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
grid;
coheFreqRange = [0.7 3.0];
xlim(coheFreqRange);
ylim([0 1]);

[Cxy,F] = mscohere(FilteredXGyro,rollSpeed,hann(FFTLength),...
    Overlap,FFTLength,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence X Gyro, Roll Angle Speed','FontSize',FontSize);
xlabel('Frequency (Hz)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
grid;
coheFreqRange = [0.7 3.0];
xlim(coheFreqRange);
ylim([0 1]);


[Cxy,F] = mscohere(FilteredXGyro,FilteredXAcc,hann(FFTLength),...
    Overlap,FFTLength,Fs);
figure;
plot(F,Cxy);
title('Magnitude-Squared Coherence X Axis Acceleration, X Gyro','FontSize',FontSize);
xlabel('Frequency (Hz)','FontSize',FontSize);
grid;
set(gca,'FontSize',FontSize);
coheFreqRange = [0.7 3.0];
xlim(coheFreqRange);
ylim([0 1]);

R = corrcoef(PPG,xAcc);
disp(strcat('PPG,xAcc:',num2str(R(1,2))));
R = corrcoef(PPG,yAcc);
disp(strcat('PPG,yAcc:',num2str(R(1,2))));
R = corrcoef(PPG,zAcc);
disp(strcat('PPG,zAcc:',num2str(R(1,2))));
R = corrcoef(PPG,xGyro);
disp(strcat('PPG,xGyro:',num2str(R(1,2))));
R = corrcoef(PPG,yGyro);
disp(strcat('PPG,yGyro:',num2str(R(1,2))));
R = corrcoef(PPG,zGyro);
disp(strcat('PPG,zGyro:',num2str(R(1,2))));
R = corrcoef(PPG,rollSpeed);
disp(strcat('PPG,roll:',num2str(R(1,2))));
R = corrcoef(PPG,pitchSpeed);
disp(strcat('PPG,pitch:',num2str(R(1,2))));
R = corrcoef(PPG,yawSpeed);
disp(strcat('PPG,yaw:',num2str(R(1,2))));
R = corrcoef(xAcc,rollSpeed);
disp(strcat('xAcc,roll:',num2str(R(1,2))));
R = corrcoef(yAcc,pitchSpeed);
disp(strcat('yAcc,pitch:',num2str(R(1,2))));
R = corrcoef(zAcc,yawSpeed);
disp(strcat('zAcc,yaw:',num2str(R(1,2))));
R = corrcoef(xGyro,rollSpeed);
disp(strcat('xGyro,roll:',num2str(R(1,2))));
R = corrcoef(yGyro,pitchSpeed);
disp(strcat('yGyro,pitch:',num2str(R(1,2))));
R = corrcoef(zGyro,yawSpeed);
disp(strcat('zGyro,yaw:',num2str(R(1,2))));


figure();
plot(dECGTime,rollSpeed);
hold on;
plot(dECGTime,pitchSpeed);
plot(dECGTime,yawSpeed);
legend('Roll','Pitch','Yaw');
ylabel('Angle Speed(rad/sec)');
xlabel('time (sec.)')

%dは観測信号, xは外乱, eを脈波として使用する
[adaptLMSPPGXAccSpectrum,adaptLMSPPGXAcc]= GetSpectrumUsingLMSFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateLMSAdaptXAccPulseRate]= getHRFromSpectrumPd(adaptLMSPPGXAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateLMSAdaptXAccPulseRate = estimateLMSAdaptXAccPulseRate * 60;
adaptLMSXAccError = sqrt(immse(estimateLMSAdaptXAccPulseRate,realHR));
figure(HRFig);
plot(FilteredPPGSpectrumTime,estimateLMSAdaptXAccPulseRate);
legend('HR calculated from peaks','PR estimated from STFT(Raw data)','PR estimated from STFT using FIR filter',...
    'PR estimated from STFT using NLMS(xAcc Only)');
disp(strcat('NLMS(xAcc Only)のRMSE:',num2str(adaptLMSXAccError)));

[adaptLMSPPGYAccSpectrum,adaptLMSPPGYAcc]= GetSpectrumUsingLMSFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYAccPulseRate]= getHRFromSpectrumPd(adaptLMSPPGYAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSYAccPulseRate = estimateAdaptLMSYAccPulseRate * 60;
adaptLMSYAccError = sqrt(immse(estimateAdaptLMSYAccPulseRate,realHR));
disp(strcat('NLMS(yAcc Only)のRMSE:',num2str(adaptLMSYAccError)));

[adaptLMSPPGZAccSpectrum,adaptLMSPPGZAcc]= GetSpectrumUsingLMSFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZAccPulseRate]= getHRFromSpectrumPd(adaptLMSPPGZAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSZAccPulseRate = estimateAdaptLMSZAccPulseRate * 60;
adaptLMSZAccError = sqrt(immse(estimateAdaptLMSZAccPulseRate,realHR));
disp(strcat('NLMS(zAcc Only)のRMSE:',num2str(adaptLMSZAccError)));

mixedNLMSAccSpectrum = zeros([size(adaptLMSPPGXAccSpectrum) 3]);
mixedNLMSAccSpectrum(:,:,1) = adaptLMSPPGXAccSpectrum;
mixedNLMSAccSpectrum(:,:,2) = adaptLMSPPGYAccSpectrum;
mixedNLMSAccSpectrum(:,:,3) = adaptLMSPPGZAccSpectrum;

[estimateAdaptNLMSTriAccPulseRate]= getHRFromMixedSpectrumsPd(mixedNLMSAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptNLMSTriAccPulseRate = estimateAdaptNLMSTriAccPulseRate * 60;
estimateAdaptNLMSTriAccPulseError = sqrt(immse(estimateAdaptNLMSTriAccPulseRate,realHR));
disp(strcat('NLMS(Acc all Axis)のRMSE:',num2str(estimateAdaptNLMSTriAccPulseError)));


[adaptLMSPPGXGyroSpectrum,adaptLMSPPGXGyro]= GetSpectrumUsingLMSFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSXGyroPulseRate]= getHRFromSpectrumPd(adaptLMSPPGXGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSXGyroPulseRate = estimateAdaptLMSXGyroPulseRate * 60;
adaptLMSXGyroError = sqrt(immse(estimateAdaptLMSXGyroPulseRate,realHR));
disp(strcat('NLMS(xGyro Only)のRMSE:',num2str(adaptLMSXGyroError)));

[adaptLMSPPGYGyroSpectrum,adaptLMSPPGYGyro]= GetSpectrumUsingLMSFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYGyroPulseRate]= getHRFromSpectrumPd(adaptLMSPPGYGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSYGyroPulseRate = estimateAdaptLMSYGyroPulseRate * 60;
adaptLMSYGyroError = sqrt(immse(estimateAdaptLMSYGyroPulseRate,realHR));
disp(strcat('NLMS(yGyro Only)のRMSE:',num2str(adaptLMSYGyroError)));

[adaptLMSPPGZGyroSpectrum,adaptLMSPPGZGyro]= GetSpectrumUsingLMSFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZGyroPulseRate]= getHRFromSpectrumPd(adaptLMSPPGZGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSZGyroPulseRate = estimateAdaptLMSZGyroPulseRate * 60;
adaptLMSZGyroError = sqrt(immse(estimateAdaptLMSZGyroPulseRate,realHR));
disp(strcat('NLMS(zGyro Only)のRMSE:',num2str(adaptLMSZGyroError)));

mixedNLMSGyroSpectrum = zeros([size(adaptLMSPPGXGyroSpectrum) 3]);
mixedNLMSGyroSpectrum(:,:,1) = adaptLMSPPGXGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,2) = adaptLMSPPGYGyroSpectrum;
mixedNLMSGyroSpectrum(:,:,3) = adaptLMSPPGZGyroSpectrum;

[estimateAdaptNLMSTriGyroPulseRate]= getHRFromMixedSpectrumsPd(mixedNLMSGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptNLMSTriGyroPulseRate = estimateAdaptNLMSTriGyroPulseRate * 60;
estimateAdaptNLMSTriGyroPulseError = sqrt(immse(estimateAdaptNLMSTriGyroPulseRate,realHR));
disp(strcat('NLMS(Gyro all Axis)のRMSE:',num2str(estimateAdaptNLMSTriGyroPulseError)));


[adaptLMSPPGXAngleSpectrum,adaptLMSPPGXAngle]= GetSpectrumUsingLMSFilt(rollSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSXAnglePulseRate]= getHRFromSpectrumPd(adaptLMSPPGXAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSXAnglePulseRate = estimateAdaptLMSXAnglePulseRate * 60;
adaptLMSXAngleError = sqrt(immse(estimateAdaptLMSXAnglePulseRate,realHR));
disp(strcat('NLMS(RollSpeed Only)のRMSE:',num2str(adaptLMSXAngleError)));

[adaptLMSPPGYAngleSpectrum,adaptLMSPPGYAngle]= GetSpectrumUsingLMSFilt(pitchSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSYAnglePulseRate]= getHRFromSpectrumPd(adaptLMSPPGYAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSYAnglePulseRate = estimateAdaptLMSYAnglePulseRate * 60;
adaptLMSYAngleError = sqrt(immse(estimateAdaptLMSYAnglePulseRate,realHR));
disp(strcat('NLMS(PitchSpeed Only)のRMSE:',num2str(adaptLMSYAngleError)));

[adaptLMSPPGZAngleSpectrum,adaptLMSPPGZAngle]= GetSpectrumUsingLMSFilt(yawSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,LMSStepSize);
[estimateAdaptLMSZAnglePulseRate]= getHRFromSpectrumPd(adaptLMSPPGZAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptLMSZAnglePulseRate = estimateAdaptLMSZAnglePulseRate * 60;
adaptLMSZAngleError = sqrt(immse(estimateAdaptLMSZAnglePulseRate,realHR));
disp(strcat('NLMS(YawSpeed Only)のRMSE:',num2str(adaptLMSZAngleError)));


mixedNLMSAngleSpectrum = zeros([size(adaptLMSPPGXAngleSpectrum) 3]);
mixedNLMSAngleSpectrum(:,:,1) = adaptLMSPPGXAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,2) = adaptLMSPPGYAngleSpectrum;
mixedNLMSAngleSpectrum(:,:,3) = adaptLMSPPGZAngleSpectrum;

[estimateAdaptNLMSTriAnglePulseRate]= getHRFromMixedSpectrumsPd(mixedNLMSAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptNLMSTriAnglePulseRate = estimateAdaptNLMSTriAnglePulseRate * 60;
estimateAdaptNLMSTriAnglePulseError = sqrt(immse(estimateAdaptNLMSTriAnglePulseRate,realHR));
disp(strcat('NLMS(Angle all Axis)のRMSE:',num2str(estimateAdaptNLMSTriAnglePulseError)));




[adaptRLSPPGXAccSpectrum,adaptRLSPPGXAcc]= GetSpectrumUsingRLSFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateRLSAdaptXAccPulseRate]= getHRFromSpectrumPd(adaptRLSPPGXAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateRLSAdaptXAccPulseRate = estimateRLSAdaptXAccPulseRate * 60;
adaptRLSXAccError = sqrt(immse(estimateRLSAdaptXAccPulseRate,realHR));
disp(strcat('RLS(xAcc Only)のRMSE:',num2str(adaptRLSXAccError)));

[adaptRLSPPGYAccSpectrum,adaptRLSPPGYAcc]= GetSpectrumUsingRLSFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYAccPulseRate]= getHRFromSpectrumPd(adaptRLSPPGYAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSYAccPulseRate = estimateAdaptRLSYAccPulseRate * 60;
adaptRLSYAccError = sqrt(immse(estimateAdaptRLSYAccPulseRate,realHR));
disp(strcat('RLS(yAcc Only)のRMSE:',num2str(adaptRLSYAccError)));

[adaptRLSPPGZAccSpectrum,adaptRLSPPGZAcc]= GetSpectrumUsingRLSFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZAccPulseRate]= getHRFromSpectrumPd(adaptRLSPPGZAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSZAccPulseRate = estimateAdaptRLSZAccPulseRate * 60;
adaptRLSZAccError = sqrt(immse(estimateAdaptRLSZAccPulseRate,realHR));
disp(strcat('RLS(zAcc Only)のRMSE:',num2str(adaptRLSZAccError)));


mixedRLSAccSpectrum = zeros([size(adaptRLSPPGXAccSpectrum) 3]);
mixedRLSAccSpectrum(:,:,1) = adaptRLSPPGXAccSpectrum;
mixedRLSAccSpectrum(:,:,2) = adaptRLSPPGYAccSpectrum;
mixedRLSAccSpectrum(:,:,3) = adaptRLSPPGZAccSpectrum;

[estimateAdaptRLSTriAccPulseRate]= getHRFromMixedSpectrumsPd(mixedRLSAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSTriAccPulseRate = estimateAdaptRLSTriAccPulseRate * 60;
estimateAdaptRLSTriAccPulseError = sqrt(immse(estimateAdaptRLSTriAccPulseRate,realHR));
disp(strcat('RLS(Acc all Axis)のRMSE:',num2str(estimateAdaptRLSTriAccPulseError)));




[adaptRLSPPGXGyroSpectrum,adaptRLSPPGXGyro]= GetSpectrumUsingRLSFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSXGyroPulseRate]= getHRFromSpectrumPd(adaptRLSPPGXGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSXGyroPulseRate = estimateAdaptRLSXGyroPulseRate * 60;
adaptRLSXGyroError = sqrt(immse(estimateAdaptRLSXGyroPulseRate,realHR));
disp(strcat('RLS(xGyro Only)のRMSE:',num2str(adaptRLSXGyroError)));

[adaptRLSPPGYGyroSpectrum,adaptRLSPPGYGyro]= GetSpectrumUsingRLSFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYGyroPulseRate]= getHRFromSpectrumPd(adaptRLSPPGYGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSYGyroPulseRate = estimateAdaptRLSYGyroPulseRate * 60;
adaptRLSYGyroError = sqrt(immse(estimateAdaptRLSYGyroPulseRate,realHR));
disp(strcat('RLS(yGyro Only)のRMSE:',num2str(adaptRLSYGyroError)));

[adaptRLSPPGZGyroSpectrum,adaptRLSPPGZGyro]= GetSpectrumUsingRLSFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZGyroPulseRate]= getHRFromSpectrumPd(adaptRLSPPGZGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSZGyroPulseRate = estimateAdaptRLSZGyroPulseRate * 60;
adaptRLSZGyroError = sqrt(immse(estimateAdaptRLSZGyroPulseRate,realHR));
disp(strcat('RLS(zGyro Only)のRMSE',num2str(adaptRLSZGyroError)));


mixedRLSGyroSpectrum = zeros([size(adaptRLSPPGXGyroSpectrum) 3]);
mixedRLSGyroSpectrum(:,:,1) = adaptRLSPPGXGyroSpectrum;
mixedRLSGyroSpectrum(:,:,2) = adaptRLSPPGYGyroSpectrum;
mixedRLSGyroSpectrum(:,:,3) = adaptRLSPPGZGyroSpectrum;

[estimateAdaptRLSTriGyroPulseRate]= getHRFromMixedSpectrumsPd(mixedRLSGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSTriGyroPulseRate = estimateAdaptRLSTriGyroPulseRate * 60;
estimateAdaptRLSTriGyroPulseError = sqrt(immse(estimateAdaptRLSTriGyroPulseRate,realHR));
disp(strcat('RLS(Gyro all Axis)のRMSE:',num2str(estimateAdaptRLSTriGyroPulseError)));



[adaptRLSPPGXAngleSpectrum,adaptRLSPPGXAngle]= GetSpectrumUsingRLSFilt(rollSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSXAnglePulseRate]= getHRFromSpectrumPd(adaptRLSPPGXAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSXAnglePulseRate = estimateAdaptRLSXAnglePulseRate * 60;
adaptRLSXAngleError = sqrt(immse(estimateAdaptRLSXAnglePulseRate,realHR));
disp(strcat('RLS(Roll Only)のRMSE:',num2str(adaptRLSXAngleError)));

[adaptRLSPPGYAngleSpectrum,adaptRLSPPGYAngle]= GetSpectrumUsingRLSFilt(pitchSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSYAnglePulseRate]= getHRFromSpectrumPd(adaptRLSPPGYAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSYAnglePulseRate = estimateAdaptRLSYAnglePulseRate * 60;
adaptRLSYAngleError = sqrt(immse(estimateAdaptRLSYAnglePulseRate,realHR));
disp(strcat('RLS(Pitch Only)のRMSE:',num2str(adaptRLSYAngleError)));

[adaptRLSPPGZAngleSpectrum,adaptRLSPPGZAngle]= GetSpectrumUsingRLSFilt(yawSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,ForgettingFactor);
[estimateAdaptRLSZAnglePulseRate]= getHRFromSpectrumPd(adaptRLSPPGZAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSZAnglePulseRate = estimateAdaptRLSZAnglePulseRate * 60;
adaptRLSZAngleError = sqrt(immse(estimateAdaptRLSZAnglePulseRate,realHR));
disp(strcat('RLS(Yaw Only)のRMSE:',num2str(adaptRLSZAngleError)));


mixedRLSAngleSpectrum = zeros([size(adaptRLSPPGXAngleSpectrum) 3]);
mixedRLSAngleSpectrum(:,:,1) = adaptRLSPPGXAngleSpectrum;
mixedRLSAngleSpectrum(:,:,2) = adaptRLSPPGYAngleSpectrum;
mixedRLSAngleSpectrum(:,:,3) = adaptRLSPPGZAngleSpectrum;

[estimateAdaptRLSTriAnglePulseRate]= getHRFromMixedSpectrumsPd(mixedRLSAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptRLSTriAnglePulseRate = estimateAdaptRLSTriAnglePulseRate * 60;
estimateAdaptRLSTriAnglePulseError = sqrt(immse(estimateAdaptRLSTriAnglePulseRate,realHR));
disp(strcat('RLS(Angle all Axis)のRMSE:',num2str(estimateAdaptRLSTriAnglePulseError)));



[adaptFFTPPGXAccSpectrum,adaptFFTPPGXAcc]= GetSpectrumUsingFFTFilt(xAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateFFTAdaptXAccPulseRate]= getHRFromSpectrumPd(adaptFFTPPGXAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateFFTAdaptXAccPulseRate = estimateFFTAdaptXAccPulseRate * 60;
adaptFFTXAccError = sqrt(immse(estimateFFTAdaptXAccPulseRate,realHR));
disp(strcat('FFT(xAcc Only)のRMSE:',num2str(adaptFFTXAccError)));

[adaptFFTPPGYAccSpectrum,adaptFFTPPGYAcc]= GetSpectrumUsingFFTFilt(yAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYAccPulseRate]= getHRFromSpectrumPd(adaptFFTPPGYAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTYAccPulseRate = estimateAdaptFFTYAccPulseRate * 60;
adaptFFTYAccError = sqrt(immse(estimateAdaptFFTYAccPulseRate,realHR));
disp(strcat('FFT(yAcc Only)のRMSE:',num2str(adaptFFTYAccError)));

[adaptFFTPPGZAccSpectrum,adaptFFTPPGZAcc]= GetSpectrumUsingFFTFilt(zAcc,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZAccPulseRate]= getHRFromSpectrumPd(adaptFFTPPGZAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTZAccPulseRate = estimateAdaptFFTZAccPulseRate * 60;
adaptFFTZAccError = sqrt(immse(estimateAdaptFFTZAccPulseRate,realHR));
disp(strcat('FFT(zAcc Only)のRMSE:',num2str(adaptFFTZAccError)));


mixedFFTAccSpectrum = zeros([size(adaptFFTPPGXAccSpectrum) 3]);
mixedFFTAccSpectrum(:,:,1) = adaptFFTPPGXAccSpectrum;
mixedFFTAccSpectrum(:,:,2) = adaptFFTPPGYAccSpectrum;
mixedFFTAccSpectrum(:,:,3) = adaptFFTPPGZAccSpectrum;

[estimateAdaptFFTTriAccPulseRate]= getHRFromMixedSpectrumsPd(mixedFFTAccSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTTriAccPulseRate = estimateAdaptFFTTriAccPulseRate * 60;
estimateAdaptFFTTriAccPulseError = sqrt(immse(estimateAdaptFFTTriAccPulseRate,realHR));
disp(strcat('FFT(Acc all Axis)のRMSE:',num2str(estimateAdaptFFTTriAccPulseError)));






[adaptFFTPPGXGyroSpectrum,adaptFFTPPGXGyro]= GetSpectrumUsingFFTFilt(xGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTXGyroPulseRate]= getHRFromSpectrumPd(adaptFFTPPGXGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTXGyroPulseRate = estimateAdaptFFTXGyroPulseRate * 60;
adaptFFTXGyroError = sqrt(immse(estimateAdaptFFTXGyroPulseRate,realHR));
disp(strcat('FFT(xGyro Only)のRMSE:',num2str(adaptFFTXGyroError)));

[adaptFFTPPGYGyroSpectrum,adaptFFTPPGYGyro]= GetSpectrumUsingFFTFilt(yGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYGyroPulseRate]= getHRFromSpectrumPd(adaptFFTPPGYGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTYGyroPulseRate = estimateAdaptFFTYGyroPulseRate * 60;
adaptFFTYGyroError = sqrt(immse(estimateAdaptFFTYGyroPulseRate,realHR));
disp(strcat('FFT(yGyro Only)のRMSE:',num2str(adaptFFTYGyroError)));

[adaptFFTPPGZGyroSpectrum,adaptFFTPPGZGyro]= GetSpectrumUsingFFTFilt(zGyro,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZGyroPulseRate]= getHRFromSpectrumPd(adaptFFTPPGZGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTZGyroPulseRate = estimateAdaptFFTZGyroPulseRate * 60;
adaptFFTZGyroError = sqrt(immse(estimateAdaptFFTZGyroPulseRate,realHR));
disp(strcat('FFT(zGyro Only)のRMSE:',num2str(adaptFFTZGyroError)));


mixedFFTGyroSpectrum = zeros([size(adaptFFTPPGXGyroSpectrum) 3]);
mixedFFTGyroSpectrum(:,:,1) = adaptFFTPPGXGyroSpectrum;
mixedFFTGyroSpectrum(:,:,2) = adaptFFTPPGYGyroSpectrum;
mixedFFTGyroSpectrum(:,:,3) = adaptFFTPPGZGyroSpectrum;

[estimateAdaptFFTTriGyroPulseRate]= getHRFromMixedSpectrumsPd(mixedFFTGyroSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTTriGyroPulseRate = estimateAdaptFFTTriGyroPulseRate * 60;
estimateAdaptFFTTriGyroPulseError = sqrt(immse(estimateAdaptFFTTriGyroPulseRate,realHR));
disp(strcat('FFT(Gyro all Axis)のRMSE:',num2str(estimateAdaptFFTTriGyroPulseError)));


[adaptFFTPPGXAngleSpectrum,adaptFFTPPGXAngle]= GetSpectrumUsingFFTFilt(rollSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTXAnglePulseRate]= getHRFromSpectrumPd(adaptFFTPPGXAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTXAnglePulseRate = estimateAdaptFFTXAnglePulseRate * 60;
adaptFFTXAngleError = sqrt(immse(estimateAdaptFFTXAnglePulseRate,realHR));
disp(strcat('FFT(Roll Only)のRMSE:',num2str(adaptFFTXAngleError)));

[adaptFFTPPGYAngleSpectrum,adaptFFTPPGYAngle]= GetSpectrumUsingFFTFilt(pitchSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTYAnglePulseRate]= getHRFromSpectrumPd(adaptFFTPPGYAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTYAnglePulseRate = estimateAdaptFFTYAnglePulseRate * 60;
adaptFFTYAngleError = sqrt(immse(estimateAdaptFFTYAnglePulseRate,realHR));
disp(strcat('FFT(Pitch Only)のRMSE:',num2str(adaptFFTYAngleError)));

[adaptFFTPPGZAngleSpectrum,adaptFFTPPGZAngle]= GetSpectrumUsingFFTFilt(yawSpeed,PPG,FFTLength,Overlap,Fs,FilterLength,FFTStepSize);
[estimateAdaptFFTZAnglePulseRate]= getHRFromSpectrumPd(adaptFFTPPGZAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTZAnglePulseRate = estimateAdaptFFTZAnglePulseRate * 60;
adaptFFTZAngleError = sqrt(immse(estimateAdaptFFTZAnglePulseRate,realHR));
disp(strcat('FFT(Yaw Only)のRMSE:',num2str(adaptFFTZAngleError)));


mixedFFTAngleSpectrum = zeros([size(adaptFFTPPGXAngleSpectrum) 3]);
mixedFFTAngleSpectrum(:,:,1) = adaptFFTPPGXAngleSpectrum;
mixedFFTAngleSpectrum(:,:,2) = adaptFFTPPGYAngleSpectrum;
mixedFFTAngleSpectrum(:,:,3) = adaptFFTPPGZAngleSpectrum;

[estimateAdaptFFTTriAnglePulseRate]= getHRFromMixedSpectrumsPd(mixedFFTAngleSpectrum,freq,freqRange,RHR,pd,percentage);
estimateAdaptFFTTriAnglePulseRate = estimateAdaptFFTTriAnglePulseRate * 60;
estimateAdaptFFTTriAnglePulseError = sqrt(immse(estimateAdaptFFTTriAnglePulseRate,realHR));
disp(strcat('FFT(Angle Speed)のRMSE:',num2str(estimateAdaptFFTTriAnglePulseError)));

