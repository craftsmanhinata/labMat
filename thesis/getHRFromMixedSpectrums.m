function [estimateHeartRate] = getHRFromMixedSpectrums(spectrums,freq,freqRange,startHeartRate)
%GETHRFROMMIXEDSPECTRUMS この関数の概要をここに記述
%   詳細説明をここに記述

minFreq = min(freqRange);
maxFreq = max(freqRange);
freqIndex = intersect(find((freq >= minFreq)),find(freq <= maxFreq));
procFreq = freq(freqIndex);
procSpectrum = spectrums(freqIndex,:,:);
% figure();

searchFreq = startHeartRate / 60;
estimateHeartRate = ones(size(spectrums,2),1);
candEstimateHeartRate = ones(size(spectrums,2),size(spectrums,3));
for index = 1:size(spectrums,2)
    for spectrumIndex = 1:size(spectrums,3)
    %     plot(procFreq,procSpectrum(:,index));
        [pks,locs] = findpeaks(procSpectrum(:,index,spectrumIndex),procFreq,'SortStr','descend'...
            ,'NPeaks',5);
        if isempty(pks)
            candEstimateHeartRate(index,spectrumIndex) = 3 * 60;
        else
            estimateHeartRateIndex = knnsearch(locs,searchFreq);
            candEstimateHeartRate(index,spectrumIndex) = locs(estimateHeartRateIndex);
        end
    end
    estimateHeartRateIndex = knnsearch(candEstimateHeartRate(index,:)',searchFreq);
    estimateHeartRate(index) = candEstimateHeartRate(index,estimateHeartRateIndex);
    searchFreq = estimateHeartRate(index);
    %     hold on;
    %     plot(estimateHeartRate(index),pks(estimateHeartRateIndex),'ko');
    %     hold off;
end
end

