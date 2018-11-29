function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingFFTFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs)
%ESTIMATEHRUSINGRLSFILT この関数の概要をここに記述
%   詳細説明をここに記述
FFTFilterLength = 300;
FFTFilterBlockLength = 100;
StepSize = 0.01;
FFTFilter = dsp.FrequencyDomainAdaptiveFilter('Length',FFTFilterLength,'BlockLength',FFTFilterBlockLength,...
    'StepSize',StepSize);
[~,adaptOutput] = FFTFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

