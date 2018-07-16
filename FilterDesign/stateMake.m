function [states] = stateMake(dim,time,value)
%STATEMAKE この関数の概要をここに記述
%   詳細説明をここに記述 state = [t;x]
if isrow(time)
    time = time';
end
if isrow(value)
    value = value';
end
stateVector = zeros(dim * 2,1);
timeIndex = 1:1:dim;
timeIndex = timeIndex * 2 - 1;
valueIndex = 1:1:dim;
valueIndex = valueIndex * 2;
stateNum = floor(length(time)/dim);

states = zeros(dim * 2,stateNum);

for stateIndex = 1 : stateNum
   for dimIndex = 1:dim
       stateVector(timeIndex(dimIndex),1) = time(dimIndex+dim*(stateIndex-1));
       stateVector(valueIndex(dimIndex),1) = value(dimIndex+dim*(stateIndex-1));
   end
   states(:,stateIndex) = stateVector;
end

end

