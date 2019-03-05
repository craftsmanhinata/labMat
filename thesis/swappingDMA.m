function [responseDMA] = swappingDMA(data,count)
%SWAPPINGDMA データを交換していく
%   詳細説明をここに記述

loopCount = floor(length(data) / count);
if rem(loopCount,2) == 1
    loopCount = loopCount - 1;
end
responseDMA = zeros(loopCount * count ,1);
loopCount = loopCount / 2;
offset = 1;
for index = 1 : loopCount
    responseDMA(offset:offset+count-1) = data(offset+count:offset+(count*2)-1);
    responseDMA(offset+count:offset+(count*2)-1) = data(offset:offset+count-1);
    offset = offset + count * 2;
end

