function [states] = stateConvTime(states)
%STATECONVTIME ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
dim = floor(length(states(:,1))/2);
[time,~] = stateDisassem(states(:,1));
time = timeConvToState(time);
timeIndex = 1:1:dim;
timeIndex = timeIndex * 2 - 1;
for index = 2:length(states)
    for dimIndex = 1: dim
        states(timeIndex(dimIndex),index) = time(dimIndex);
    end
end

