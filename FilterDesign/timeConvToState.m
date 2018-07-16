function [stateTime] = timeConvToState(recordTime)
%TIMECONV この関数の概要をここに記述
%   詳細説明をここに記述
Ts = recordTime(2) - recordTime(1);
stateTime = (0:1:length(recordTime)-1)'*Ts;
end

