clear;
clc;
timewidth = 12;
df = 0.01;
T0 = 6; %x(t) Period
f0 = 1/T0; %x(t) frequency
fs = f0 * 10; % sampling frequcny
ts = 1/fs; % sampling period
t = [-1*timewidth/2:ts:timewidth/2]; % time
x = Rect(t/3); % signal x(t)

h =  exp( - t / 2);

h(1:round(timewidth/2/ts)+1) = 0;

if timewidth / 2 >= 4
    h(round(4/ts)+round(size(h,2)/2):size(h,2)) = 0;
end

y = conv(x,h);

[Y,y1,df1] = fftseq(y,ts,df);
f = [0:df1:df1*(length(y1)-1)]-fs/2;
Y1 = Y / fs;
plot(f,abs(Y1));