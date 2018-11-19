function [fractNumber] = str2Fract(fractStr)
%STR2FRACT 文字列を固定小数点に変換
%   fixedpointツールボックスがひつよう
buf = sfi;
buf.hex = char(fractStr);
fractNumber = buf;

end

