function fractNumber = float2Fract(floatNumber)
%float2Fract: This function conver float number to dsPIC's Fract(Q1.15 format).
%
wordSize = 16;
decimalSize = 15;
fractNumber = sfi(floatNumber,wordSize,decimalSize);
end

