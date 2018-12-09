clc;
close all;
clear();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'PPG\';
fileNamePPG = '20181207AngleRecord08_Res.csv';
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


filterOrder = 2900;

minCutoffFreq = 0.1;
maxCutoffFreq = 3.0;
cutoffArraySize = 10;
cutoffFreqArray = logspace(log10(minCutoffFreq),log10(maxCutoffFreq),cutoffArraySize);
time = (0:1:length(xAcc)-1)*Ts;

axisNum = 3;

rollAngleRippleArray = zeros(size(cutoffFreqArray));
pitchAngleRippleArray = zeros(size(cutoffFreqArray));
yawAngleRippleArray = zeros(size(cutoffFreqArray));
AngleRippleArray = zeros(size(cutoffFreqArray));
rollSpeed = zeros([length(xAcc) cutoffArraySize]);
pitchSpeed = zeros([length(yAcc) cutoffArraySize]);
yawSpeed = zeros([length(zAcc) cutoffArraySize]);

for cutoffIndex = 1: cutoffArraySize
    highPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'high');
    lowPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'low');
    
    if cutoffIndex == 1
        FontSize = 30;
        fvtool(lowPass,1,'Fs',Fs)
        xlim([0 3.0]);
        title('Amplitude response(dB)','FontSize',FontSize);
        ylabel('ylabel(dB)','FontSize',FontSize);
        ylabel('Amplitude(dB)','FontSize',FontSize);
        xlabel('Frequency(Hz)','FontSize',FontSize);
        set(gca,'FontSize',FontSize);
        fvtool(highPass,1,'Fs',Fs)
        xlim([0 3.0]);
        title('Amplitude response(dB)','FontSize',FontSize);
        ylabel('ylabel(dB)','FontSize',FontSize);
        ylabel('Amplitude(dB)','FontSize',FontSize);
        xlabel('Frequency(Hz)','FontSize',FontSize);
        set(gca,'FontSize',FontSize);
    end

    FilteredXGyro = filtfilt(highPass,1,xGyro);
    FilteredYGyro = filtfilt(highPass,1,yGyro);
    FilteredZGyro = filtfilt(highPass,1,zGyro);
    
    [roll, pitch] = calcRollPitchFromAcc([xAcc yAcc zAcc]);
    FilteredRoll = filtfilt(lowPass,1,roll);
    FilteredPitch = filtfilt(lowPass,1,pitch);
    
    [rollSpeed(:,cutoffIndex),pitchSpeed(:,cutoffIndex),yawSpeed(:,cutoffIndex)] = calcAngleSpeed([FilteredXGyro FilteredYGyro FilteredZGyro],...
        FilteredRoll,FilteredPitch);
    
    rollSpeed(:,cutoffIndex) = angleSpeedIntegral(rollSpeed(:,cutoffIndex),Fs);
    pitchSpeed(:,cutoffIndex) = angleSpeedIntegral(pitchSpeed(:,cutoffIndex),Fs);
    yawSpeed(:,cutoffIndex) = angleSpeedIntegral(yawSpeed(:,cutoffIndex),Fs);

    
    meanRollAngleSpeed = mean(rollSpeed(:,cutoffIndex));
    meanPitchAngleSpeed = mean(yawSpeed(:,cutoffIndex));
    meanYawAngleSpeed = mean(pitchSpeed(:,cutoffIndex));

    
    rollAngleRipple = rms(rollSpeed(:,cutoffIndex));
    pitchAngleRipple = rms(pitchSpeed(:,cutoffIndex));
    yawAngleRipple = rms(yawSpeed(:,cutoffIndex));
    
    rollAngleRippleArray(cutoffIndex) = abs(rollAngleRipple ./ meanRollAngleSpeed);
    pitchAngleRippleArray(cutoffIndex) = abs(pitchAngleRipple ./ meanPitchAngleSpeed);
    yawAngleRippleArray(cutoffIndex) = abs(yawAngleRipple ./ meanYawAngleSpeed);
    AngleRippleArray(cutoffIndex) = mean([(rollAngleRipple) (pitchAngleRipple) (yawAngleRipple)]);

    disp(strcat('cufoffFrq:',num2str(cutoffFreqArray(cutoffIndex))));
    
    disp(strcat('RollAngleRipple:',num2str(rollAngleRipple)));
    disp(strcat('PitchAngleRipple:',num2str(pitchAngleRipple)));
    disp(strcat('YawAngleRipple:',num2str(yawAngleRipple)));
    disp(strcat('AngleMeanRipple:',num2str(AngleRippleArray(cutoffIndex))));
end

 [MinRipple,bestCutoffIndex] = min(AngleRippleArray);
 disp(strcat('best cutoff freq:',num2str(cutoffFreqArray(bestCutoffIndex)),'Hz'));
 disp(strcat('Ripple:',num2str(MinRipple)));
 [roll, pitch] = calcRollPitchFromAcc([xAcc yAcc zAcc]);
 [rollSpeedRaw,pitchSpeedRaw,yawSpeedRaw] = calcAngleSpeed([xGyro yGyro zGyro],roll,pitch);
     
 MeanRollSpeedRaw = mean(rollSpeedRaw);
 MeanPitchSpeedRaw = mean(pitchSpeedRaw);
 MeanYawSpeedRaw = mean(yawSpeedRaw);
 RollRippleRaw = rms(rollSpeedRaw);
 PitchRippleRaw = rms(pitchSpeedRaw);
 YawRippleRaw = rms(yawSpeedRaw);
 rippleRaw = mean([abs(RollRippleRaw / MeanRollSpeedRaw) abs(MeanPitchSpeedRaw / PitchRippleRaw) ...
     abs(YawRippleRaw / MeanYawSpeedRaw)]);
 

 figure();
 axRoll = subplot(3,1,1);
 plot(time,rollSpeed(:,bestCutoffIndex));
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 axPitch = subplot(3,1,2);
 plot(time,pitchSpeed(:,bestCutoffIndex));
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 axYaw = subplot(3,1,3);
 plot(time,yawSpeed(:,bestCutoffIndex));
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 linkaxes([axRoll,axPitch,axYaw],'xy');

 
 figure();
 axRollRaw = subplot(3,1,1);
 plot(time,rollSpeedRaw);
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 axPitchRaw = subplot(3,1,2);
 plot(time,pitchSpeedRaw);
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 axYawRaw = subplot(3,1,3);
 plot(time,yawSpeedRaw);
 xlabel('time(sec.)');
 ylabel('AngleSpeed(rad/sec.)');
 linkaxes([axRoll,axRollRaw,axPitchRaw,axYawRaw],'xy');
 
