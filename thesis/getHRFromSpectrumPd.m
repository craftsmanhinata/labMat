function [estimateHeartRate] = getHRFromSpectrumPd(spectrums,freq,freqRange,startHeartRate,Pd,percentage)
%GETPEAKSFROMSPECTRUM この関数の概要をここに記述
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
    end
    transitionHR = estimateHeartRate(index) * 60 - searchFreq * 60;
    probability = pdf(Pd,transitionHR);
    if(probability * 100 < percentage)
        estimateHeartRate(index) = searchFreq;
    end
    searchFreq = estimateHeartRate(index);

%     hold on;
%     plot(estimateHeartRate(index),pks(estimateHeartRateIndex),'ko');
%     hold off;
end
end

