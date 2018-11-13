function [matHex] = hex2Mathex(hex)
%HEX2MATHEX hexを読み込んだ際につく接頭辞の0xを削除する関数
%   0xを削除する
matHex = erase(hex,'0x');
end

