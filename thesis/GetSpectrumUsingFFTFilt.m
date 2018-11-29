function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingFFTFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,FFTFilterLength,StepSize)
%ESTIMATEHRUSINGRLSFILT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
FFTFilter = dsp.FrequencyDomainAdaptiveFilter('Length',FFTFilterLength,...
    'StepSize',StepSize);
[~,adaptOutput] = FFTFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

