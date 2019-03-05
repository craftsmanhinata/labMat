function [estimateHeartRate] = getHRFromMixedSpectrumsPd(spectrums,freq,freqRange,startHeartRate,Pd,percentage)
%GETHRFROMMIXEDSPECTRUMS �����̃X�y�N�g������S�����̐���, �y�ъm�����x�֐�����O��l�̏������s��, �S�����𐄒肷��֐�
%   �ڍא����������ɋL�q

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
            candEstimateHeartRate(index,spectrumIndex) = 69;
        else
            estimateHeartRateIndex = knnsearch(locs,searchFreq);
            candEstimateHeartRate(index,spectrumIndex) = locs(estimateHeartRateIndex);
        end
    end
    estimateHeartRateIndex = knnsearch(candEstimateHeartRate(index,:)',searchFreq);
    
    transitionHR = (candEstimateHeartRate(index,estimateHeartRateIndex) * 60 - searchFreq * 60);
    probability = pdf(Pd,transitionHR);
    if(probability * 100 < percentage)
        estimateHeartRate(index) = searchFreq;
    else
        estimateHeartRate(index) = candEstimateHeartRate(index,estimateHeartRateIndex);
    end
    searchFreq = estimateHeartRate(index);
    
   
    %     hold on;
    %     plot(estimateHeartRate(index),pks(estimateHeartRateIndex),'ko');
    %     hold off;
end
end

