function [estimateState] = weightedAve(particleArray,particleWeight)
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述
stateLength = length(particleArray(:,1));
estimateState = zeros(stateLength,1);
particleNumber = length(particleWeight);

%estimateTime = (0:1:floor(stateLength/2))';
timeIndex = (0:1:floor(stateLength/2)-1)';
timeIndex = timeIndex*2+1;
Ts = particleArray(timeIndex(2),1) - particleArray(timeIndex(1),1);
for stateIndex = 1:length(estimateState)/2
    estimateState(timeIndex(stateIndex)) = Ts*(stateIndex-1);
end
signalIndex = (1:1:floor(stateLength/2))';
signalIndex = signalIndex * 2;
for stateIndex = 1:length(estimateState)/2
    for particleIndex = 1:particleNumber
        estimateState(signalIndex(stateIndex)) = estimateState(signalIndex(stateIndex)) + (particleWeight(particleIndex))*(particleArray(signalIndex(stateIndex),particleIndex));
    end
end

end
