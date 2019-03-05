function [peakFreq] = coheFindPeak(F,Cxy,coheFreqRange)
%COHEFINDPEAK �X�y�N�g���R�q�[�����X��Ńs�[�N��T���֐�
%   �ڍא����������ɋL�q
minFreq = min(coheFreqRange);
maxFreq = max(coheFreqRange);
procIndex = intersect(find((F >= minFreq)),find(F <= maxFreq));
procFreq = F(procIndex);
procCohe = Cxy(procIndex);
[~,peakFreq]= findpeaks(procCohe,procFreq,'SortStr','descend','NPeaks',1);
maxFreq = peakFreq;
procIndex = intersect(find((F >= minFreq)),find(F <= maxFreq));
procFreq = F(procIndex);
procCohe = Cxy(procIndex);
[~,minPeakFreq]= findpeaks(-procCohe,procFreq);
freqIndex = knnsearch(minPeakFreq,peakFreq);
peakFreq = minPeakFreq(freqIndex);
end

