function [cellString] = fract2HexStr(FractArray)
%FRACT2HEXSTR ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
cellString = cell(1,length(FractArray));
for index = 1:length(FractArray)
    var = FractArray(index);
    cellString{index} = cellstr(var.hex);
end
end

