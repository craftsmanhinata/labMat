%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

close all;
clear();
clc;
% 
% 
% logFolder = 'Log\';
% fileNameLog = 'NLMSTuning.txt';
% diary(strcat(logFolder,fileNameLog));


PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;


ECGFolder = 'ECG\';
fileNameECG = {'2018112405move02.csv',...   %1
    '2018112405move02.csv',...  %2
    '2018112405move02.csv',...  %3
    '2018112405move02.csv',...  %4
    '2018112405move02.csv',...  %5
    '2018112405move02.csv',...  %6
    '2018112405move02.csv',...  %7
    '2018112405move02.csv',...  %8
    '2018112405move02.csv',...  %9
    '2018112405move02.csv'      %10
    };
fileNamePPG = {'20181124_200643_Move02.csv',... %1
    '20181124_200643_Move02.csv',...    %2
    '20181124_200643_Move02.csv',...    %3
    '20181124_200643_Move02.csv',...    %4
    '20181124_200643_Move02.csv',...    %5
    '20181124_200643_Move02.csv',...    %6
    '20181124_200643_Move02.csv',...    %7
    '20181124_200643_Move02.csv',...    %8
    '20181124_200643_Move02.csv',...    %9
    '20181124_200643_Move02.csv'        %10
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
peakHeight = 0.03;
peakDistance = 0.3;
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
searchFilterCoefLength = 10:10:100;

searchFilterCoefLengthProcNum = length(searchFilterCoefLength);

NLMSMinStepSize = 0.001;

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
    'xAngle','yAngle','zAngle',...
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
    
    xAngleFromGyro = angleSpeedIntegral(xGyro,Fs);
    yAngleFromGyro = angleSpeedIntegral(yGyro,Fs);
    zAngleFromGyro = angleSpeedIntegral(zGyro,Fs);
    [xAngleFromAcc,yAngleFromAcc,zAngleFromAcc] = calcAngleFromAcc(xAcc,yAcc,zAcc);
    
    [Cxy,F] = mscohere(xAngleFromGyro,xAngleFromAcc,hann(FFTLength),...
        Overlap,FFTLength,Fs);
    xPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);
    [Cxy,F] = mscohere(yAngleFromGyro,yAngleFromAcc,hann(FFTLength),...
        Overlap,FFTLength,Fs);
    yPeakFreq = coheFindPeak(F,Cxy,coheFreqRange); 
    [Cxy,F] = mscohere(zAngleFromGyro,zAngleFromAcc,hann(FFTLength),...
        Overlap,FFTLength,Fs);
    zPeakFreq = coheFindPeak(F,Cxy,coheFreqRange);
    
    highXPass = fir1(filterOrder,xPeakFreq/(Fs/2),'high');
    lowXPass = fir1(filterOrder,xPeakFreq/(Fs/2),'low');

    highYPass = fir1(filterOrder,yPeakFreq/(Fs/2),'high');
    lowYPass = fir1(filterOrder,yPeakFreq/(Fs/2),'low');

    highZPass = fir1(filterOrder,zPeakFreq/(Fs/2),'high');
    lowZPass = fir1(filterOrder,zPeakFreq/(Fs/2),'low');

    FilteredXAngleFromAcc  = filtfilt(lowXPass,1,xAngleFromAcc);
    FilteredXAngleFromGyro = filtfilt(highXPass,1,xAngleFromGyro);
    FilteredYAngleFromAcc  = filtfilt(lowYPass,1,yAngleFromAcc);
    FilteredYAngleFromGyro = filtfilt(highYPass,1,yAngleFromGyro);
    FilteredZAngleFromAcc  = filtfilt(lowZPass,1,zAngleFromAcc);
    FilteredZAngleFromGyro = filtfilt(highZPass,1,zAngleFromGyro);

    xAngle = FilteredXAngleFromAcc + FilteredXAngleFromGyro';
    inertialDataArray(xAngleKey,:,index) = xAngle;
    yAngle = FilteredYAngleFromAcc + FilteredYAngleFromGyro';
    inertialDataArray(yAngleKey,:,index) = yAngle;
    zAngle = FilteredZAngleFromAcc + FilteredZAngleFromGyro';
    inertialDataArray(zAngleKey,:,index) = zAngle;
end

%NLMSStepProcNum = 50;
NLMSStepProcNum = 20;
NLMSRMSEArray = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,Dict.Count);

NLMSMaxStepSize = 2;%maxstep(NLMSFilter,PPGDataArray(:,trialIndex));
NLMSStepSizeArray = logspace(log10(NLMSMinStepSize),log10(NLMSMaxStepSize),NLMSStepProcNum);

