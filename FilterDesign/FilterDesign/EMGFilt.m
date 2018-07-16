clear();
clc();
close all;
Fs = 50;
Ts = 1 / Fs;
fhc = 4; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.5;
NFlc = flc/(Fs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 1.1;
lowFreqMargin = 1.2;
Ap = 1.0;

EMGFolder = 'ECG\';
fileNameEMG = '0001~aa~20180626.csv';
EMGData = csvread(strcat(EMGFolder,fileNameEMG));
EMG = EMGData(:,2);
EMGFs = 1000;
dEMG = decimate(EMG,EMGFs / (Fs));


D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
%filt = designfilt('bandpassiir','FilterOrder',10,'HalfPowerFrequency1',flc,'HalfPowerFrequency2',fhc,'SampleRate',Fs);
%fvtool(filt);


dFilteredEMG = filtfilt (Hd.numerator,1,dEMG);
EMGTime = (0:1:length(dEMG)-1)'*Ts;

[EMGpks,EMGlocs] = findpeaks(dFilteredEMG,Fs,'MinPeakDistance',0.56);
[OrigEMGpks,OrigEMGlocs] = findpeaks(dEMG,Fs,'MinPeakDistance',0.56);


plot(EMGTime,dFilteredEMG);

hold on;

plot(EMGlocs,EMGpks,'b*');
hold on;


% plot(OrigEMGlocs,OrigEMGpks,'b*');


xlabel('Time[sec]');
ylabel('Voltage[mV]');

title('EMG Signal');

hold on;
plot(EMGTime,dEMG);
hold on;
plot(OrigEMGlocs,OrigEMGpks,'r*');

diffEMGlocs = diff(EMGlocs);
figure();
plot(EMGlocs(2:end),diffEMGlocs);
diffOrigEMGlocs = diff(OrigEMGlocs);



%[alignedEMG,aligedOrigEMG] = forceAligned(EMGlocs,OrigEMGlocs);
%c = xcorr(alignedEMG-mean(alignedEMG),aligedOrigEMG-mean(aligedOrigEMG),'coef');

f_EMG = fit(EMGlocs(2:end),diffEMGlocs,'smoothingspline');
figure();
plot(EMGTime,f_EMG(EMGTime));
hold on;
plot(EMGlocs(2:end),diffEMGlocs);
% figure();
% cwt(dEMG,'morse',Fs,'TimeBandwidth',120,'VoicesPerOctave',48);
% corrcoef(EMGlocs,OrigEMGlocs)

% [h,p,name] = autoTest(OrigEMGlocs);
% figure();
% histogram(OrigEMGlocs);
% z = hilbert(dFilteredEMG);
% [diffFilteredEMG,diffTime] = diffFiltering(unwrap(angle(z)),EMGTime,NFhc,NFhc*highFreqMargin,Ap,-1*minResVoldb);
% diffFilteredEMG = diffFilteredEMG / (2 * pi);
