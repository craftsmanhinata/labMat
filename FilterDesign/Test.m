close all;
clear();
clc();

Fs = 50;
Ts = 1/Fs;
% point = 1000;
% time = (0:1:point-1)'*Ts;
% 
% sinFreq1 = 1;
% demoData = sin(2*pi*sinFreq1*time);
% window = figure();
% [diffData,diffTime] = myDiff(demoData,time,5,true);
% plot(time,demoData);
% hold on;
% plot(diffTime,diffData);
% 
% oldIndex = 1;
% for index = 1:length(diffData)
%     [signChanged,oldSigIsPlus] = detectSignChange(diffData(1:index));
%     if signChanged && oldSigIsPlus
%         figure(window);
%         hold on;
%         plot(diffTime(index),diffData(index),'*');
%         drawWindow(time,demoData,window,diffTime(oldIndex),diffTime(index));
%         figure();
%         title('1 frame');
%         plot(time(oldIndex:index),demoData(oldIndex:index));
%         oldIndex = index;
%     end
% end
% 
close all;

PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

fhc = 3; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.7;
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
[diffPPGData,diffPPGTime] = myDiff(PPG,PPGTime,1.1,true);

window2 = figure();
plot(PPGTime,PPG);
yyaxis right;
hold on;
plot(diffPPGTime,diffPPGData);
yyaxis left;

oldIndex = 1;
timeIndex = 1;

for index = 1:length(diffPPGData)
    [signChanged,oldSigIsPlus] = detectSignChange(diffPPGData(1:index));
    if signChanged && oldSigIsPlus
        figure(window2);
        hold on;
        plot(diffPPGTime(index),diffPPGData(index),'*');
        drawWindow(PPGTime,PPG,window2,diffPPGTime(oldIndex),diffPPGTime(index));
        freqTime(timeIndex) = oldIndex;
        timeIndex = timeIndex + 1;
        %figure();
        %title('1 frame');
        %plot(PPGTime(oldIndex:index),PPG(oldIndex:index));
        oldIndex = index;
        if timeIndex > 2
            break;
        end
    end
end
states = stateMake(freqTime(2),PPGTime,PPG);
errors = collectErrorRateFromStates(states);
errorArray = errorsMatToArray(errors);
[histCount,~] = histcounts(errorArray);
rng default;
figure();
histfit(errorArray,length(histCount),'kernel');
pd = fitdist(errorArray,'Kernel');
particleNum = 100;
estimateStates = myParticleFilt(states,particleNum/2,particleNum);
[t,v] = stateMatToArray(estimateStates);
figure();
plot(t,v);
particleFilteredPPG = filtfilt(Hd.numerator,1,v);
