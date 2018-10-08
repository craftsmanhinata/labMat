clear;
close all;
clc;
Fs = 50;
Ts = 1 / Fs;
blockLength = 2^9;
dataPoint = 100 * blockLength;
time = (0:dataPoint-1)*Ts;
freq1 = 1.2;
freq2 = 2.0;
noiseData = [sin(2 * pi * freq1 * time(1:ceil(end/2)))...
    sin(2 * pi * freq2 * time(ceil(end/2)+1:end))];

figure();
plot(time,noiseData);
title('Noise Signal');

freq3 = 0.3;
Data = sin(2 * pi * freq3 * time);
figure();
plot(time,Data);
title('Original Signal');

mixedData = Data + noiseData;
figure();
plot(time,mixedData);
title('Mixed Signal');

mu = 0.1;
fdaf = dsp.FrequencyDomainAdaptiveFilter('Length',blockLength,...
    'BlockLength',blockLength,'StepSize',mu);
[y,err] = fdaf(mixedData,noiseData);


%plot(time,err);
%hold on;
plot(time,err);
title('Adaptive Filter Response');
hold on;
plot(time,Data);
plot(time,mixedData);
plot(time,noiseData);
legend('Filtered Signal','Original Signal','Mixed Signal','Noise');


fftres = fft(err);
fftres = abs(fftres);
fftres = fftshift(fftres);
f = Fs*(-(length(fftres)/2):(length(fftres)/2-1))/length(fftres);
figure();
plot(f,fftres);