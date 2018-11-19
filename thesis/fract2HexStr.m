function [cellString] = fract2HexStr(FractArray)
%FRACT2HEXSTR 固定小数点を16進数の文字列に変換
%   固定小数点を16進数の文字列にする
cellString = cell(1,length(FractArray));
for index = 1:length(FractArray)
    var = FractArray(index);
    cellString{index} = cellstr(var.hex);
end
end

