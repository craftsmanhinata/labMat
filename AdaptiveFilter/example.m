clear;
close all;
clc;

D = 16;
b  = exp(1i*pi/4)*[-0.7 1];
a  = [1 -0.7];
ntr = 1024;
s  = sign(randn(1,ntr+D)) + 1i*sign(randn(1,ntr+D));
n  = 0.1*(randn(1,ntr+D) + 1i*randn(1,ntr+D));
%フィルタリング　+ noise
r  = filter(b,a,s) + n;
x  = r(1+D:ntr+D);
d  = s(1:ntr);

mu  = 0.1;
fdaf = dsp.FrequencyDomainAdaptiveFilter('Length',32,'StepSize',mu);
[y,e] = fdaf(x,d);
fftCoeffs = fdaf.FFTCoefficients;

plot(1:ntr,real([d;y;e]))
legend('Desired','Output','Error')
title('In-Phase Components')
xlabel('Time Index'); ylabel('signal value')

plot(1:ntr,imag([d;y;e]))
legend('Desired','Output','Error')
title('Quadrature Components')
xlabel('Time Index')
ylabel('signal value')