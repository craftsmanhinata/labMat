%close all;
clear();
clc();
%load('C:\Users\toragouf\Downloads\MATLAB\MATLAB\FilterDesign\Data\resWave.mat')

Fs = 50;
Ts = 1 / Fs;
fc = 1; %unit:[Hz]

EMGFolder = 'ECG\';
fileNameEMG = '0001~aa~0628.csv';
EMGData = csvread(strcat(EMGFolder,fileNameEMG));
EMG = EMGData(:,2);
EMGFs = 1000;
dEMG = decimate(EMG,(EMGFs/Fs));

EMGTime = (0:1:length(dEMG)-1)'*Ts;
[EMGTime,dEMG] = trimSig(EMGTime,dEMG,1,181);

figure();
subplot(2,1,1);
plot(EMGTime,dEMG);
hold on;
set(gca,'FontSize',40);

xlabel('Time[sec.]','FontSize',40);
ylabel('Voltage[mV]','FontSize',40);
title('EMG Signal','FontSize',40);
[EMGpks,EMGlocs] = findpeaks(dEMG,EMGTime,'MinPeakHeight',0.02);
xlim([0 80]);
% delIndex = [5,18,25,32];
% EMGpks = arrayEleDel(EMGpks,delIndex);
% EMGlocs = arrayEleDel(EMGlocs,delIndex);

% delIndex = [3,6,19,32,45,52,69,78,83,90,95,104,107,...
%     110,113,118,123,132,145,160,165,166,205,216,...
%     227,238,265,274,281,300,323,358,401,416];
% 
% EMGpks = arrayEleDel(EMGpks,delIndex);
% EMGlocs = arrayEleDel(EMGlocs,delIndex);
[EMGlocs,EMGpks]= evenDel(EMGlocs,EMGpks);

plot(EMGlocs,EMGpks,'b*');




[diffEMGPks,anomalyEMGPoint,anomalyEMGLocs] = diffPeakAnomalyDetect(EMGpks,EMGlocs,1.5);
plot(anomalyEMGLocs,anomalyEMGPoint,'ro');


PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

fhc = 3; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.3;
NFlc = flc/(Fs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 1.1;
lowFreqMargin = 1.16;
Ap = 1.0;

D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
FilteredPPG = filtfilt(Hd.numerator,1,PPG);



subplot(2,1,2);
plot(PPGTime,FilteredPPG);
hold on;
title('PPG Signal','FontSize',40);
xlabel('Time[sec.]','FontSize',40);
ylabel('PPG [a.u.]','FontSize',40);
xlim([0 80]);

set(gca,'FontSize',40);


[PPGpks,PPGlocs] = findpeaks(1*FilteredPPG,PPGTime,'MinPeakDistance',0.5);
plot(PPGlocs,1*PPGpks,'b*');
[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGpks,PPGlocs,1.2);

[R,P,D]=movingCorrcoef(diffPPGPks,diffEMGPks);
figure();
plot(2:1:length(diffEMGPks)+1,diffEMGPks);
hold on;
alignedPPG = diffPPGPks(D:D+length(diffEMGPks)-1);
ylabel('RR Interval(sec.)','FontSize',40);
xlabel('Pulse count','FontSize',40);
leftYLim = ylim;
yyaxis right;
plot(2:1:length(alignedPPG)+1,alignedPPG);
ylabel('Pulse Interval(sec.)','FontSize',40);
ylim(leftYLim);
legend({'RRI calculated from ECG','Pulse Interval calculated from PPG'},'FontSize',40);
set(gca,'FontSize',40);
xlim([2 210]);
figure();
histogram(alignedPPG - diffEMGPks);

% fvtool(Hd,'Fs',Fs);
% 
% figure();
% plot(PPGTime,timeArray2);
% [timeArray2Pks,timeArray2Locs] = findpeaks(timeArray2,PPGTime,'MinPeakDistance',0.5);
% hold on;
% plot(timeArray2Locs,timeArray2Pks,'b*');
% [diffTimeArrayPPGPks,anomalyTimeArrayPPGPoint,anomalyTimeArrayPPGLocs] = diffPeakAnomalyDetect(timeArray2Pks,timeArray2Locs,1.2);
% plot(anomalyTimeArrayPPGLocs,anomalyTimeArrayPPGPoint,'ro');
% [R,P,D]=movingCorrcoef(diffTimeArrayPPGPks,diffEMGPks);



% timeError = diffEMGPks - alignedPPG;
% figure();
% histfit(timeError);
% [TimeNoiseMuhat,TimeNoiseSigmahat] = normfit(timeError);
% 
% NoiseFolder = 'Out\';
% fileNameNoise = '20180629_143424_Test_Res.csv';
% NoiseData = csvread(strcat(PPGFolder,fileNameNoise));
% Noise = NoiseData(:,1);
% 
% Noise = -1 * Noise;
% figure();
% histfit(Noise);
% [signalNoiseMuhat,signalNoiseSigmahat] = normfit(Noise);
% sampleIndex = randsample(length(Noise),length(timeError));
% newNoise = zeros(length(timeError),1);
% 
% for index = 1 : length(newNoise)
%     newNoise(index) = Noise(sampleIndex(index));
% end
% C = cov(timeError,newNoise);
% load('data2.mat')
% t = (0:1:length(particleFilteredPPG)-1)'*Ts;
% v = particleFilteredPPG;
% figure();
% plot(t,v);
% hold on;
% [Vpks,Tlocs] = findpeaks(v,t,'MinPeakDistance',0.5);
% [diffVPks,anomalyVPoint,anomalyTLocs] = diffPeakAnomalyDetect(Vpks,Tlocs,1.2);
% 
% plot(Tlocs,Vpks,'b*');
% plot(PPGTime,FilteredPPG);
% 
% 
% [R,P,D]=movingCorrcoef(diffVPks,diffEMGPks);
% figure();
% plot(2:1:length(diffEMGPks)+1,diffEMGPks);
% hold on;
% if (D+length(diffEMGPks)-1) >= length(diffVPks)
%     alignedV = diffVPks(D:end);
% else
%     alignedV = diffVPks(D:D+length(diffEMGPks)-1);
% end
% ylabel('RR Interval(sec)');
% xlabel('pulse count');
% leftYLim = ylim;
% yyaxis right;
% plot(2:1:length(alignedV)+1,alignedV);
% ylabel('Pulse Interval(sec)');
% ylim(leftYLim);
% legend({'RRI value from ECG','PI value from PPG'},'FontSize',10);
% 
% figure();
% cwt(FilteredPPG,'morse',50,'FrequencyLimits',[0.1 1.5],'VoicesPerOctave',48);
% figure();
% cwt(particleFilteredPPG,'morse',50,'FrequencyLimits',[0.1 1.5],'VoicesPerOctave',48);