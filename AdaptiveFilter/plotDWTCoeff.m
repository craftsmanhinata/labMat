function [] = plotDWTCoeff(coeff,coeffLength,wname,Fs)
%PLOTDWTCOEFF この関数の概要をここに記述
%   詳細説明をここに記述
level = length(coeffLength) - 2;
figure;
plotNum = level + 1;

approx = appcoef(coeff,coeffLength,wname);
subplot(plotNum,1,1);
plot(approx);
title(strcat('Approximation Coefficients:',num2str(Fs*power(0.5,level)),'Hz LPF'));

for index = 0:plotNum - 2
    cd = detcoef(coeff,coeffLength,level-index);
    subplot(plotNum,1,index+2);
    plot(cd);
    title(strcat('Level',num2str(level-index),' Detail Coefficients:',...
        num2str(Fs*power(0.5,level-index)),'Hz HPF'));
end
end

