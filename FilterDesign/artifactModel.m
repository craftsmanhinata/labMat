close all;
clear();
clc();


fileName = '20180712_150736_Test';
srcFolderName = '.\Data\';
dstFolderName = '.\Out\';
fileExtension = '.csv';

saveName = strcat(fileName,'_Noise');

srcData = readtable(strcat(srcFolderName,fileName,fileExtension),'Delimiter',',','Format','%s%s%s%s');

PPGSig  = srcData(:,1);
PPGSig  = string(table2array(PPGSig));
PPGSig  = hex2Mathex(PPGSig);
PPGSig  = str2Fract(PPGSig);
PPGSig  = PPGSig.double * -1;

xAcc = srcData(:,2);
xAcc = string(table2array(xAcc));
xAcc = hex2Mathex(xAcc);
xAcc = double(typecast(uint16(base2dec(xAcc,16)),'int16'));

yAcc = srcData(:,3);
yAcc = string(table2array(yAcc));
yAcc = hex2Mathex(yAcc);
yAcc = double(typecast(uint16(base2dec(yAcc,16)),'int16'));

zAcc = srcData(:,4);
zAcc = string(table2array(zAcc));
zAcc = hex2Mathex(zAcc);
zAcc = double(typecast(uint16(base2dec(zAcc,16)),'int16'));

accCoeff = 9.80665;
gReso = 4;

xAccOffset =  20;
yAccOffset = -40;
zAccOffset = 150;

xAcc = (xAcc - xAccOffset)*accCoeff/1000;
yAcc = (yAcc - yAccOffset)*accCoeff/1000;
zAcc = (zAcc - zAccOffset)*accCoeff/1000;

Fs = 50;
Ts = 1/Fs;
time = (0:1:height(srcData)-1)';
time = Ts * time;


figure();
subplot(4,1,1);
plot(time,PPGSig);
hold on;
[PPGpks,PPGlocs] = findpeaks(PPGSig,Fs,'MinPeakDistance',0.7);
plot(PPGlocs,PPGpks,'b*');
[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGpks,PPGlocs,1.5);
hold on;
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');

title('PPG Signal');
xlabel('Time[sec]');
ylabel('PPG [a.u.]');


subplot(4,1,2);
plot(time,xAcc);
title('X Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);

subplot(4,1,3);
plot(time,yAcc);
title('Y Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);

subplot(4,1,4);
plot(time,zAcc);
title('Z Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/{s^{2}}]');
ylim([-gReso*accCoeff,gReso*accCoeff]);
[~,PPGSig] = trimSig(time,PPGSig,0,180);
[~,xAcc] = trimSig(time,xAcc,0,180);
[~,yAcc] = trimSig(time,yAcc,0,180);
[time,zAcc] = trimSig(time,zAcc,0,180);

dstData = ones(length(time),4);
dstData(:,1) = PPGSig;
dstData(:,2) = xAcc;
dstData(:,3) = yAcc;
dstData(:,4) = zAcc;
csvwrite(strcat(dstFolderName,saveName,fileExtension),dstData);


% figure();
% resWave = cwtPeakDetect(PPGSig,Fs,0.1,10,true,10,10,false);
% figure();
% plot(time,resWave);
% hold on;
% plot(time,PPGSig);

FFTautoPlot(PPGSig,Fs);