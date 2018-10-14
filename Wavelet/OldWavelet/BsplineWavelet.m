clc;
clear();
close all;


%ためしにsin波でやってみる
samplingPeriod = 0.01;
dataPoint = 1000;
t = 0:1:dataPoint-1;
t = t * samplingPeriod;
f1 = 2;
f2 = 5;
data = [sin(2 * pi * f1 * t(1:ceil(end/2)))  sin(2 * pi * f2 * t(ceil(end/2)+1:end))];



% 周波数計算
fs = 1/samplingPeriod;
wname = 'fbsp3-0.05-0.2';
wname = 'cmor2-3';

voicesPerOctave = 48;
scales = scalesAutoSet(wname,samplingPeriod,[0.1 50],voicesPerOctave);


getWavelets(wname,scales,fs);



[coefs, frequencies] = cwt(data, scales, wname, samplingPeriod);%係数と周波数をかえす
%imagesc(abs(coefs));
% freq = scal2frq(scale, 'fbsp3-1-0.5', samplingPeriod);

%反転
% flipudFrequencies = flipud(frequencies');
% flipudCoefs = flipud(abs(coefs));
%figure;

%スケログラム
plotScaleogram2(coefs,t,frequencies);

reconSig = reconstructFromCoeffs(wname,coefs,scales,samplingPeriod,voicesPerOctave);

figure();
plot(t,data);
hold on;
plot(t,reconSig);

