clear;
close all;
clc;

BlockLength = 128 * 2;

%未知システムの生成
Fs = 50;
Ts = 1 / Fs;
NyquistFreq = Fs / 2;
b = fir1(200,[0.1/NyquistFreq 10/NyquistFreq]);
fvtool(b,'Fs',Fs);

filterCoeffGraph = figure;
stem(b);

dataLength = BlockLength * 100;
signalTime = (0:1:dataLength-1)*Ts;
signal = 5 * sin(2 * pi * 20 * signalTime) + 10 * sin(2 * pi * 10 * signalTime)...
    +8 * sin(2 * pi * 0.1 * signalTime) + sin(2 * pi * 1 * signalTime);
signalFig = figure();
%観測されうる信号
plot(signalTime,signal);

%未知のシステムから出力される信号の生成
filteredSignal = filter(b,1,signal);
%ノイズの生成
Noise = 0.1 * randn(1,dataLength);

%他の信号の生成
otherSignal = cos(2 * pi * 15 * signalTime);

ObservedSignal = filteredSignal + Noise + otherSignal;

hold on;
plot(signalTime,ObservedSignal);

mu = 0.01;
fdaf = dsp.FrequencyDomainAdaptiveFilter('Length',BlockLength,'StepSize',mu);
[y, e] = fdaf(ObservedSignal,signal);
fftCoeffs = fdaf.FFTCoefficients;

figure(filterCoeffGraph);
hold on;
IfilterCoeff = ifft(fftCoeffs);
%IfilterCoeff = (fftCoeffs);
stem(real(IfilterCoeff));
legend('Unknown System','FDAF');

fvtool(real(IfilterCoeff),'Fs',Fs);
figure(signalFig);
plot(signalTime,y);
legend('InputSignal','ObservedSignal','AdaptiveFilterOutput');

[spectY,~] = FFTAuto(y,Fs);
[spectOrig,~] = FFTAuto(signal,Fs);
[spectObserve,freq] = FFTAuto(ObservedSignal,Fs);
spectY = abs(spectY);
spectY(2:end-1) = 2 * spectY(2:end-1);
spectOrig = abs(spectOrig);
spectOrig(2:end-1) = 2 * spectOrig(2:end-1);
spectObserve = abs(spectObserve);
spectObserve(2:end-1) = 2 * spectObserve(2:end-1);
figure();
plot(freq,spectOrig);
hold on;
plot(freq,spectObserve);
plot(freq,spectY);
legend('InputSignal','OutputSignal','AdaptiveFilterOutput');

