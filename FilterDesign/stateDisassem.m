function [time,value] = stateDisassem(state)
%STATE この関数の概要をここに記述
%   詳細説明をここに記述
dim = floor(length(state)/2);
time = zeros(dim,1);
value = zeros(dim,1);

timeIndex = 1:1:dim;
timeIndex = timeIndex * 2 - 1;
valueIndex = 1:1:dim;
valueIndex = valueIndex * 2;

for dimIndex = 1:dim
    time(dimIndex) = state(timeIndex(dimIndex));
    value(dimIndex) = state(valueIndex(dimIndex));
end
end

