function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingFFTFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,FFTFilterLength,StepSize)
%ESTIMATEHRUSINGRLSFILT この関数の概要をここに記述
%   詳細説明をここに記述
FFTFilter = dsp.FrequencyDomainAdaptiveFilter('Length',FFTFilterLength,...
    'StepSize',StepSize);
[~,adaptOutput] = FFTFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

