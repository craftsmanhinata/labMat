%各適応アルゴリズムの比較用プログラム. 
%適当に組んであるので使えないと思います.
%実行時間計測用.
load('.\ECG\ECGTransitionPd.mat');
percentage = 1;
ECGFolder = 'ECG\';


PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

RHR = 69;
fileNameECG = 'ECG20181204_01.csv';
fileNamePPG = '20181204_Data01_Res.csv';

procTime = 180;
ECGFs = 1000;
ECGTs = 1 / ECGFs;
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);
dECG = decimate(ECG,(ECGFs/Fs));
dECG = trimSig(dECG,Fs,procTime);
dECGDataArray = dECG;

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


realHRArray = calcRealHR(dECGTime,dECGDataArray,...
        slidingSpectrumTime,peakHeight,peakDistance,plotIs);
PPGFolder = 'PPG\';
filterCoeffLength = 100;
RLSForgettingFactor = 1;


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

PPGDataArray = zeros(ceil(procTime/Ts),1);
inertialDataArray = zeros(inertialAxis,ceil(procTime/Ts),1);


coheFreqRange = [0.7 3.0];
filterOrder = 2900;

PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPG = trimSig(PPG,Fs,procTime);
PPGDataArray(:,1) = PPG;

xAcc = PPGData(:,2);
xAcc = trimSig(xAcc,Fs,procTime);
inertialDataArray(xAccKey,:,1) = xAcc;

yAcc = PPGData(:,3);
yAcc = trimSig(yAcc,Fs,procTime);
inertialDataArray(yAccKey,:,1) = yAcc;

zAcc = PPGData(:,4);
zAcc = trimSig(zAcc,Fs,procTime);
inertialDataArray(zAccKey,:,1) = zAcc;

xGyro = PPGData(:,5);
xGyro = trimSig(xGyro,Fs,procTime);
inertialDataArray(xGyroKey,:,1) = xGyro;

yGyro = PPGData(:,6);
yGyro = trimSig(yGyro,Fs,procTime);
inertialDataArray(yGyroKey,:,1) = yGyro;

zGyro = PPGData(:,7);
zGyro = trimSig(zGyro,Fs,procTime);
inertialDataArray(zGyroKey,:,1) = zGyro;

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

inertialDataArray(xAngleKey,:,1) = rollSpeed;
inertialDataArray(yAngleKey,:,1) = pitchSpeed;
inertialDataArray(zAngleKey,:,1) = yawSpeed;




spectrumBuffer = zeros(ceil(FFTLength/2)+1,FFTExecuteNum,zAngleKey);

NLMSStepSize = 1;

NLMSFilter = dsp.LMSFilter('Length',filterCoeffLength,...
    'StepSize',NLMSStepSize,'Method','Normalized LMS');
tic
for axisIndex = 1:Dict.Count
    disp(strcat('axisName:',Dict(axisIndex)));
    if axisIndex < TriAccKey
        [~,adaptOutput] = NLMSFilter(PPGDataArray(:,1),...
            inertialDataArray(axisIndex,:,1)');
        if any(isnan(adaptOutput))
            disp('error');
            return
        end
        [adaptOutputSpectrum,freq,spectrumTime] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs);
        adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);
        spectrumBuffer(:,:,axisIndex) = adaptOutputSpectrum;
        [estimateAdaptPulseRate]= getHRFromSpectrumPd(adaptOutputSpectrum,freq,freqRange,RHR,pd,percentage);
        estimateAdaptPulseRate = estimateAdaptPulseRate * 60;
        adaptPulseRateError = sqrt(immse(estimateAdaptPulseRate,realHRArray(:,1)));
        NLMSFilter = dsp.LMSFilter('Length',filterCoeffLength,...
        'StepSize',NLMSStepSize,'Method','Normalized LMS');
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
        [estimateAdaptTriPulseRate]= getHRFromMixedSpectrumsPd(mixedNLMSSpectrum,freq,freqRange,RHR,pd,percentage);
        estimateAdaptTriPulseRate = estimateAdaptTriPulseRate * 60;
    end
end
toc

RLSFilter = dsp.RLSFilter('Length',filterCoeffLength,...
        'ForgettingFactor',RLSForgettingFactor);
tic
for axisIndex = 1:Dict.Count
    disp(strcat('axisName:',Dict(axisIndex)));
    if axisIndex < TriAccKey
        [~,adaptOutput] = RLSFilter(PPGDataArray(:,1),...
            inertialDataArray(axisIndex,:,1)');
        if any(isnan(adaptOutput))
            disp('error');
            return
        end
        [adaptOutputSpectrum,freq,spectrumTime] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs);
        adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);
        spectrumBuffer(:,:,axisIndex) = adaptOutputSpectrum;
        [estimateAdaptPulseRate]= getHRFromSpectrumPd(adaptOutputSpectrum,freq,freqRange,RHR,pd,percentage);
        estimateAdaptPulseRate = estimateAdaptPulseRate * 60;
        adaptPulseRateError = sqrt(immse(estimateAdaptPulseRate,realHRArray(:,1)));
        
        RLSFilter = dsp.RLSFilter('Length',filterCoeffLength,...
        'ForgettingFactor',RLSForgettingFactor);
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
    end
end
toc

FFTLMSStepSize = 1.0;
tic
FFTLMSFilter = dsp.FrequencyDomainAdaptiveFilter('Length',filterCoeffLength,...
    'StepSize',FFTLMSStepSize,'Method','Partitioned constrained FDAF');
spectrumBuffer = zeros(ceil(FFTLength/2)+1,FFTExecuteNum,zAngleKey);
for axisIndex = 1:Dict.Count
    disp(strcat('axisName:',Dict(axisIndex)));
    if axisIndex < TriAccKey
        [~,adaptOutput] = FFTLMSFilter(PPGDataArray(:,1),...
            inertialDataArray(axisIndex,:,1)');
        if any(isnan(adaptOutput))
            disp('error');
            return
        end
        [adaptOutputSpectrum,freq,spectrumTime] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs);
        adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);
        spectrumBuffer(:,:,axisIndex) = adaptOutputSpectrum;
        [estimateAdaptPulseRate]= getHRFromSpectrumPd(adaptOutputSpectrum,freq,freqRange,RHR,pd,percentage);
        estimateAdaptPulseRate = estimateAdaptPulseRate * 60;
        
        FFTLMSFilter = dsp.FrequencyDomainAdaptiveFilter('Length',filterCoeffLength,...
        'StepSize',FFTLMSStepSize,'Method','Partitioned constrained FDAF');
    else
        mixedFFTLMSSpectrum = zeros([size(adaptOutputSpectrum) 3]);
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
            mixedFFTLMSSpectrum(:,:,loopCount) = spectrumBuffer(:,:,mixedIndex);
            loopCount = loopCount + 1;
        end
        [estimateAdaptTriPulseRate]= getHRFromMixedSpectrumsPd(mixedFFTLMSSpectrum,freq,freqRange,RHR,pd,percentage);
        estimateAdaptTriPulseRate = estimateAdaptTriPulseRate * 60;
    end
end
toc

