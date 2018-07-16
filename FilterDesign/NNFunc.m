function [outputSignal] = NNFunc(input)
%NNFUNC この関数の概要をここに記述
%   詳細説明をここに記述
% load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\NNPPG\HiddenBias.mat');
% load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\NNPPG\HiddenWeight.mat');
% load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\NNPPG\OutputBias.mat');
% load('C:\Users\tsuwgawa_lab\Documents\MATLAB\FilterDesign\NNPPG\OutputWeight.mat');
HiddenWeight = -0.337576835541417;
HiddenBias = -0.020335617685851;
OutputWeight = {};
OutputBias = -0.057931432068344;
signalLength = length(input);
outputSignal = zeros(signalLength,1);
hiddenOutput = zeros(length(HiddenBias),1);

for signalIndex = 1 : signalLength
    for index = 1:length(HiddenBias)
        hiddenOutput(index) = HiddenWeight(index)*input(signalIndex)+HiddenBias(index);
    end

    
    if isempty(OutputWeight)
        output = purelin(tansig(sum(hiddenOutput))+OutputBias);
    else
        for index = 1:length(HiddenBias)
            output = purelin(tansig(sum(hiddenOutput))*OutputWeight(index)+OutputBias);
        end
    end
    outputSignal(signalIndex) = output;
end