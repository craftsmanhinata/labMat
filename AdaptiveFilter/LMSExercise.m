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

mixedData = Data + noiseData + randn(length(Data),1)';



lmsFilt = dsp.LMSFilter('Length',128,'Method','Normalized LMS', ...
    'StepSize',0.1);
[y,err] = lmsFilt(noiseData',mixedData');

fftres = fft(y);
fftres = abs(fftres);
fftres = fftshift(fftres);
f = Fs*(-(length(fftres)/2):(length(fftres)/2-1))/length(fftres);
figure();
plot(f,fftres);
title('LMS Filter output Response');


fftres_origin = fft(mixedData);
fftres_origin = abs(fftres_origin);
fftres_origin = fftshift(fftres_origin);
f_origin = Fs*(-(length(fftres_origin)/2):(length(fftres_origin)/2-1))...
    /length(fftres_origin);
figure();
plot(f_origin,fftres_origin);
title('Original Signal Response');


figure();
plot(time,mixedData);
title('Mixed Signal');
hold on;
plot(time,y);
plot(time,noiseData);