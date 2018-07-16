function [timeArray,valueArray] = stateMatToArray(stateMat)
%STATEMATTOARRAY この関数の概要をここに記述
%   詳細説明をここに記述
dim = floor(length(stateMat(:,1)) / 2);
timeArrayLength = length(stateMat) * dim;
valueArrayLength = timeArrayLength;
valueArray = zeros(valueArrayLength,1);
valueIndex =  1:1:dim;
valueIndex = valueIndex * 2;
Ts = stateMat(valueIndex(2)-1,1) - stateMat(valueIndex(1)-1,1);
timeArray = (0:1:timeArrayLength-1)';
timeArray = timeArray * Ts;
for index = 1:valueArrayLength
    column = ceil(index/dim);
    arrayIndex = mod(index,dim);
    if arrayIndex == 0
        arrayIndex = dim;
    end
    valueArray(index) = stateMat(valueIndex(arrayIndex),column);
end
end

