%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

close all;
clear();
clc;
% 
% 
% logFolder = 'Log\';
% fileNameLog = 'RLSTuning.txt';
% diary(strcat(logFolder,fileNameLog));
load('.\ECG\ECGTransitionPd.mat');
percentage = 1;

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;


ECGFolder = 'ECG\';
fileNameECG = {...
    'ECG20181204_01.csv',...   %1
    'ECG20181204_02.csv',...  %2
    'ECG20181204_03.csv',...  %3
    'ECG20181204_04.csv',...  %4
    'ECG20181204_05.csv',...  %5
    'ECG20181204_06.csv',...  %6
    'ECG20181204_07.csv',...  %7
    'ECG20181204_08.csv',...  %8
    'ECG20181204_09.csv',...  %9
    'ECG20181204_10.csv'      %10
    };
fileNamePPG = {...
    '20181204_Data01_Res.csv',... %1
    '20181204_Data02_Res.csv',...    %2
    '20181204_Data03_Res.csv',...    %3
    '20181204_Data04_Res.csv',...    %4
    '20181204_Data05_Res.csv',...    %5
    '20181204_Data06_Res.csv',...    %6
    '20181204_Data07_Res.csv',...    %7
    '20181204_Data08_Res.csv',...    %8
    '20181204_Data09_Res.csv',...    %9
    '20181204_Data10_Res.csv'        %10
    };
if length(fileNameECG) ~= length(fileNamePPG)
    ME = MException('MyLib:dataError', ...
        'Data counts do not match.');
    throw(ME);
end
trialLength = length(fileNameECG);

procTime = 180;
dECGDataArray = zeros(ceil(procTime/Ts),trialLength);
ECGFs = 1000;
ECGTs = 1 / ECGFs;
for index = 1:trialLength
    ECGData = csvread(strcat(ECGFolder,cell2mat(fileNameECG(index))));
    ECG = ECGData(:,2);
    dECG = decimate(ECG,(ECGFs/Fs));
    dECG = trimSig(dECG,Fs,procTime);
    dECGDataArray(:,index) = dECG;
end

dECGTime = (0:length(dECGDataArray)-1) * Ts;

freqRange = [0.7 3.0];



FFTLength = 512;
Overlap = 256;
peakHeight = 30;
peakDistance = 0.4;
plotIs = false;
FFTExecuteNum = floor(length(dECGTime)/Overlap)-1;
FFTSpectrumTime = (1:1:FFTExecuteNum)*Overlap*Ts;
slidingSpectrumTime = spectrumTimeSlidingEndTime(FFTSpectrumTime,Ts);

realHRArray = zeros(FFTExecuteNum,trialLength);



for index = 1:trialLength
    realHRArray(:,index) = calcRealHR(dECGTime,dECGDataArray(:,trialLength),...
        slidingSpectrumTime,peakHeight,peakDistance,plotIs);
end


PPGFolder = 'PPG\';

%searchFilterCoefLength = 10:10:500;
searchFilterCoefLength = divisors(length(dECG));
searchFilterCoefLength = searchFilterCoefLength .* ((searchFilterCoefLength >= 10) .* (searchFilterCoefLength < 900));
searchFilterCoefLength(searchFilterCoefLength == 0 ) = '';

searchFilterCoefLengthProcNum = length(searchFilterCoefLength);

RLSMinForgettingFactor = 0.78;

xAccKey = 1;
yAccKey = 2;
zAccKey = 3;
xGyroKey = 4;
yGyroKey = 5;
zGyroKey = 6;
xAngleKey = 7;
yAngleKey = 8;
zAngleKey = 9;
TriAccKey = 10;
TriGyroKey = 11;
TriAngleKey = 12;
KeyArray = 1:1:12;
valueSet = {'xAcc','yAcc','zAcc',...
    'xGyro','yGyro','zGyro',...
    'roll','pitch','yaw',...
    'TriAcc','TriGyro','TriAngle'};
Dict = containers.Map(KeyArray,valueSet);

inertialAxis = 6;

