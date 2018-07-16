close all;
clear();
clc();
addpath('.\FastICA_25');

Fs = 50;
Ts = 1 / Fs;
pointNum = 2000;

time = (0:1:pointNum - 1) * Ts;

figure();
subplot(5,2,1);
sinFreq1 = 1;
signal1 = sin(2*pi*sinFreq1*time);
plot(time,signal1);
title('Component 1');

subplot(5,2,3);
sinFreq2 = 2.3;
signal2 = sin(2*pi*sinFreq2*time);
plot(time,signal2);
title('Component 2');

subplot(5,2,5);
sawtoothFreq = 5;
signal3 = sawtooth(2*pi*sawtoothFreq*time);
plot(time,signal3);
title('Component 3');

subplot(5,2,7);
squareFreq = 0.1;
signal4 = square(2*pi*squareFreq*time);
plot(time,signal4);
title('Component 4');

subplot(5,2,9);
mixedSignal = conv(conv(conv(signal1,signal2),signal3),signal4);
plot(time,mixedSignal(1:length(time)));
title('Obsereved Signal');

subplot(5,2,2);
histogram(signal1);
title('Component 1 histogram');
subplot(5,2,4);
histogram(signal2);
title('Component 2 histogram');
subplot(5,2,6);
histogram(signal3);
title('Component 3 histogram');
subplot(5,2,8);
histogram(signal4);
title('Component 4 histogram');
subplot(5,2,10);
histogram(mixedSignal);
title('Observed Signal histogram');

mixedMat = zeros(4,pointNum);
mixedMat(1,:) = mixedSignal(1:length(time));
mixedMat(2,:) = signal1;
mixedMat(3,:) = signal2;
mixedMat(4,:) = signal3;
[cwtMat,f,coi] = cwtMultiAnimation(mixedMat,time,[0.1 20],true);
cwtPowerMat = abs(cwtMat);
icasig = zeros(fliplr(size(cwtPowerMat)));
icaSource = permute(cwtPowerMat,[3 2 1]);
for index = 1:length(f)
    [A,W] = fastica (icaSource(:,:,index), 'numOfIC', 4, 'displayMode', 'off','verbose', 'off');
end

figure();
for index = 1:length(mixedMat(:,1))
    subplot(length(mixedMat(:,1)),2,index*2-1);
    plot(time,mixedMat(index,:));
    subplot(length(mixedMat(:,1)),2,index*2);
    histogram(icasig(index,:));
end


figure();
for index = 1:length(icasig(:,1))
    subplot(length(icasig(:,1)),2,index*2-1);
    plot(time,icasig(index,:));
    subplot(length(icasig(:,1)),2,index*2);
    histogram(icasig(index,:));
end

%cwtMultiAnimation(mixedMat,time,[0.1 5],true);

