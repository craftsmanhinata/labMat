function [RandState] = randSampling(microState)
%RANDSAMPLING ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
% microState = [t x]
RandState = microState + systemNoiseReturn();
end

