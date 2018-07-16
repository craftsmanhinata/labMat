clear;
clc;

degree = 6;
point = 2^10;

samplingFrequency = 100;
samplingPeriod = 1 / samplingFrequency;

minFrequency = 0.1;
maxFrequency = samplingFrequency  / 2 ;
scaleStepParam = 1.0;
perExec = floor(log2((minFrequency^-1)/(maxFrequency^-1))/scaleStepParam);

row = 3;
column = 2;

scaleA = 0:1:perExec;
scaleA = 2 .^ (scaleA * scaleStepParam);
scaleA = maxFrequency^-1 .* scaleA;
frequencyWavelet = transpose(scaleA).^-1;

time = 0:1:point-1;
time = time.* samplingPeriod;

frequencyPoint = 5;

angularFrequencyWavelet = [1:fix(point/2)];
angularFrequencyWavelet = angularFrequencyWavelet .* ((2*pi)/(point*samplingPeriod));
angularFrequencyWavelet = [0., angularFrequencyWavelet, -angularFrequencyWavelet(fix((point-1)/2):-1:1)];
frequencyFourier = (-point/2:point/2-1)*(samplingFrequency/point);


fourierSpaceMotherWavelet = zeros(perExec,point);
for k = 1 : perExec
    expnt = -(scaleA(k).*angularFrequencyWavelet - degree).^2/2.*(angularFrequencyWavelet > 0.);
    norm = sqrt(scaleA(k)*angularFrequencyWavelet(2))*(pi^(-0.25))*sqrt(point);
    fourierSpaceMotherWavelet(k,:) = norm*exp(expnt);
    fourierSpaceMotherWavelet(k,:) = fourierSpaceMotherWavelet(k,:).*(angularFrequencyWavelet > 0.);
end

figure('Name','Wavelet Transform Test','NumberTitle','off');
subplot(row,column,2);
for k = 1: perExec
    plot(frequencyFourier,fftshift(fourierSpaceMotherWavelet(k,:)),'DisplayName',strcat('Freq:',num2str(1/scaleA(k))));
    hold on;
end
title('Morlet Fourier Space');
title(legend('show'),'Wavelet Space Frequency');
xlabel('Frequency(Hz)');
ylabel('Magnitude');
xlim([min(frequencyFourier),max(frequencyFourier)]);

timeMotherWavelet = zeros(perExec,point);

subplot(row,column,1);
for k = 1: perExec
    timeMotherWavelet(k,:) = ifft((fourierSpaceMotherWavelet(k,:)),point);
    plot(time,real(fftshift(timeMotherWavelet(k,:))),'DisplayName',strcat('Freq:',num2str(1/scaleA(k))));
    hold on;
end
title('Morlet Time Space');
title(legend('show'),'Wavelet Space Frequency');
xlim([0,(point-1)*samplingPeriod]);
xlabel('Time(Sec)');


inputSignal = 2*sin(2*pi*0.55243*time)+2*sin(2*pi*6.25*time)+3*sin(2*pi*35*time.*(time>5.0));
subplot(row,column,3);
plot(time,inputSignal);
title('Input Signal Time Space');
xlabel('Time(Sec)');
xlim([0,(point-1)*samplingPeriod]);


freqInSig = fft(inputSignal,point);
subplot(row,column,4);
powerSpect = abs(fftshift(freqInSig)).^2/point;
plot(frequencyFourier,powerSpect);
findpeaks(powerSpect,frequencyFourier,'MinPeakHeight',100);

title('Input Signal Fourier Space');
xlabel('Frequency(Hz)');
ylabel('Magnitude');


xlim([min(frequencyFourier),max(frequencyFourier)]);
%Wavelet Transform
waveletSignal = ones(perExec,point);
waveletSignal = waveletSignal + waveletSignal * j;
for k = 1: perExec
    waveletSignal(k,:) = ifft(freqInSig.*fourierSpaceMotherWavelet(k,:)); 
end

waveletSignalPower = (abs(waveletSignal)).^2 ;
subplot(row,column,4);

strongFrequency = ones(frequencyPoint,point);
sentinel = -100;


for k = 1: point
    buffer = waveletSignalPower(:,k);
    for l = 1 : frequencyPoint
        [val,index] = max(buffer);
        strongFrequency(l,k) = frequencyWavelet(index);
        buffer(index) = sentinel;
    end
end

subplot(row,column,5);
for k = 1: frequencyPoint
    plot(time,strongFrequency(k,:),'DisplayName',strcat(iptnum2ordinal(k),'Freq'));
    hold on;
end
title('Strong Frequency Time Space');
xlabel('Time(Sec)');
ylabel('Frequency(Hz)');
legend('show');
xlim([0,(point-1)*samplingPeriod]);