PPGDataArray = zeros(ceil(procTime/Ts),trialLength);
inertialDataArray = zeros(inertialAxis,ceil(procTime/Ts),trialLength);


coheFreqRange = [0.7 3.0];
filterOrder = 2900;


for index = 1 : trialLength
    PPGData = csvread(strcat(PPGFolder,cell2mat(fileNamePPG(index))));
    PPG = PPGData(:,1);
    PPG = trimSig(PPG,Fs,procTime);
    PPGDataArray(:,index) = PPG;
    
    xAcc = PPGData(:,2);
    xAcc = trimSig(xAcc,Fs,procTime);
    inertialDataArray(xAccKey,:,index) = xAcc;
    
    yAcc = PPGData(:,3);
    yAcc = trimSig(yAcc,Fs,procTime);
    inertialDataArray(yAccKey,:,index) = yAcc;
    
    zAcc = PPGData(:,4);
    zAcc = trimSig(zAcc,Fs,procTime);
    inertialDataArray(zAccKey,:,index) = zAcc;
    
    xGyro = PPGData(:,5);
    xGyro = trimSig(xGyro,Fs,procTime);
    inertialDataArray(xGyroKey,:,index) = xGyro;
    
    yGyro = PPGData(:,6);
    yGyro = trimSig(yGyro,Fs,procTime);
    inertialDataArray(yGyroKey,:,index) = yGyro;
    
    zGyro = PPGData(:,7);
    zGyro = trimSig(zGyro,Fs,procTime);
    inertialDataArray(zGyroKey,:,index) = zGyro;
    
    cutoffFreq = 1.064;


    filterOrder = 2900;

    highPass = fir1(filterOrder,cutoffFreq/(Fs/2),'high');
    lowPass = fir1(filterOrder,cutoffFreq/(Fs/2),'low');

    FilteredXGyro = filtfilt(highPass,1,xGyro);
    FilteredYGyro = filtfilt(highPass,1,yGyro);
    FilteredZGyro = filtfilt(highPass,1,zGyro);
    FilteredXAcc = filtfilt(lowPass,1,xAcc);
    FilteredYAcc = filtfilt(lowPass,1,yAcc);
    FilteredZAcc = filtfilt(lowPass,1,zAcc);

    [roll, pitch] = calcRollPitchFromAcc([FilteredXAcc FilteredYAcc FilteredZAcc]);
    [rollSpeed,pitchSpeed,yawSpeed] = calcAngleSpeed([FilteredXGyro FilteredYGyro FilteredZGyro],roll,pitch);

    inertialDataArray(xAngleKey,:,index) = rollSpeed;
    inertialDataArray(yAngleKey,:,index) = pitchSpeed;
    inertialDataArray(zAngleKey,:,index) = yawSpeed;
end

%NLMSStepProcNum = 50;
RLSStepProcNum = 30;
RLSRMSEArray = zeros(trialLength,searchFilterCoefLengthProcNum,RLSStepProcNum,Dict.Count);

RLSForgettingFactorArray = logspace(log10(RLSMinForgettingFactor),log10(1),RLSStepProcNum);


