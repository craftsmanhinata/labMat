clear;
clc;

dataDir = 'data';
dataFile = '20170202_154555_Test';

mega    = 10 ^ 6;
kilo    = 10 ^ 6;
mill    = 10 ^ -3;
nano    = 10 ^ -9;

xReverse = false;
yReverse = false;
zReverse = false;


xAxisCh = 1;
yAxisCh = 2;
zAxisCh = 3;
PPGCh = 4;
channel = 4;

graphHold = true;


pll = 8;
clock = 7.3728 * mega * pll;
samplingTime = 15 * 20 * 4 / clock / 2;
Tad = samplingTime / 15;
samplingPeriod = 4 / clock * 256 * 144 * channel;
samplingFrequency = 1 / samplingPeriod;
adcBit = 12;
operatingVoltage = 3.3;


accelerationSensitivity = 9.80665 * 0.66;
maxAcceleration = 11;

disp(strcat(dataDir,'\',dataFile,'.csv'));

adConvData = csvread(strcat(dataDir,'\',dataFile,'.csv'));
PPG = adConvData(:,PPGCh) * operatingVoltage / (2 ^ adcBit - 1);
dataPoint = size(PPG,1);
zeroGravity = operatingVoltage / 2 * ones(dataPoint,1);

xAcceleration = (-2 * xReverse + 1) * (adConvData(:,xAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;
yAcceleration = (-2 * yReverse + 1) * (adConvData(:,yAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;
zAcceleration = (-2 * zReverse + 1) * (adConvData(:,zAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;


timeAxisX = transpose(0:dataPoint-1);
timeAxisX = timeAxisX * samplingPeriod;
timeAxisY = timeAxisX + samplingPeriod / channel * (yAxisCh - 1);
timeAxisZ = timeAxisX + samplingPeriod / channel * (zAxisCh - 1);
timeAxisPPG = timeAxisX + samplingPeriod / channel * (PPGCh - 1);






startPoint = 1;
endPoint = 6000;


focusPoint = transpose(startPoint:endPoint);

focusPPG = PPG(focusPoint,:);
focusPPGTime = timeAxisPPG(focusPoint,:);
focusXAcceleration = xAcceleration(focusPoint,:);
focusXTime = timeAxisX(focusPoint,:);
focusYAcceleration = yAcceleration(focusPoint,:);
focusYTime = timeAxisY(focusPoint,:);
focusZAcceleration = zAcceleration(focusPoint,:);
focusZTime = timeAxisZ(focusPoint,:);

detrendPPG = detrend(focusPPG);
diffFocusPPG = diff(detrendPPG);

figure('Name','TrendPPGSignal','NumberTitle','off');
plot(focusPPGTime,focusPPG);
xlabel('Time(s)');
ylabel('PPG Signal(a.u.)');
title('PPG');
grid on;
grid minor;

