function [downSampleArray] = downSampling(InputSample,scale,varargin)
%DOWNSAMPLING ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
index = 1;
switch nargin
    case 3
        index = ceil(cell2mat(varargin(1)));
end

count = 1;
downSampleArray = zeros([fix(length(InputSample)/scale) 1]);
while count<=length(downSampleArray)
    if index <= length(InputSample)
        downSampleArray(count) = InputSample(index);
    end
    index = index + scale;
    count = count + 1;
end
end

