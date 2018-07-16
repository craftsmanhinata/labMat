echo off;
clear;
clc;
signalFrequency = 8;
fs = signalFrequency * 2;
ts = 1/fs;

df = 0.01;

t = [-4:ts:4];

h = Myexp(t);
figure();
plot(t,h);
xlabel('Time(s)');
title('LTI System Problem1.10');
grid on;

x = Rect(t/3);
figure();
plot(t,x);
xlabel('Time(s)');
title('Input Signal Problem1.10');
grid on;

y = conv(x,h);
[Y,y1,df1] = fftseq(y,ts,df);
f=[0:df1:df1*(length(y1)-1)]-fs/2;
Y1 = Y/fs;
figure();
plot(f,fftshift(abs(Y1)));
title('The Discrete Magnitude Spectrum Problem 1.10');
xlabel('Frequency(Hz)');
grid on;

figure();
plot(f,(angle(Y1)));
title('The Discrete Phase Spectrum Problem 1.10');
xlabel('Frequency(Hz)');
ylabel('Phase(rad)');
grid on;
