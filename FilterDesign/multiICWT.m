function [timeArray] = multiICWT(multiCWTArray,f,mean)
%MULTIICWT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
cwtTimeBandWidth = 3.1;
[~,column,channel] = size(multiCWTArray);
timeArray = zeros(column,channel);
fMin = min(f);
fMax = max(f);
for channelIndex = 1:channel
    timeArray(:,channelIndex) = icwt(multiCWTArray(:,:,channelIndex),f,[fMin fMax],'TimeBandwidth',cwtTimeBandWidth,'SignalMean',mean(channelIndex));
end
end

