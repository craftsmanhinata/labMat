function [time,signal] = trimSig(time,signal,startTime,endTime)
%TRIMSIG この関数の概要をここに記述
%   詳細説明をここに記述
startID = knnsearch(time,startTime);
endID = knnsearch(time,endTime);
signal = signal(startID:endID);
Ts = time(2) - time(1);
time = (0:1:length(signal)-1)'*Ts;

end

