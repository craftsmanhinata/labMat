function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingRLSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,RLSFilterLength,ForgettingFactor)
%ESTIMATEHRUSINGRLSFILT RLSアルゴリズム(忘却係数つき)を用いてスペクトルを得る関数
%   詳細説明をここに記述
RLSFilter = dsp.RLSFilter('Length',RLSFilterLength,'ForgettingFactor',ForgettingFactor);
[~,adaptOutput] = RLSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

