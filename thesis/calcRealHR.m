function [realHR] = calcRealHR(ECGTime,ECG,ProcTime)
%CALCREALHR ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q

procNum = length(ProcTime);
realHR = ones(procNum,1);
startTime = 0;
% figure();
for index = 1: procNum
    endTime = ProcTime(index);
    procTimeWidth = endTime - startTime;
    HRCoef = 60 / procTimeWidth;
    procIndex = intersect(find((ECGTime >= startTime)),find(ECGTime <= endTime));
    procECG = ECG(procIndex);
    procECGTime = ECGTime(procIndex);
%     plot(procECGTime,procECG);
    [ECGPks,ECGPksTime] = findpeaks(procECG,procECGTime,'MinPeakHeight',0.03,'MinPeakDistance',0.3);
%     hold on;
%     plot(ECGPksTime,ECGPks,'ko');
%     hold off;
    startTime = endTime;
    realHR(index) = length(ECGPks) * HRCoef;
end

end