% diary on;
for trialIndex = 1 : trialLength
    disp(strcat(num2str(trialIndex),'個目のデータ'));
    for filteCoeffIndex = 1:searchFilterCoefLengthProcNum
        for NLMSStepSizeIndex = 1:NLMSStepProcNum
            NLMSFilter = dsp.LMSFilter('Length',searchFilterCoefLength(filteCoeffIndex),...
                'StepSize',NLMSStepSizeArray(NLMSStepSizeIndex),'Method','Normalized LMS');
            disp(strcat('FilterOrder:',num2str(searchFilterCoefLength(filteCoeffIndex))));
            disp(strcat('NLMS StepSize:',num2str(NLMSStepSizeArray(NLMSStepSizeIndex))));
            spectrumBuffer = zeros(ceil(FFTLength/2)+1,FFTExecuteNum,zAngleKey);
            for axisIndex = 1:Dict.Count
                disp(strcat('axisName:',Dict(axisIndex)));
                if axisIndex < TriAccKey
                    [~,adaptOutput] = NLMSFilter(PPGDataArray(:,trialIndex),...
                        inertialDataArray(axisIndex,:,trialIndex)');
                    if any(isnan(adaptOutput))
                        disp('error');
                        return
                    end
                    [adaptOutputSpectrum,freq,spectrumTime] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs);
                    adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);
                    spectrumBuffer(:,:,axisIndex) = adaptOutputSpectrum;
                    [estimateAdaptPulseRate]= getHRFromSpectrum(adaptOutputSpectrum,freq,freqRange,RHR);
                    estimateAdaptPulseRate = estimateAdaptPulseRate * 60;
                    adaptPulseRateError = sqrt(immse(estimateAdaptPulseRate,realHRArray(:,trialIndex)));
                    disp(strcat('RMSE:',num2str(adaptPulseRateError)));
                    NLMSRMSEArray(trialIndex,filteCoeffIndex,NLMSStepSizeIndex,axisIndex) = adaptPulseRateError;
                    NLMSFilter = dsp.LMSFilter('Length',searchFilterCoefLength(filteCoeffIndex),...
                    'StepSize',NLMSStepSizeArray(NLMSStepSizeIndex),'Method','Normalized LMS');
                else
                    mixedNLMSSpectrum = zeros([size(adaptOutputSpectrum) 3]);
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
                        mixedNLMSSpectrum(:,:,loopCount) = spectrumBuffer(:,:,mixedIndex);
                        loopCount = loopCount + 1;
                    end
                    [estimateAdaptTriPulseRate]= getHRFromMixedSpectrums(mixedNLMSSpectrum,freq,freqRange,RHR);
                    estimateAdaptTriPulseRate = estimateAdaptTriPulseRate * 60;
                    estimateAdaptTriPulseError = sqrt(immse(estimateAdaptTriPulseRate,realHRArray(:,trialIndex)));
                    NLMSRMSEArray(trialIndex,filteCoeffIndex,NLMSStepSizeIndex,axisIndex) = estimateAdaptTriPulseError;
                    disp(strcat('RMSE:',num2str(estimateAdaptTriPulseError)));
                end
            end
        end
    end
end
% diary off;


% RMSEArray = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,Dict.Count);
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
NLMSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,length(evalAxis));
disp('NLMSアルゴリズムによる評価結果');
for trialIndex = 1 : trialLength
    otherDataIndex = 1:1:trialLength;
    otherDataIndex(trialIndex) = '';
    NLMSRMSEMean(trialIndex,:,:,:) = mean(NLMSRMSEArray(otherDataIndex,:,:,...
        evalAxis));
    %各軸について最小を評価
    for axisIndex = 1 : length(evalAxis)
        curRMSEMean = reshape(NLMSRMSEMean(trialIndex,:,:,axisIndex),...
        [searchFilterCoefLengthProcNum NLMSStepProcNum]);
        [val,minFilterParamKey] = min(curRMSEMean(:));
        [coefLenInd,StepInd]= ind2sub(size(curRMSEMean),minFilterParamKey);
        disp(strcat(num2str(trialIndex),'個目のデータの',Dict(evalAxis(axisIndex)),'に対する最適パラメータ:','係数長:',num2str(searchFilterCoefLength(coefLenInd)),...
        'ステップサイズ:',num2str(NLMSStepSizeArray(StepInd)),''));
        disp(strcat(num2str(trialIndex),'個目のデータのRMSE:',num2str(NLMSRMSEArray(trialLength,coefLenInd,StepInd,evalAxis(axisIndex)))));
    end
end




