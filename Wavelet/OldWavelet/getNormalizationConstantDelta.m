function [CDelta] = getNormalizationConstantDelta(wname, samplingPeriod,VoicesPerOctave, maxAmp)
%GETNORMALIZATIONCONSTANTDELTA ウェーブレットに対して正規化定数を計算する
%   詳細説明をここに記述
minFreq = 0.1;
maxFreq = 1 / samplingPeriod / 2; %ナイキスト周波数の計算
scales = scalesAutoSet(wname,samplingPeriod,[minFreq maxFreq],VoicesPerOctave);


% WaveletPoint = samplingPeriod^(-1)*100;
% %スケール1の周波数を計算する
% scaleOneFreq = scal2frq(1,wname,samplingPeriod); 
% %スケール1の周波数から周波数-スケール間の関係の推定
% minScale =  scaleOneFreq / maxFreq;
% scaleNum = ceil(VoicesPerOctave * log2(WaveletPoint*samplingPeriod/minScale));
% scales = minScale * 2 .^ (VoicesPerOctave.^-1 * (0:1:scaleNum - 1));

%デルタ関数をウェーブレット変換する
coeffs = cwt(1, scales, wname);

%スケール列からスケーリングのための定数の計算
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

CDelta = sum(real(coeffs).*scalingCoeffs);
CDelta = mean(CDelta .* sqrt(samplingPeriod) ./ VoicesPerOctave ./ maxAmp);
end

