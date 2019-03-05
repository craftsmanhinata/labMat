function [estimateHeartRate] = getHRFromSpectrum(spectrums,freq,freqRange,startHeartRate)
%GETPEAKSFROMSPECTRUM スペクトルから心拍数を推定する
%   詳細説明をここに記述

minFreq = min(freqRange);
maxFreq = max(freqRange);
freqIndex = intersect(find((freq >= minFreq)),find(freq <= maxFreq));
procFreq = freq(freqIndex);
procSpectrum = spectrums(freqIndex,:);
% figure();

searchFreq = startHeartRate / 60;
estimateHeartRate = ones(size(spectrums,2),1);

for index = 1:size(spectrums,2)
%     plot(procFreq,procSpectrum(:,index));
    [pks,locs] = findpeaks(procSpectrum(:,index),procFreq,'SortStr','descend','NPeaks',5);
    if isempty(pks)
        estimateHeartRate(index) = searchFreq;
    else
        estimateHeartRateIndex = knnsearch(locs,searchFreq);
        estimateHeartRate(index) = locs(estimateHeartRateIndex);
        searchFreq = estimateHeartRate(index);
    end
%     hold on;
%     plot(estimateHeartRate(index),pks(estimateHeartRateIndex),'ko');
%     hold off;
end
end

