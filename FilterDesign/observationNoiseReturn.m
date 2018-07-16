function [noise] = observationNoiseReturn()
%NOISERETURN この関数の概要をここに記述
% t と xは独立なので共分散を定義しない.
% state Vector [t x]
%load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\timeNoisePd.mat');
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\signalNoisePd.mat');
%noise = [random(timeNoisePd);random(signalNoisePd)];
noise = [0;random(signalNoisePd)];
end
