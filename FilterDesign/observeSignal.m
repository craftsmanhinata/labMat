function [microState] = observeSignal(microState)
%OBSERVE SIGNAL ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
microState = microState + observationNoiseReturn();
end

