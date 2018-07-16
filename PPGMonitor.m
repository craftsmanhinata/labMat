clear;
clc;

dataDir = 'data';
dataFile = '20170111_135428_Test';

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

samplingFrequency = 100;
samplingPeriod = 1 / samplingFrequency;
pll = 8;
clock = 7.3728 * mega * pll;
samplingTime = 15 * 20 * 4 / clock / 2;
Tad = samplingTime / 15;
adcBit = 12;
operatingVoltage = 3.3;



accelerationSensitivity = 9.80665 * 0.66;
maxAcceleration = 11;

disp(strcat(dataDir,'\',dataFile,'.csv'));

adConvData = csvread(strcat(dataDir,'\',dataFile,'.csv'));
PPGSignal = adConvData(:,PPGCh) * operatingVoltage / (2 ^ adcBit - 1);
dataPoint = size(PPGSignal,1);
zeroGravity = operatingVoltage / 2 * ones(dataPoint,1);

xAcceleration = (-2 * xReverse + 1) * (adConvData(:,xAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;
yAcceleration = (-2 * yReverse + 1) * (adConvData(:,yAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;
zAcceleration = (-2 * zReverse + 1) * (adConvData(:,zAxisCh) *  operatingVoltage / (2 ^ adcBit - 1) - zeroGravity) * accelerationSensitivity;


timeAxisX = transpose(0:dataPoint-1);
timeAxisX = timeAxisX * samplingPeriod;
timeAxisY = timeAxisX + samplingPeriod / channel * (yAxisCh - 1);
timeAxisZ = timeAxisX + samplingPeriod / channel * (zAxisCh - 1);
timeAxisPPG = timeAxisX + samplingPeriod / channel * (PPGCh - 1);

figure('Name','Signal','NumberTitle','off');
subplot(4,1,1);plot(timeAxisX,xAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('XAxisAcceleration');
grid on;
grid minor;
subplot(4,1,2);plot(timeAxisY,yAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('YAxisAcceleration');
grid on;
grid minor;
subplot(4,1,3);plot(timeAxisZ,zAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('ZAxisAcceleration');
grid on;
grid minor;
subplot(4,1,4);plot(timeAxisPPG,PPGSignal);
xlabel('Time(s)');
ylabel('PPG Signal(a.u.)');
ylim([0 operatingVoltage]);
title('PPG');
grid on;
grid minor;



