function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingRLSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,RLSFilterLength,ForgettingFactor)
%ESTIMATEHRUSINGRLSFILT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
RLSFilter = dsp.RLSFilter('Length',RLSFilterLength,'ForgettingFactor',ForgettingFactor);
[~,adaptOutput] = RLSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

