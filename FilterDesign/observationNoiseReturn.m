function [noise] = observationNoiseReturn()
%NOISERETURN ���̊֐��̊T�v�������ɋL�q
% t �� x�͓Ɨ��Ȃ̂ŋ����U���`���Ȃ�.
% state Vector [t x]
%load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\timeNoisePd.mat');
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\signalNoisePd.mat');
%noise = [random(timeNoisePd);random(signalNoisePd)];
noise = [0;random(signalNoisePd)];
end
