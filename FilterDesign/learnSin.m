close all;
clear();
clc();

Fs = 50;
Ts = 1/Fs;

time = (0:1:2000-1)'*Ts;
sinFreq = 1;
data = sin(2*pi*sinFreq*time);
figure();
plot(time,data);

rng default;
net = fitnet(100);
net = train(net,time',data');

time_2 = (2000:1:5000-1)*Ts;
data_2 = net(mod(time_2,time(end)-1));

figure();
plot(time_2,data_2);
