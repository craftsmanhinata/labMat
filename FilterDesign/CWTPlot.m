close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'Out\';
fileNamePPG = '20180709_180616_Test_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG))';
PPGTime = (0:1:length(PPGData)-1)'*Ts;
figure();
for index = 1:4
    subplot(4,1,index);
    plot(PPGTime,PPGData(index,:)');
    hold on;
end
cwtTimeBandWidth = 3.1;
cwtVoicesPerOctave = 48;

for index = 1:4
    figure();
    cwt(PPGData(index,:),'morse',Fs,'TimeBandwidth',cwtTimeBandWidth,'VoicesPerOctave',cwtVoicesPerOctave,'FrequencyLimits',[0.7 3]);
end