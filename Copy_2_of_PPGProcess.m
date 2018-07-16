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

%{
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
subplot(4,1,4);plot(timeAxisPPG,PPG);
xlabel('Time(s)');
ylabel('PPG Signal(a.u.)');
ylim([0 operatingVoltage]);
title('PPG');
grid on;
grid minor;
%}

%{
startPoint = 8301;
endPoint = 11341;
%}


startPoint = 1;
endPoint = dataPoint;


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
yyaxis left;
plot(focusPPGTime,detrendPPG);
xlabel('Time(s)');
ylabel('PPG Signal(a.u.)');
title('PPG');
grid on;
grid minor;
yyaxis right;


plot(focusXTime,focusXAcceleration,'-');


hold on;
%plot(focusYTime,focusYAcceleration,'g-');
%plot(focusZTime,focusZAcceleration,'k-');

ylim([-1*maxAcceleration maxAcceleration]);
ylabel('Acceleration(m/s^2)');

%Positive Peak Detection
[xPeaks,xPeakPoint] = findpeaks(focusXAcceleration,focusXTime,'MinPeakProminence',4);
[yPeaks,yPeakPoint] = findpeaks(focusYAcceleration,focusYTime,'MinPeakProminence',4);
[zPeaks,zPeakPoint] = findpeaks(focusZAcceleration,focusZTime,'MinPeakProminence',4);
%Negative Peak Detection
[xNegPeaks,xNegPeakPoint] = findpeaks(-focusXAcceleration,focusXTime,'MinPeakProminence',4);
[yNegPeaks,yNegPeakPoint] = findpeaks(-focusYAcceleration,focusYTime,'MinPeakProminence',4);
[zNegPeaks,zNegPeakPoint] = findpeaks(-focusZAcceleration,focusZTime,'MinPeakProminence',4);

