%相補フィルタのカットオフ周波数を決定するのに使用したスクリプト.

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

minCutoffFreq = 0.7;
maxCutoffFreq = 3.0;
cutoffArraySize = 100;
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

AccRippleFactor = zeros(size(cutoffFreqArray));
GyroRippleFactor = zeros(size(cutoffFreqArray));

for cutoffIndex = 1: cutoffArraySize
    highPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'high');
    lowPass = fir1(filterOrder,cutoffFreqArray(cutoffIndex)/(Fs/2),'low');
    
%     if cutoffIndex == 1
%         FontSize = 30;
%         fvtool(lowPass,1,'Fs',Fs)
%         xlim([0 3.0]);
%         title('Amplitude response(dB)','FontSize',FontSize);
%         ylabel('ylabel(dB)','FontSize',FontSize);
%         ylabel('Amplitude(dB)','FontSize',FontSize);
%         xlabel('Frequency(Hz)','FontSize',FontSize);
%         set(gca,'FontSize',FontSize);
%         fvtool(highPass,1,'Fs',Fs)
%         xlim([0 3.0]);
%         title('Amplitude response(dB)','FontSize',FontSize);
%         ylabel('ylabel(dB)','FontSize',FontSize);
%         ylabel('Amplitude(dB)','FontSize',FontSize);
%         xlabel('Frequency(Hz)','FontSize',FontSize);
%         set(gca,'FontSize',FontSize);
%     end

    FilteredXGyro = filtfilt(highPass,1,xGyro);
    FilteredYGyro = filtfilt(highPass,1,yGyro);
    FilteredZGyro = filtfilt(highPass,1,zGyro);

    xAngle = angleSpeedIntegral(FilteredXGyro,Fs);
%     xAngle = filtfilt(highPass,1,xAngle);
%     plot(time,xAngle);
    xAngleRippleFactor = abs(rms(xAngle)/mean(xAngle));
    yAngle = angleSpeedIntegral(FilteredYGyro,Fs);
%     yAngle = filtfilt(highPass,1,yAngle);
    yAngleRippleFactor = abs(rms(yAngle)/mean(yAngle));
    zAngle = angleSpeedIntegral(FilteredZGyro,Fs);
%     zAngle = filtfilt(highPass,1,zAngle);
    zAngleRippleFactor = abs(rms(zAngle)/mean(zAngle));
    GyroRippleFactor(:,cutoffIndex) = mean([xAngleRippleFactor yAngleRippleFactor zAngleRippleFactor]);
    
    FilteredXAcc = filtfilt(lowPass,1,xAcc);
    FilteredYAcc = filtfilt(lowPass,1,yAcc);
    FilteredZAcc = filtfilt(lowPass,1,zAcc);

    [roll, pitch] = calcRollPitchFromAcc([FilteredXAcc FilteredYAcc FilteredZAcc]);
%     roll = filtfilt(lowPass,1,roll);
    rollRippleFactor = abs(rms(roll)/mean(roll));
%     pitch = filtfilt(lowPass,1,pitch);
    pitchRippleFactor = abs(rms(pitch)/mean(pitch));
    AccRippleFactor(:,cutoffIndex) = mean([rollRippleFactor pitchRippleFactor]);
    [rollSpeed(:,cutoffIndex),pitchSpeed(:,cutoffIndex),yawSpeed(:,cutoffIndex)] = calcAngleSpeed([FilteredXGyro FilteredYGyro FilteredZGyro],roll,pitch);
%     AngleRippleArray(:,cutoffIndex) = meanAngleRippleFactor;
    
    
%     meanRollAngleSpeed = mean(rollSpeed(:,cutoffIndex));
%     meanPitchAngleSpeed = mean(yawSpeed(:,cutoffIndex));
%     meanYawAngleSpeed = mean(pitchSpeed(:,cutoffIndex));
% 
%     
%     rollAngleRipple = rms(rollSpeed(:,cutoffIndex));
%     pitchAngleRipple = rms(pitchSpeed(:,cutoffIndex));
%     yawAngleRipple = rms(yawSpeed(:,cutoffIndex));
%     
%     rollAngleRippleArray(cutoffIndex) = abs(rollAngleRipple ./ meanRollAngleSpeed);
%     pitchAngleRippleArray(cutoffIndex) = abs(pitchAngleRipple ./ meanPitchAngleSpeed);
%     yawAngleRippleArray(cutoffIndex) = abs(yawAngleRipple ./ meanYawAngleSpeed);
%     AngleRippleArray(cutoffIndex) = mean([(rollAngleRipple) (pitchAngleRipple) (yawAngleRipple)]);
% 
%     disp(strcat('cufoffFrq:',num2str(cutoffFreqArray(cutoffIndex))));
%     
%     disp(strcat('RollAngleRipple:',num2str(rollAngleRipple)));
%     disp(strcat('PitchAngleRipple:',num2str(pitchAngleRipple)));
%     disp(strcat('YawAngleRipple:',num2str(yawAngleRipple)));
%     disp(strcat('AngleMeanRipple:',num2str(AngleRippleArray(cutoffIndex))));
end
figure();
plot(cutoffFreqArray,GyroRippleFactor);
hold on;
plot(cutoffFreqArray,AccRippleFactor);
[MinRipple,bestCutoffIndex] = min(GyroRippleFactor);

 disp(strcat('best cutoff freq:',num2str(cutoffFreqArray(bestCutoffIndex)),'Hz'));
 disp(strcat('Ripple:',num2str(MinRipple)));
