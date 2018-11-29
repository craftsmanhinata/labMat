function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingRLSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs)
%ESTIMATEHRUSINGRLSFILT この関数の概要をここに記述
%   詳細説明をここに記述
RLSFilterLength = 450;
RLSFilter = dsp.RLSFilter('Length',RLSFilterLength,'ForgettingFactor',1);
[~,adaptOutput] = RLSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

