clear;
clc;
pointNumber = 2^10;
adcBit = 12;
maxSamplingRate = 1110 * 10^3; %1100ksps
maxFs = 1 / maxSamplingRate;

%Time:Second
startTime = -4;
endTime = 4;
degree = 6;

time = [startTime:maxFs:endTime];

figure('Name','Mother Wavelet','NumberTitle','off');


for scaleA = 1:2
    %motherWavelet = (1 - (time./scaleA).^2).*exp(-1/2*(time./scaleA).^2) ./ sqrt(scaleA);%mexican hat
    motherWavelet = (pi.^-1/4) .* exp(1i .* degree .* (time./scaleA)) .* exp(-(time./scaleA).^2 ./ 2) ./ sqrt(scaleA); %Morlet 
    plot(time,real(motherWavelet));
    hold on;
end


%inputSignal = sin(2*pi*10*time);
%hold on;
%plot(time,inputSignal);

%fftCount = ceil(size(inputSignal,2) / pointNumber);
%frequencyData = zeros(1,fftCount);