function [fractNumber] = str2Fract(fractStr)
%STR2FRACT ��������Œ菬���_�ɕϊ�
%   fixedpoint�c�[���{�b�N�X���Ђ悤
buf = sfi;
buf.hex = char(fractStr);
fractNumber = buf;

end

