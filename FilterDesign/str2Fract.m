function [fractNumber] = str2Fract(fractStr)
%STR2FRACT この関数の概要をここに記述
%   詳細説明をここに記述
buf = sfi;
buf.hex = char(fractStr);
fractNumber = buf;

end

