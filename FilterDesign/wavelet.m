close all;
clear();
clc();
Fs = 50;
Ts = 1 / Fs;
diffFiltFpass = 1;
diffFiltFstop = diffFiltFpass*1.1;
Ap = 1.0;
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
stopBandMargin = 10;
minResVoldb = db(minResVol)+stopBandMargin;
margin = -2;
minResVoldb = minResVoldb + margin;

sinFreq1 = 1;
sinFreq2 = 2;
time = (0:1:500-1)*Ts;
demoData = [sin(2*pi*sinFreq1*time(1:(end/2))),sin(2*pi*sinFreq2*time((end/2+1):end))];


resWave = cwtPeakDetect(demoData,Fs,0.1,3,false,5,5,false);
[instFreqData,diffTime] = instFreqProc(resWave,time,diffFiltFpass,true);


figure();
plot(time,demoData);
yyaxis right;
plot(diffTime,instFreqData);
ylim([0.1 3]);
hold on;
%[demoData,diffTime] = instFreqProc(demoData,time,diffFiltFpass,false);
%yyaxis right;
%plot(diffTime,demoData,'b');


