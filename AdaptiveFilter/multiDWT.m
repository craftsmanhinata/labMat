function [] = multiDWT(signal1,signal2,Fs,lowFreq)
%MULTIDWT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
wname = 'bior5.5';
level = abs(floor(log2(lowFreq/Fs)));
[coeff1,coeffLength1] = wavedec(signal1,level,wname);
plotDWTCoeff(coeff1,coeffLength1,wname,Fs);
[coeff2,coeffLength2] = wavedec(signal2,level,wname);
plotDWTCoeff(coeff2,coeffLength2,wname,Fs);
R = DWTCorr(coeff1,coeffLength1,coeff2,coeffLength2,wname);
end

