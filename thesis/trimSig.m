function [trimSig] = trimSig(signal,Fs,procTime)
%TRIMSIG �M�����w��b�����Ƀg��������
%   �ڍא����������ɋL�q
Ts = 1 / Fs;
procPoint = procTime / Ts;
trimSig = signal(1:procPoint);
end

