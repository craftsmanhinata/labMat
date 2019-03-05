function fractNumber = float2Fract(floatNumber)
%float2Fract: This function conver float number to dsPIC's Fract(Q1.15 format).
%�K���ȉp��ŏ����Ă���܂���, �悤�����Q1.15��P���x���������_�ɒ����֐��ł�.
wordSize = 16;
decimalSize = 15;
fractNumber = sfi(floatNumber,wordSize,decimalSize);
end