%  [roll, pitch] = calcRollPitchFromAcc([xAcc yAcc zAcc]);
%  [rollSpeedRaw,pitchSpeedRaw,yawSpeedRaw] = calcAngleSpeed([xGyro yGyro zGyro],roll,pitch);
%      
%  MeanRollSpeedRaw = mean(rollSpeedRaw);
%  MeanPitchSpeedRaw = mean(pitchSpeedRaw);
%  MeanYawSpeedRaw = mean(yawSpeedRaw);
%  RollRippleRaw = rms(rollSpeedRaw);
%  PitchRippleRaw = rms(pitchSpeedRaw);
%  YawRippleRaw = rms(yawSpeedRaw);
%  rippleRaw = mean([abs(RollRippleRaw / MeanRollSpeedRaw) abs(MeanPitchSpeedRaw / PitchRippleRaw) ...
%      abs(YawRippleRaw / MeanYawSpeedRaw)]);
%  

FontSize = 19; 
figure();
 axRoll = subplot(3,1,1);
 plot(time,rollSpeed(:,bestCutoffIndex));
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angular speed(rad/sec.)','FontSize',FontSize);
 title('Roll angular speed','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
 axPitch = subplot(3,1,2);
 plot(time,pitchSpeed(:,bestCutoffIndex));
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angular speed(rad/sec.)','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
  title('Pitch angular speed','FontSize',FontSize);
 axYaw = subplot(3,1,3);
 plot(time,yawSpeed(:,bestCutoffIndex));
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angular speed(rad/sec.)','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
   title('Yaw angular speed','FontSize',FontSize);
 linkaxes([axRoll,axPitch,axYaw],'xy');
 xlim([0 180]);
 
 
 rollChange = angleSpeedIntegral(rollSpeed(:,bestCutoffIndex),Fs);
 pitchChange = angleSpeedIntegral(pitchSpeed(:,bestCutoffIndex),Fs);
 yawChange = angleSpeedIntegral(yawSpeed(:,bestCutoffIndex),Fs);

 figure();
 axRollChange = subplot(3,1,1);
 plot(time,rollChange);
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angle increasement(rad)','FontSize',FontSize);
 title('Roll angle increasement','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
 axPitchChange = subplot(3,1,2);
 plot(time,pitchChange);
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angle increasement(rad)','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
  title('Pitch angle increasement','FontSize',FontSize);
 axYawChange = subplot(3,1,3);
 plot(time,yawChange);
 xlabel('Time(sec.)','FontSize',FontSize);
 ylabel('Angle increasement(rad)','FontSize',FontSize);
 set(gca,'FontSize',FontSize);
   title('Yaw angle increasement','FontSize',FontSize);
 linkaxes([axRollChange,axPitchChange,axYawChange],'xy');
 xlim([0 180]);
% 
%  
%  figure();
%  axRollRaw = subplot(3,1,1);
%  plot(time,rollSpeedRaw);
%  xlabel('time(sec.)');
%  ylabel('AngleSpeed(rad/sec.)');
%  axPitchRaw = subplot(3,1,2);
%  plot(time,pitchSpeedRaw);
%  xlabel('time(sec.)');
%  ylabel('AngleSpeed(rad/sec.)');
%  axYawRaw = subplot(3,1,3);
%  plot(time,yawSpeedRaw);
%  xlabel('time(sec.)');
%  ylabel('AngleSpeed(rad/sec.)');
%  linkaxes([axRoll,axRollRaw,axPitchRaw,axYawRaw],'xy');
 
