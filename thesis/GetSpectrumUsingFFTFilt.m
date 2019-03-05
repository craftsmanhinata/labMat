function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingFFTFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,FFTFilterLength,StepSize)
%ESTIMATEHRUSINGRLSFILT PFBLMS�A���S���Y����p���ēK���t�B���^�����s��, �X�y�N�g���𓾂�֐�
%   �ڍא����������ɋL�q
FFTFilter = dsp.FrequencyDomainAdaptiveFilter('Length',FFTFilterLength,...
    'StepSize',StepSize,'Method','Partitioned constrained FDAF');
[~,adaptOutput] = FFTFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

