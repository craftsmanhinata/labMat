%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す
close all;
clear();
clc();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '2018111702_stay.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);
ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));

dECGTime = (0:1:length(dECG)-1)'*Ts;

figure();
subplot(2,1,1);
plot(dECGTime,dECG);
hold on;

set(gca,'FontSize',40);

[dECGPks,dECGPksTime] = findpeaks(dECG,dECGTime,'MinPeakHeight',20,'MinPeakDistance',0.3);
plot(dECGPksTime,dECGPks,'ko');



[dRRI,anomalydECGPoint,anomalydECGLocs] = diffPeakAnomalyDetect(dECGPks,dECGPksTime,1.5);
plot(anomalydECGLocs,anomalydECGPoint,'ro');

PPGFolder = 'PPG\';
fileNamePPG = '20181117_204639_DataStay2_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

fhc = 1; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.1;
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
% 
D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
PPG = filtfilt(Hd.numerator,1,PPG);

if PPGInvOn
    PPG = PPG * -1;
end
% PPGSig = filter(Hd,PPGSig);

subplot(2,1,2);
plot(PPGTime,PPG);

[PPGPks,PPGPksTime] = findpeaks(PPG,PPGTime,'MinPeakDistance',min(dRRI)*0.9);
hold on;
set(gca,'FontSize',40);
plot(PPGPksTime,PPGPks,'ko');
[PI,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGPks,PPGPksTime,1.5);
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');

disp(strcat('秒差:',num2str(abs(length(dECG)-length(PPG))*Ts)));

[AlignedRRI,AlignedPI] = forceAligned(dRRI,PI);
figure();
plot(AlignedRRI);
hold on;
plot(AlignedPI);
[R,P] = corrcoef(AlignedRRI,AlignedPI);
disp(strcat('相関係数:',num2str(R(1,2))));


[R,P,D]=movingCorrcoef(PI,dRRI);
disp(strcat('movingによる相関係数:',num2str(R(1,2))));

% figure();
% plot(2:1:length(dRRI)+1,dRRI);
% hold on;
% alignedPI = PI(D:D+length(dRRI)-1);
% ylabel('RR Interval(sec.)','FontSize',40);
% xlabel('Pulse count','FontSize',40);
% leftYLim = ylim;
% yyaxis right;
% plot(2:1:length(alignedPI)+1,alignedPI);
% ylabel('Pulse Interval(sec.)','FontSize',40);
% ylim(leftYLim);
% legend({'RRI calculated from ECG','Pulse Interval calculated from PPG'},'FontSize',40);
% set(gca,'FontSize',40);