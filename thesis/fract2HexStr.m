function [cellString] = fract2HexStr(FractArray)
%FRACT2HEXSTR �Œ菬���_��16�i���̕�����ɕϊ�
%   �Œ菬���_��16�i���̕�����ɂ���
cellString = cell(1,length(FractArray));
for index = 1:length(FractArray)
    var = FractArray(index);
    cellString{index} = cellstr(var.hex);
end
end

