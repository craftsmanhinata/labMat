clear;
clc;

degree = 6;
point = 2^10;
startTime = -4;
endTime = 4;
time = linspace(-4,4,point);
samplingPeriod = time(2) - time(1);
samplingFrequency = 1 / samplingPeriod;

scaleA = 1;

motherWavelet = (pi^(- 0.25)) .* exp(j .* degree .* (time./scaleA)) .* exp(-(time./scaleA).^2 ./ 2) ./ sqrt(scaleA);

figure('Name','Mother Wavelet','NumberTitle','off');
plot(time,real(motherWavelet));

FFTRes = abs(fft(motherWavelet,point)).^2/point;
frequency = [1:fix(point/2)];
frequency = frequency .* ((2.*pi)/(point*samplingPeriod));
frequency = [0., frequency, -frequency(fix((point-1)/2):-1:1)];

fftWavelet = sqrt(scaleA*frequency(2))*(pi^(-0.25))*sqrt(point)*exp(-(scaleA.*frequency-degree).^2/2.*(frequency > 0.));
fftWavelet = fftWavelet .* (frequency > 0.);


figure('Name','FFT','NumberTitle','off');
shiftFrequency = fftshift(frequency);
FFTRes = fftshift(FFTRes);
plot(shiftFrequency,FFTRes);

figure('Name','Direct','NumberTitle','off');
fftWavelet = fftshift(fftWavelet);
plot(shiftFrequency,fftWavelet);

figure('Name','Difference','NumberTitle','off');
diff = fftWavelet - FFTRes;
plot(shiftFrequency,diff);