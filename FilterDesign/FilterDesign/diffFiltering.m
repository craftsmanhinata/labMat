function [x,time] = diffFiltering(x,time,Fp,Fst,Ap,Ast)
%DIFFFILTERING この関数の概要をここに記述
%   詳細説明をここに記述
Ts = time(2) - time(1);
Fs = 1 / Ts;
D = fdesign.differentiator('Fp,Fst,Ap,Ast',Fp,...
    Fst,...
    Ap,...
    Ast);
M = designmethods(D);
Hd = design(D,cell2mat(M(1)));
delay = mean(grpdelay(Hd));

if isrow(x)
    x = filter(Hd,[x';zeros(delay,1)])*Fs;
else
    x = filter(Hd,[x;zeros(delay,1)])*Fs;
end
x = x(delay+1:end);
end

