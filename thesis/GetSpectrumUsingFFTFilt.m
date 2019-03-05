function [adaptOutputSpectrum,adaptOutput] = GetSpectrumUsingFFTFilt(inputX,desiredSignal,FFTLength,Overlap,...
    Fs,FFTFilterLength,StepSize)
%ESTIMATEHRUSINGRLSFILT PFBLMSアルゴリズムを用いて適応フィルタを実行し, スペクトルを得る関数
%   詳細説明をここに記述
FFTFilter = dsp.FrequencyDomainAdaptiveFilter('Length',FFTFilterLength,...
    'StepSize',StepSize,'Method','Partitioned constrained FDAF');
[~,adaptOutput] = FFTFilter(inputX,desiredSignal);
[adaptOutputSpectrum,~,~] = spectrogram(adaptOutput,hann(FFTLength),Overlap,FFTLength,Fs); 
adaptOutputSpectrum = convertOneSidedSpectrum(adaptOutputSpectrum,FFTLength);

end

