function [CDelta] = getNormalizationConstantDelta(wname, samplingPeriod,VoicesPerOctave, maxAmp)
%GETNORMALIZATIONCONSTANTDELTA ウェーブレットに対して正規化定数を計算する
%   詳細説明をここに記述

minFreq = 0.01; %定数値. 小さくするほど計算精度が向上する(かもしれない)
maxFreq = 1 / samplingPeriod / 2; %ナイキスト周波数の計算

scales = scalesAutoSet(wname,samplingPeriod,[minFreq maxFreq],VoicesPerOctave);

%デルタ関数をウェーブレット変換する
[coeffs, ~] = cwt(1, scales, wname, samplingPeriod);

%スケール列からスケーリングのための定数の計算
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

CDelta = sum(real(coeffs).*scalingCoeffs);
CDelta = CDelta * sqrt(samplingPeriod) / VoicesPerOctave / maxAmp;
disp(CDelta)
end

