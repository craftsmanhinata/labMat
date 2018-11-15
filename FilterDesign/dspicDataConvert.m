close all;
clear();
clc();


fileName = '20181114_170553_GAIN100';
srcFolderName = '.\Data\';
dstFolderName = '.\Out\';
fileExtension = '.csv';

saveName = strcat(fileName,'_Res');

srcData = readtable(strcat(srcFolderName,fileName,fileExtension),'Delimiter',',','Format','%s%s%s%s%s%s%s');

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

xGyro = srcData(:,5);
xGyro = string(table2array(xGyro));
xGyro = hex2Mathex(xGyro);
xGyro = double(typecast(uint16(base2dec(xGyro,16)),'int16'));

yGyro = srcData(:,6);
yGyro = string(table2array(yGyro));
yGyro = hex2Mathex(yGyro);
yGyro = double(typecast(uint16(base2dec(yGyro,16)),'int16'));


zGyro = srcData(:,7);
zGyro = string(table2array(zGyro));
zGyro = hex2Mathex(zGyro);
zGyro = double(typecast(uint16(base2dec(zGyro,16)),'int16'));



accCoeff = 9.80665;
gReso = 4;

xAccOffset =  20;
yAccOffset = -40;
zAccOffset = 150;

xAcc = (xAcc - xAccOffset)*accCoeff/1000;
yAcc = (yAcc - yAccOffset)*accCoeff/1000;
zAcc = (zAcc - zAccOffset)*accCoeff/1000;

gyroRange = 500;
gyroCoeff = 1;
switch gyroRange
    case 245
        gyroCoeff = 8.75;
    case 500
        gyroCoeff = 17.5;
    case 2000
        gyroCoeff = 70;
end

xGyro = deg2rad(xGyro * gyroCoeff / 1000);
yGyro = deg2rad(yGyro * gyroCoeff / 1000);
zGyro = deg2rad(zGyro * gyroCoeff / 1000);

Fs = 50;
Ts = 1/Fs;
time = (0:1:height(srcData)-1)';
time = Ts * time;


figure();
subplot(7,1,1);
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
ylim([-1,1]);


subplot(7,1,2);
plot(time,xAcc);
title('X Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);

subplot(7,1,3);
plot(time,yAcc);
title('Y Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/s^2]');
ylim([-gReso*accCoeff,gReso*accCoeff]);

subplot(7,1,4);
plot(time,zAcc);
title('Z Acc Signal');
xlabel('Time[sec]');
ylabel('Acc [m/{s^{2}}]');
ylim([-gReso*accCoeff,gReso*accCoeff]);

subplot(7,1,5);
plot(time,xGyro);
title('X Gyro Signal');
xlabel('Time[sec]');
ylabel('Angular velocity [rad/s]');
ylim([deg2rad(-gyroRange*gyroCoeff),deg2rad(gyroRange*gyroCoeff)]);


subplot(7,1,6);
plot(time,yGyro);
title('Y Gyro Signal');
xlabel('Time[sec]');
ylabel('Angular velocity [rad/s]');
ylim([deg2rad(-gyroRange*gyroCoeff),deg2rad(gyroRange*gyroCoeff)]);


subplot(7,1,7);
plot(time,zGyro);
title('Z Gyro Signal');
xlabel('Time[sec]');
ylabel('Angular velocity [rad/s]');
ylim([deg2rad(-gyroRange*gyroCoeff),deg2rad(gyroRange*gyroCoeff)]);


dstData = ones(height(srcData),7);
dstData(:,1) = PPGSig;
dstData(:,2) = xAcc;
dstData(:,3) = yAcc;
dstData(:,4) = zAcc;
dstData(:,5) = xGyro;
dstData(:,6) = yGyro;
dstData(:,7) = zGyro;

csvwrite(strcat(dstFolderName,saveName,fileExtension),dstData);



% figure();
% resWave = cwtPeakDetect(PPGSig,Fs,0.1,10,true,10,10,false);
% figure();
% plot(time,resWave);
% hold on;
% plot(time,PPGSig);

FFTautoPlot(PPGSig,Fs);