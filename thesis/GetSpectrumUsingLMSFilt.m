function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingLMSFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,LMSFilterLength,LMSStepSize)
%ESTIMATEHRUSINGLMSFILT NLMSアルゴリズムを用いて適応フィルタを実行し, スペクトルを得る関数
%   詳細説明をここに記述
LMSFilter = dsp.LMSFilter('Length',LMSFilterLength,'StepSize',LMSStepSize,'Method','Normalized LMS');
[~,adaptOutput] = LMSFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

