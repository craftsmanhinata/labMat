function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingRLSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,RLSFilterLength,ForgettingFactor)
%ESTIMATEHRUSINGRLSFILT RLS�A���S���Y��(�Y�p�W����)��p���ăX�y�N�g���𓾂�֐�
%   �ڍא����������ɋL�q
RLSFilter = dsp.RLSFilter('Length',RLSFilterLength,'ForgettingFactor',ForgettingFactor);
[~,adaptOutput] = RLSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

