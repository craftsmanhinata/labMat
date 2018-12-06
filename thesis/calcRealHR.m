function [realHR] = calcRealHR(ECGTime,ECG,ProcTime,peakHeight,peakDistance,plotIs)
%CALCREALHR この関数の概要をここに記述
%   詳細説明をここに記述
procNum = length(ProcTime);
realHR = ones(procNum,1);
startTime = 0;
if plotIs
    figure();
    xlabel('Time(sec)');
end
for index = 1: procNum
    endTime = ProcTime(index);
    procTimeWidth = endTime - startTime;
    HRCoef = 60 / procTimeWidth;
    procIndex = intersect(find((ECGTime >= startTime)),find(ECGTime <= endTime));
    procECG = ECG(procIndex);
    procECGTime = ECGTime(procIndex);
    if plotIs
        plot(procECGTime,procECG);
    end
    [ECGPks,ECGPksTime] = findpeaks(procECG,procECGTime,'MinPeakHeight',peakHeight,'MinPeakDistance',peakDistance);
    if plotIs
        hold on;
        plot(ECGPksTime,ECGPks,'ko');
        hold off;
        drawnow;
        waitforbuttonpress;
    end
    startTime = endTime;
    realHR(index) = length(ECGPks) * HRCoef;
end

end

