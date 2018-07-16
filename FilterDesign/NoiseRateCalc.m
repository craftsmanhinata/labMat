close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'Out\';
fileNamePPG = '20180629_143424_Test_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

PPG = -1 * PPG;
histfit(PPG);
[muhat,sigmahat] = normfit(PPG);
xlim([-0.05 0.05]);