function [noise] = systemNoiseReturn()
%SYSTEMNOISERETURN ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\systemNoisePd.mat');
noise = [0;random(systemNoisePd)];
end

