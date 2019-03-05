function [trimSig] = trimSig(signal,Fs,procTime)
%TRIMSIG 信号を指定秒数分にトリムする
%   詳細説明をここに記述
Ts = 1 / Fs;
procPoint = procTime / Ts;
trimSig = signal(1:procPoint);
end

