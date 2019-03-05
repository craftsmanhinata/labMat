function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingLMSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,LMSFilterLength,LMSStepSize)
%ESTIMATEHRUSINGLMSFILT NLMS�A���S���Y����p���ēK���t�B���^�����s��, �X�y�N�g���𓾂�֐�
%   �ڍא����������ɋL�q
LMSFilter = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptOutput] = LMSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

