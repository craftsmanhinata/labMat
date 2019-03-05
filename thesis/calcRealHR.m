function [realHR] = calcRealHR(ECGTime,ECG,ProcTime,peakHeight,peakDistance,plotIs)
%CALCREALHR ECG‚©‚çS””‚Ì„ˆÚ‚ð‹‚ß‚éŠÖ”
%   Ú×à–¾‚ð‚±‚±‚É‹Lq
procNum = length(ProcTime);
realHR = ones(procNum,1);
startTime = 0;
if plotIs
    figure();
end
overlapTime = ProcTime(2) - ProcTime(1);
for index = 1: procNum
    endTime = ProcTime(index);
    procTimeWidth = endTime - startTime;
    HRCoef = 60 / procTimeWidth;
    procIndex = intersect(find((ECGTime >= startTime)),find(ECGTime <= endTime));
    procECG = ECG(procIndex);
    procECGTime = ECGTime(procIndex);
    if plotIs
        FontSize = 20;
        plot(procECGTime,procECG);
        ylabel('Voltage(\muV)','FontSize',FontSize);
        xlabel('Time(sec.)','FontSize',FontSize);
        xlim([startTime endTime]);
    end
    [ECGPks,ECGPksTime] = findpeaks(procECG,procECGTime,'MinPeakHeight',peakHeight,'MinPeakDistance',peakDistance);
    if plotIs
        hold on;
        plot(ECGPksTime,ECGPks,'ko');
        hold off;
        drawnow;
        set(gca,'FontSize',FontSize);
        waitforbuttonpress;
    end
    startTime = endTime - overlapTime;
    realHR(index) = length(ECGPks) * HRCoef;
end

end