peakPointPPGTimeIndex = ceil( (xPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod);
peakPointPPGTimeIndex = vertcat(peakPointPPGTimeIndex,ceil( (yPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod));
peakPointPPGTimeIndex = vertcat(peakPointPPGTimeIndex,ceil( (zPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod));
peakPointPPGTimeIndex = vertcat(peakPointPPGTimeIndex,ceil( (xNegPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod));
peakPointPPGTimeIndex = vertcat(peakPointPPGTimeIndex,ceil( (yNegPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod));
peakPointPPGTimeIndex = vertcat(peakPointPPGTimeIndex,ceil( (zNegPeakPoint+ samplingPeriod / channel * (PPGCh - 1)) / samplingPeriod));
peakPointPPGTimeIndex = sort(peakPointPPGTimeIndex);

peakPointPPGTimeIndex = peakPointPPGTimeIndex - startPoint + 1;

text(xPeakPoint,xPeaks,'Åõ');
text(xNegPeakPoint,-xNegPeaks,'Åõ');



figure('Name','AccSignals','NumberTitle','off');
subplot(3,1,1);plot(focusXTime,focusXAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('XAxisAcceleration');
grid on;
grid minor;
text(xPeakPoint,xPeaks,'Åõ','FontSize',5);
text(xNegPeakPoint,-xNegPeaks,'Åõ','FontSize',5);
subplot(3,1,2);plot(focusYTime,focusYAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('YAxisAcceleration');
grid on;
grid minor;
text(yPeakPoint,yPeaks,'Åõ','FontSize',5);
text(yNegPeakPoint,-yNegPeaks,'Åõ','FontSize',5);
subplot(3,1,3);plot(focusZTime,focusZAcceleration);
xlabel('Time(s)');
ylabel('Acceleration(m/s^2)');
ylim([-1*maxAcceleration maxAcceleration]);
title('ZAxisAcceleration');
grid on;
grid minor;
text(zPeakPoint,zPeaks,'Åõ','FontSize',5);
text(zNegPeakPoint,-zNegPeaks,'Åõ','FontSize',5);


l = 1;
for k = 1:size(peakPointPPGTimeIndex)
   if peakPointPPGTimeIndex(k)-1 ~= 0
        if diffFocusPPG(peakPointPPGTimeIndex(k)-1) < 0
           diffPeakPointPPGTimeIndex(l,:) = peakPointPPGTimeIndex(k) - 1;
           peakPointPPG(l,:) = detrendPPG(peakPointPPGTimeIndex(k));
           peakPointPPGTime(l,:) = focusPPGTime(peakPointPPGTimeIndex(k));
           l = l + 1;
        end
   end
end



timeLimit = 5/7;

processedPPG = detrendPPG;
processEndPoint = 0;
for k = 1 : size(diffPeakPointPPGTimeIndex)
    if diffPeakPointPPGTimeIndex(k) > processEndPoint
        processEndPoint = ceil((focusPPGTime(diffPeakPointPPGTimeIndex(k)) + timeLimit) / samplingPeriod) - startPoint + 1;
        for l = diffPeakPointPPGTimeIndex(k) : processEndPoint
            processedPPG(l) = peakPointPPG(k) + diffFocusPPG(diffPeakPointPPGTimeIndex(k)) .*  (l - diffPeakPointPPGTimeIndex(k) );
        end
    end
end


maxProcessedPPG = max(processedPPG);
shift = operatingVoltage - maxProcessedPPG;

for k = 1 : size(processedPPG,1)
    processedPPG(k) = processedPPG(k) + shift;
    if processedPPG(k) < 0
        processedPPG(k) = 0;
    end
end

figure('Name','ProcessedPPGSignal','NumberTitle','off');
plot(focusPPGTime,processedPPG);
hold on;
%plot(focusPPGTime,focusPPG,'--');
%plot(focusPPGTime,detrendPPG);

xlabel('Time(s)');
ylabel('PPG Signal(a.u.)');
title('ProcessedPPG');
grid on;
grid minor;
%grid minor;
[processedPPGPeaks,processedPPGPeakPoints] = findpeaks(processedPPG,focusPPGTime,'MinPeakProminence',1);
%text(processedPPGPeakPoints,processedPPGPeaks,'P');
[originPPGPeaks,originPPGPeakPoints] = findpeaks(focusPPG,focusPPGTime,'MinPeakProminence',1);
%text(originPPGPeakPoints,originPPGPeaks,'A');
[detrendPPGPeaks,detrendPPGPeakPoints] = findpeaks(detrendPPG,focusPPGTime,'MinPeakProminence',1);
%text(detrendPPGPeakPoints,detrendPPGPeaks,'P');
%legend({'ProcessedSignal','RawSignal'},'FontSize',18);


processedPPGInterval = diff(processedPPGPeakPoints)*60;
originPPGInterval = diff(originPPGPeakPoints)*60;
detrendPPGInterval = diff(detrendPPGPeakPoints)*60;
processedPPGPeakPoints(size(processedPPGPeakPoints,1),:) = [];
originPPGPeakPoints(size(originPPGPeakPoints,1),:) = [];
detrendPPGPeakPoints(size(detrendPPGPeakPoints,1),:) = [];
figure('Name','PeakInterval','NumberTitle','off');
plot(processedPPGPeakPoints,processedPPGInterval,'LineWidth',2,'Marker','o','MarkerSize',10);
hold on;
plot(originPPGPeakPoints,originPPGInterval,'--^','LineWidth',2,'MarkerSize',10);
%plot(detrendPPGPeakPoints,detrendPPGInterval,'LineWidth',2,'Marker','square','MarkerSize',10);
grid on;
xlabel({'Time(s)'},'FontSize',16);
ylabel({'PulseRate(pulse/minute)'},'FontSize',16);
title({'PulseRateDetection'},'FontSize',20);
%legend({'ProcessedSignal','RawSignal','TrendRemovedSignal'},'FontSize',18);
legend({'ProcessedSignal','RawSignal'},'FontSize',18);




