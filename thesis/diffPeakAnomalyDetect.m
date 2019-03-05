function [diffPks,anomalyPoint,anomalyLocs] = diffPeakAnomalyDetect(pks,locs,threshold)
%DIFFPEAK 閾値を元にピークの外れ値を検出する関数
%   詳細説明をここに記述
diffPks = diff(locs);
anomalyPoint = zeros(length(find(diffPks > threshold))*2,1);
anomalyLocs = zeros(length(find(diffPks > threshold))*2,1);
count = 1;
for index = 1:length(diffPks)
    if diffPks(index) >= threshold
        anomalyPoint(count) = pks(index);
        anomalyLocs(count) = locs(index);
        anomalyPoint(count+1) = pks(index+1);
        anomalyLocs(count+1) = locs(index+1);
        count = count + 2;
    end
end
end

