function [fractNumber] = str2Fract(fractStr)
%STR2FRACT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
buf = sfi;
buf.hex = char(fractStr);
fractNumber = buf;

end

