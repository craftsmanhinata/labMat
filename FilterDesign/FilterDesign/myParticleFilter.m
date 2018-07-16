close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

addNoiseR = 0.2;

noiseDistR = 0.2;

particleNumber = 100;
ESSThreshold = particleNumber / 2;

observeR = 0.2;


ECGFolder = 'ECG\';
fileNameECG = '0001~aa~tri3.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);
ECGFs = 1000;
dECG = decimate(ECG,ECGFs / (Fs));
startTime = 1;
endTime = 185;
dECGTime = (0:1:length(dECG)-1)'*Ts;

[dECGTime,dECG] = trimSig(dECGTime,dECG,startTime,endTime);

%add noise
rng(1);
noisyDECG = dECG + addNoiseR * randn(length(dECG),1);

figure('Name','Original ECG signal','NumberTitle','off');
plot(dECGTime,noisyDECG);
hold on;
plot(dECGTime,dECG);

particleArray = zeros(particleNumber,1);
defaultWeight = 1 / particleNumber;
particleWeight = zeros(particleNumber,1) + defaultWeight;

particleFilteredECG = zeros(length(dECG),1);

markerSize = logspace(0,log10(particleNumber),10);

figure('Name','Particle Animation','NumberTitle','off');
for timeIndex=1:length(dECG)
    for particleIndex = 1:particleNumber
        randSample = noisyDECG(timeIndex) + observeR * randn(1);
        diffRand = randSample - noisyDECG(timeIndex);
        particleArray(particleIndex) = randSample;
        particleWeight(particleIndex) = particleWeight(particleIndex) * pdf('Normal',diffRand,0,sqrt(noiseDistR));
    end
    cumsumWeight = cumsum(particleWeight);
    if cumsumWeight(end) ~= 0
        particleWeight = particleWeight / cumsumWeight(end);
        cumsumWeight = cumsumWeight / cumsumWeight(end);
    else
        particleWeight = zeros(particleNumber,1) +  defaultWeight;
        cumsumWeight = 1:1:particleNumber* defaultWeight;
    end
    
    ESS = 1.0/(particleWeight'*particleWeight);
    if ESS < ESSThreshold
        %resampling
        randomNum = rand(1)/particleNumber;
        samplingWeightBar = (0:1:particleNumber-1)*defaultWeight;
        samplingWeightBar = samplingWeightBar + rand()/particleNumber;
        samplingSourcePoint = 1;
        copyOfParticleArray =  particleArray;
        for particleIndex = 1 : particleNumber
            while(samplingWeightBar(particleIndex)> cumsumWeight(samplingSourcePoint))
                samplingSourcePoint = samplingSourcePoint + 1;
            end
            particleArray(particleIndex) = copyOfParticleArray(samplingSourcePoint);
            particleWeight(particleIndex) = 1 / particleNumber;
        end
    end
   
    particleFilteredECG(timeIndex) = particleArray'*particleWeight;
    particleForPlot = horzcat(particleWeight,particleArray);
    particleForPlot = sortrows(particleForPlot);
    plot(dECGTime(timeIndex), noisyDECG(timeIndex),'go','MarkerSize',5);
    hold on;
    curMarkerSize = 1;
    for particleIndex = 1:particleNumber
        plot(dECGTime(timeIndex),particleArray(particleIndex),'bo','MarkerSize',curMarkerSize);
        hold on;
        if particleIndex >= markerSize(curMarkerSize)
            curMarkerSize = curMarkerSize + 1;
        end
    end
    plot(dECGTime(timeIndex),particleFilteredECG(timeIndex),'pr','MarkerSize',10);
    hold on;
end

