function [timeArray] = multiICWT(multiCWTArray,f,mean)
%MULTIICWT この関数の概要をここに記述
%   詳細説明をここに記述
cwtTimeBandWidth = 3.1;
[~,column,channel] = size(multiCWTArray);
timeArray = zeros(column,channel);
fMin = min(f);
fMax = max(f);
for channelIndex = 1:channel
    timeArray(:,channelIndex) = icwt(multiCWTArray(:,:,channelIndex),f,[fMin fMax],'TimeBandwidth',cwtTimeBandWidth,'SignalMean',mean(channelIndex));
end
end

