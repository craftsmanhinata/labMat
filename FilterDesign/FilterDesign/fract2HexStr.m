function [cellString] = fract2HexStr(FractArray)
%FRACT2HEXSTR この関数の概要をここに記述
%   詳細説明をここに記述
cellString = cell(1,length(FractArray));
for index = 1:length(FractArray)
    var = FractArray(index);
    cellString{index} = cellstr(var.hex);
end
end

