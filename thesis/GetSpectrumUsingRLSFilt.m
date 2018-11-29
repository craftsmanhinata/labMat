function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingRLSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs)
%ESTIMATEHRUSINGRLSFILT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
RLSFilterLength = 450;
RLSFilter = dsp.RLSFilter('Length',RLSFilterLength,'ForgettingFactor',1);
[~,adaptOutput] = RLSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

