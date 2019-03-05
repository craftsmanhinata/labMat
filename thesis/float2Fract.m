function fractNumber = float2Fract(floatNumber)
%float2Fract: This function conver float number to dsPIC's Fract(Q1.15 format).
%適当な英語で書いてありますが, ようするにQ1.15を単精度浮動小数点に直す関数です.
wordSize = 16;
decimalSize = 15;
fractNumber = sfi(floatNumber,wordSize,decimalSize);
end

