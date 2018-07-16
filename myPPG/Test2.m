clear;
clc;


dataDir = 'data';
dataFile = '20180223_141456_Test';


disp(strcat(dataDir,'\',dataFile,'.csv'));
adConvData = csvread(strcat(dataDir,'\',dataFile,'.csv'));
adConvData = adConvData + 1;
adcPlusInputMax = 3.3;
adcMinusInputMax = 0;
adConvData = (adcPlusInputMax / (2 - 2^ (-15))) * adConvData;
samplingHz = 200;
samplingPeriod = 1 / samplingHz;
time = (0:1:length(adConvData)-1)';
time = samplingPeriod * time;
figure();
plot(time,adConvData);
ylim([adcMinusInputMax,adcPlusInputMax]);
ylabel('Voltage(V)');
xlabel('Time(s)');
AvrSignal = mean(adConvData);
NoiseSignalRMS = rms(adConvData);
StdSignal = std(adConvData);
VarSignal = var(adConvData);
SignalRMS = rms(ones(length(adConvData),1)*AvrSignal);



fc = 5;
fs = samplingHz;

[b,a] = butter(6,fc/(fs/2));
y = filter(b,a,adConvData);
figure();
plot(time,y);
ylabel('Voltage(V)');
xlabel('Time(s)');

L = length(detrend(y));
FFTRes = fft(detrend(y));
P2 = abs(FFTRes / L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = samplingHz*(0:(L/2))/L;
figure();
plot(f,P1);
xlim([0,5]);
maxP = max(adConvData);
minP = min(adConvData);