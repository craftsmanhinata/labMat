clc;
close all;
clear();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'PPG\';
fileNamePPG = '20181207AngleRecord02_Res.csv';
procTime = 180;

PPGData = csvread(strcat(PPGFolder,fileNamePPG));
xAcc = PPGData(:,2);
xAcc = trimSig(xAcc,Fs,procTime);
yAcc = PPGData(:,3);
yAcc = trimSig(yAcc,Fs,procTime);
zAcc = PPGData(:,4);
zAcc = trimSig(zAcc,Fs,procTime);

xGyro = PPGData(:,5);
xGyro = trimSig(xGyro,Fs,procTime);
yGyro = PPGData(:,6);
yGyro = trimSig(yGyro,Fs,procTime);
zGyro = PPGData(:,7);
zGyro = trimSig(zGyro,Fs,procTime);

xAngleFromGyro = angleSpeedIntegral(xGyro,Fs);
yAngleFromGyro = angleSpeedIntegral(yGyro,Fs);
zAngleFromGyro = angleSpeedIntegral(zGyro,Fs);

[xAngleFromAcc,yAngleFromAcc,zAngleFromAcc] = calcAngleFromAcc(xAcc,yAcc,zAcc);

filterOrder = 2900;

minCutoffFreq = 0.1;
maxCutoffFreq = 3.0;
cutoffArraySize = 100;
cutoffFreqArray = logspace(log10(minCutoffFreq),log10(maxCutoffFreq),cutoffArraySize);
time = (0:1:length(xAcc)-1)*Ts;

axisNum = 3;

XAngleRippleArray = zeros(size(cutoffFreqArray));
YAngleRippleArray = zeros(size(cutoffFreqArray));
ZAngleRippleArray = zeros(size(cutoffFreqArray));
AngleRippleArray = zeros(size(cutoffFreqArray));

for cutoffIndex = 1: cutoffArraySize
    highXPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'high');
    lowXPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'low');

    highYPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'high');
    lowYPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'low');

    highZPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'high');
    lowZPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'low');

    FilteredXAngleFromAcc  = filtfilt(lowXPass,1,xAngleFromAcc);
    FilteredXAngleFromGyro = filtfilt(highXPass,1,xAngleFromGyro);
    FilteredYAngleFromAcc  = filtfilt(lowYPass,1,yAngleFromAcc);
    FilteredYAngleFromGyro = filtfilt(highYPass,1,yAngleFromGyro);
    FilteredZAngleFromAcc  = filtfilt(lowZPass,1,zAngleFromAcc);
    FilteredZAngleFromGyro = filtfilt(highZPass,1,zAngleFromGyro);

    XAngle = FilteredXAngleFromAcc + FilteredXAngleFromGyro';
    YAngle = FilteredYAngleFromAcc + FilteredYAngleFromGyro';
    ZAngle = FilteredZAngleFromAcc + FilteredZAngleFromGyro';

    XAngleDeg = rad2deg(XAngle);
    YAngleDeg = rad2deg(YAngle);
    ZAngleDeg = rad2deg(ZAngle);
    
    meanXAngleDeg = mean(XAngleDeg);
    meanYAngleDeg = mean(YAngleDeg);
    meanZAngleDeg = mean(ZAngleDeg);
    meanXAngleDeg = repmat(meanXAngleDeg,size(FilteredXAngleFromAcc));
    meanYAngleDeg = repmat(meanYAngleDeg,size(FilteredYAngleFromAcc));
    meanZAngleDeg = repmat(meanZAngleDeg,size(FilteredZAngleFromAcc));
    
    xAngleRipple = rms(XAngleDeg);
    yAngleRipple = rms(YAngleDeg);
    zAngleRipple = rms(ZAngleDeg);
    
    XAngleRippleArray(cutoffIndex) = mean(xAngleRipple ./ meanXAngleDeg);
    YAngleRippleArray(cutoffIndex) = mean(yAngleRipple ./ meanYAngleDeg);
    ZAngleRippleArray(cutoffIndex) = mean(zAngleRipple ./ meanZAngleDeg);
    AngleRippleArray(cutoffIndex) = mean([xAngleRipple yAngleRipple zAngleRipple]);

    disp(strcat('cufoffFrq:',num2str(cutoffFreqArray(cutoffIndex))));
    
    disp(strcat('XAngleRipple:',num2str(xAngleRipple)));
    disp(strcat('YAngleRipple:',num2str(yAngleRipple)));
    disp(strcat('ZAngleRipple:',num2str(zAngleRipple)));
    disp(strcat('AngleMeanRipple:',num2str(AngleRippleArray(cutoffIndex))));
    
    figure();
    plot(time,XAngleDeg);
    hold on;
    plot(time,YAngleDeg);
    plot(time,ZAngleDeg);
    line(time,meanXAngleDeg,'Color','black','LineStyle','--');
    line(time,meanYAngleDeg,'Color','black','LineStyle','--');
    line(time,meanZAngleDeg,'Color','black','LineStyle','--');
    legend('XAngle','YAngle','ZAngle');
    ylabel('Degree');
    xlabel('time(sec.)');
    title(strcat('cutoffFreq;',num2str(cutoffFreqArray(cutoffIndex)),'Hz'));
    
    figure();
    subplot(2,1,1);
    plot(time,rad2deg(FilteredXAngleFromAcc));
    hold on;
    plot(time,rad2deg(FilteredYAngleFromAcc));
    plot(time,rad2deg(FilteredZAngleFromAcc));
    title(strcat('Angle from Acc cutoffFreq;',num2str(cutoffFreqArray(cutoffIndex)),'Hz'));
    ylabel('Degree');
    xlabel('time(sec.)');
    subplot(2,1,2);
    plot(time,rad2deg(FilteredXAngleFromGyro));
    hold on;
    plot(time,deg2rad(FilteredYAngleFromGyro));
    plot(time,deg2rad(FilteredZAngleFromGyro));
    title(strcat('Angle change from Gyro cutoffFreq;',num2str(cutoffFreqArray(cutoffIndex)),'Hz'));
    ylabel('Degree');
    xlabel('time(sec.)');
end

 [MinRipple,bestCutoffIndex] = min(AngleRippleArray);
 disp(strcat('best cutoff freq:',num2str(cutoffFreqArray(bestCutoffIndex)),'Hz'));
 disp(strcat('Ripple:',num2str(MinRipple)));

