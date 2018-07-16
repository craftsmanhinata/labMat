clear;
clc;

LPF = fir1(10,0.7);
freqz(LPF);
fvtool(LPF);