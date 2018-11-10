function [scale] = scalesAutoSet(wname,samplingPeriod,freqRange,voicesPerOctave)
%SCALESAUTOSET スケールaを自動生成する
%   詳細説明をここに記述

if ~ isrow(freqRange) && ~ iscolumn(freqRange)
    msgID = 'SCALEAUTOSET:InvalidArgument';
    msg = strcat('引数freqRangeはベクトルである必要があります.');
    baseException = MException(msgID,msg);
    throw(baseException)
end

%解析周波数の最高周波数の計算.
maxFrequency = 1 / samplingPeriod / 2; %デフォルトはナイキスト周波数
if max(freqRange) < maxFrequency
    maxFrequency = max(freqRange);
end

%スケール1の周波数を計算する
scaleOneFreq = scal2frq(1,wname,samplingPeriod); 
%スケール1の周波数から周波数-スケール間の関係の推定
minScale =  scaleOneFreq / maxFrequency;
maxScale =  scaleOneFreq / min(freqRange);

scaleStepParam = 1 / voicesPerOctave;


%5
scaleNum = ceil(voicesPerOctave * log2(maxScale/minScale));

scale = minScale * 2 .^ (scaleStepParam * (0:1:scaleNum - 1));

end

