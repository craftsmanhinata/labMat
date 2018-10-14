function [reconstructionSignal] = reconstructFromCoeffs(wname,coeffMatrix,scales,samplingPeriod,VoicesPerOctave)
%RECONSTRUCTFROMCOEFFS 係数から信号を再構成する.疑似的な逆変換を行う.
%   詳細説明をここに記述

%スケール列からスケーリングのための定数の計算
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

%ウェーブレットのt = 0時の振幅を観測
prec = 15;
[psi,time] = wavefun(wname,prec);
maxAmp = abs(psi(knnsearch(time',0)));

%CDeltaは再構成の様子を見ながら変更する
%ex: CDelta = 1.996(DOG m = 6)
CDelta = getNormalizationConstantDelta(wname,samplingPeriod,VoicesPerOctave,maxAmp);

reconstructionSignal = sum(real(coeffMatrix).*scalingCoeffs);
reconstructionSignal = reconstructionSignal * (sqrt(samplingPeriod) / VoicesPerOctave / maxAmp / CDelta);
end

