filt = dsp.FIRFilter;
filt.Numerator = fir1(10,0.25);
x = randn(1000,1);
n = 0.01*randn(1000,1);
d = filt(x) + n;
lms = dsp.LMSFilter(11,'StepSize',0.01);
[y,e,w] = lms(x,d);
plot(1:1000, [d,y,e])
title('System Identification of an FIR filter')
legend('Desired','Output','Error')
xlabel('time index')
ylabel('signal value')