% diary on;
for trialIndex = 1 : trialLength
    disp(strcat(num2str(trialIndex),'個目のデータ'));
    for filteCoeffIndex = 1:searchFilterCoefLengthProcNum
        for RLSForgettingFactorIndex = 1:RLSStepProcNum
            RLSFilter = dsp.RLSFilter('Length',searchFilterCoefLength(filteCoeffIndex),...
                'ForgettingFactor',RLSForgettingFactorArray(RLSForgettingFactorIndex));
            disp(strcat('FilterOrder:',num2str(searchFilterCoefLength(filteCoeffIndex))));
            disp(strcat('RLS Forgetting Factor:',num2str(RLSForgettingFactorArray(RLSForgettingFactorIndex))));
            spectrumBuffer = zeros(ceil(FFTLength/2)+1,FFTExecuteNum,zAngleKey);
            for axisIndex = 1:Dict.Count
                disp(strcat('axisName:',Dict(axisIndex)));
                if axisIndex < TriAccKey
                    [~,adaptOutput] = RLSFilter(PPGDataArray(:,trialIndex),...
                        inertialDataArray(axisIndex,:,trialIndex)');
                    if any(isnan(adaptOutput))
                        disp('error');
                        return
                    end
                    [adaptOutputSpectrum,freq,spectrumTime] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs);
                    adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);
                    spectrumBuffer(:,:,axisIndex) = adaptOutputSpectrum;
                    [estimateAdaptPulseRate]= getHRFromSpectrumPd(adaptOutputSpectrum,freq,freqRange,RHR,pd,percentage);
                    estimateAdaptPulseRate = estimateAdaptPulseRate * 60;
                    adaptPulseRateError = sqrt(immse(estimateAdaptPulseRate,realHRArray(:,trialIndex)));
                    disp(strcat('RMSE:',num2str(adaptPulseRateError)));
                    RLSRMSEArray(trialIndex,filteCoeffIndex,RLSForgettingFactorIndex,axisIndex) = adaptPulseRateError;
                    RLSFilter = dsp.RLSFilter('Length',searchFilterCoefLength(filteCoeffIndex),...
                    'ForgettingFactor',RLSForgettingFactorArray(RLSForgettingFactorIndex));
                else
                    mixedRLSSpectrum = zeros([size(adaptOutputSpectrum) 3]);
                    switch axisIndex
                        case TriAccKey
                            firstIndex = xAccKey;
                        case TriGyroKey
                            firstIndex = xGyroKey;
                        case TriAngleKey
                            firstIndex = xAngleKey;
                    end
                    loopCount = 1;
                    for mixedIndex = firstIndex:firstIndex+2
                        mixedRLSSpectrum(:,:,loopCount) = spectrumBuffer(:,:,mixedIndex);
                        loopCount = loopCount + 1;
                    end
                    [estimateAdaptTriPulseRate]= getHRFromMixedSpectrumsPd(mixedRLSSpectrum,freq,freqRange,RHR,pd,percentage);
                    estimateAdaptTriPulseRate = estimateAdaptTriPulseRate * 60;
                    estimateAdaptTriPulseError = sqrt(immse(estimateAdaptTriPulseRate,realHRArray(:,trialIndex)));
                    RLSRMSEArray(trialIndex,filteCoeffIndex,RLSForgettingFactorIndex,axisIndex) = estimateAdaptTriPulseError;
                    disp(strcat('RMSE:',num2str(estimateAdaptTriPulseError)));
                end
            end
        end
    end
end


% RMSEArray = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,Dict.Count);
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
RLSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,RLSStepProcNum,length(evalAxis));
disp('RLSアルゴリズムによる評価結果');
for trialIndex = 1 : trialLength
    otherDataIndex = 1:1:trialLength;
    otherDataIndex(trialIndex) = '';
    RLSRMSEMean(trialIndex,:,:,:) = mean(RLSRMSEArray(otherDataIndex,:,:,...
        evalAxis));
    %各軸について最小を評価
    for axisIndex = 1 : length(evalAxis)
        curRMSEMean = reshape(RLSRMSEMean(trialIndex,:,:,axisIndex),...
        [searchFilterCoefLengthProcNum RLSStepProcNum]);
        [val,minFilterParamKey] = min(curRMSEMean(:));
        [coefLenInd,StepInd]= ind2sub(size(curRMSEMean),minFilterParamKey);
        disp(strcat(num2str(trialIndex),'個目のデータの',Dict(evalAxis(axisIndex)),'に対する最適パラメータ:','係数長:',num2str(searchFilterCoefLength(coefLenInd)),...
        'ステップサイズ:',num2str(RLSForgettingFactorArray(StepInd)),''));
        disp(strcat(num2str(trialIndex),'個目のデータのRMSE:',num2str(RLSRMSEArray(trialIndex,coefLenInd,StepInd,evalAxis(axisIndex)))));
    end
end

% diary off;



