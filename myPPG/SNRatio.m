clear;
clc;


dataDir = 'data';
dataFile = '20180222_132535_Test';


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