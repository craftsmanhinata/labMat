function [matHex] = hex2Mathex(hex)
%HEX2MATHEX hex‚ğ“Ç‚İ‚ñ‚¾Û‚É‚Â‚­Ú“ª«‚Ì0x‚ğíœ‚·‚éŠÖ”
%   0x‚ğíœ‚·‚é
matHex = erase(hex,'0x');
end

