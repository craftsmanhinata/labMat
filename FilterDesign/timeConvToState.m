function [stateTime] = timeConvToState(recordTime)
%TIMECONV ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
Ts = recordTime(2) - recordTime(1);
stateTime = (0:1:length(recordTime)-1)'*Ts;
end

