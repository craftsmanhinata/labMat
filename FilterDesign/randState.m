clear();
clc;
close all;
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\timeNoisePd.mat');
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\signalNoisePd.mat');

noiseTime = zeros(10000,1);
noiseSignal = zeros(10000,1);

for index = 1:length(noiseTime)
    noiseTime(index) = random(timeNoisePd);
end
figure();
histogram(noiseTime);
title('Time Noise');

for index = 1:length(noiseSignal)
    noiseSignal(index) = random(signalNoisePd);
end
figure();
histogram(noiseSignal);
title('Signal noise');

[timeMu,timeSigma] = normfit(noiseTime);
[signalMu,signalSigma] = normfit(noiseSignal);
