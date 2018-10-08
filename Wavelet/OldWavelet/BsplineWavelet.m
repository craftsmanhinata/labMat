clc;
clear();
close all;


%‚½‚ß‚µ‚Ésin”g‚Å‚â‚Á‚Ä‚İ‚é
samplingPeriod = 0.01;
dataPoint = 1000;
t = 0:1:dataPoint-1;
t = t * samplingPeriod;
f1 = 2;
f2 = 5;
data = [sin(2 * pi * f1 * t(1:ceil(end/2)))  sin(2 * pi * f2 * t(ceil(end/2)+1:end))];
figure();
plot(t,data);


% ü”g”ŒvZ
fs = 1/samplingPeriod;
wname = 'fbsp3-0.05-0.2';

scale =1:30;
getWavelets(wname,scale,fs);



[coefs, frequencies] = cwt(data, scale, wname, samplingPeriod);%ŒW”‚Æü”g”‚ğ‚©‚¦‚·
%imagesc(abs(coefs));
% freq = scal2frq(scale, 'fbsp3-1-0.5', samplingPeriod);

%”½“]
% flipudFrequencies = flipud(frequencies');
% flipudCoefs = flipud(abs(coefs));
%figure;

%ƒXƒPƒƒOƒ‰ƒ€
plotScaleogram(coefs,t,scale,frequencies);


