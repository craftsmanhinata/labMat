function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingLMSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs)
%ESTIMATEHRUSINGLMSFILT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
LMSFilterLength = 450;
LMSStepSize = 0.01;
LMSFilter = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptOutput] = LMSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

