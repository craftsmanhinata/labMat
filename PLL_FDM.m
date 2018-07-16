
clc;
clear;
adConvBit = 12;
operatingVoltage = 3.3;
maxVoltageBit = 2^adConvBit - 1;
offsetVoltage = operatingVoltage / 2;
offsetVoltageBit = ceil(maxVoltageBit / 2);
minVoltage = 0;
minVoltageBit = 0;
samplingFrequency = 100;
samplingPeriod = 1 / samplingFrequency;
operatingClock = 1 * 10 ^ 6;
operatingPeriod = 1 / operatingClock;

%centerFrequencySetting
minFrequency = 0.7;
maxFrequency = 3.0;
centerFrequency = (maxFrequency - minFrequency) / 2;
centerAngularFrequency = centerFrequency * 2 * pi ;
centerPeriod = 1 / centerFrequency;

%signalGenerater
endTimeSec = 10;
time = 0:samplingPeriod:endTimeSec;
phaseShiftStartFrequency = 1.15;
phaseShiftEndFrequency = 3.0;
phaseShift = (centerFrequency - phaseShiftStartFrequency) + (phaseShiftEndFrequency + phaseShiftStartFrequency - 2 * centerFrequency) / endTimeSec * time;
phaseShiftAngular = phaseShift * 2 * pi;
inSignal = sin(centerAngularFrequency * time + phaseShiftAngular);
origInSignal = sin(centerAngularFrequency * time);
figure('Name','Signal','NumberTitle','off');
plot(time,inSignal);
hold on;
plot(time,origInSignal);
xlabel('Time(s)');
ylabel('Voltage(V)');
grid on;
grid minor;


%NCO
refTime = 0:operatingPeriod:centerPeriod;
refSignal =  cos(centerAngularFrequency * refTime);
figure('Name','RefSignal','NumberTitle','off');
plot(refTime,refSignal);
xlabel('Time(s)');
ylabel('Voltage(V)');
grid on;
grid minor;

%phaseComparator
compRefSignal = cos(centerAngularFrequency * time );
compOutSignal = compRefSignal .* origInSignal- sin (2 * centerAngularFrequency * time ) / 2;
figure('Name','PhaseComparator','NumberTitle','off');

%plot(time,compRefSignal);
%plot(time,origInSignal);
plot(time,compOutSignal);

hold on;

xlabel('Time(s)');
ylabel('Voltage(V)');
grid on;
grid minor;

windowSize = 16;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
out = filter(b,a,compOutSignal);
plot(time,out);
disp(max(out)*2);