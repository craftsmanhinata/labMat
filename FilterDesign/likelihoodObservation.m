function [microStateWeight] = likelihoodObservation(microState)
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述
% microState = [t x]
%load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\timeNoisePd.mat');
load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\noiseData\signalNoisePd.mat');
%timeLikelihood = pdf(timeNoisePd,microState(1))/1000;
signalLikelihood = pdf(signalNoisePd,microState(2))/10000;
%microStateWeight = log(timeLikelihood) + log(signalLikelihood);
microStateWeight = log(signalLikelihood);
end

