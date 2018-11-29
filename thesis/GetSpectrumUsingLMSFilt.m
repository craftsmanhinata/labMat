function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingLMSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs)
%ESTIMATEHRUSINGLMSFILT この関数の概要をここに記述
%   詳細説明をここに記述
LMSFilterLength = 450;
LMSStepSize = 0.01;
LMSFilter = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptOutput] = LMSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

