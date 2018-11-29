function [peakFreq] = coheFindPeak(F,Cxy,coheFreqRange)
%COHEFINDPEAK ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
minFreq = min(coheFreqRange);
maxFreq = max(coheFreqRange);
procIndex = intersect(find((F >= minFreq)),find(F <= maxFreq));
procFreq = F(procIndex);
procCohe = Cxy(procIndex);
[~,peakFreq]= findpeaks(procCohe,procFreq,'SortStr','descend','NPeaks',1);

end
