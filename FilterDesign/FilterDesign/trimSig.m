function [time,signal] = trimSig(time,signal,startTime,endTime)
%TRIMSIG ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
startID = knnsearch(time,startTime);
endID = knnsearch(time,endTime);
signal = signal(startID:endID);
Ts = time(2) - time(1);
time = (0:1:length(signal)-1)'*Ts;

end

