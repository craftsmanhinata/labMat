close all;
clear();
clc();
Fs = 50;
Ts = 1 / Fs;
diffFiltFpass = 5;
diffFiltFstop = diffFiltFpass*1.1;
Ap = 1.0;
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
stopBandMargin = 10;
minResVoldb = db(minResVol)+stopBandMargin;
margin = -2;
minResVoldb = minResVoldb + margin;

% Nf = 120;
% Fpass = diffFiltFpass;
% Fstop = diffFiltFstop;
% d = designfilt('differentiatorfir','FilterOrder',Nf, ...
%     'PassbandFrequency',Fpass,'StopbandFrequency',Fstop, ...
%     'SampleRate',Fs);
% Hd = d;

%fvtool(d,'MagnitudeDisplay','zero-phase','Fs',Fs)

sinFrq = 1;
time = (0:1:1300-1)*Ts;
sinData = sin(2*pi*sinFrq*time);
cosData = cos(2*pi*sinFrq*time);
figure();
plot(time,sinData);
hold on;
plot(time,cosData);

hold on;
[diffData,time] = diffFiltering(sinData,time,diffFiltFpass/(Fs/2),...
    diffFiltFstop/(Fs/2),...
    Ap,...
    -1*minResVoldb);
plot(time,diffData);