function [states] = stateInConvTime(states)
%STATEINCONVTIME ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
dim = floor(length(states(:,1))/2);
[time,~] = stateDisassem(states(:,1));
time = timeConvToState(time);
Ts = time(2) - time(1);
timeIndex = 1:1:dim;
timeIndex = timeIndex * 2 - 1;
time = time + dim * Ts;
for index = 2:length(states)
    for dimIndex = 1: dim
        states(timeIndex(dimIndex),index) = time(dimIndex);
    end
    time = time + dim * Ts;
end
end

