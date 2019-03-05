function [R,P,D] = movingCorrcoef(X,Y)
%MOVINGCORRCOEF "相関係数"を移動しながら求める
%   相関係数の最大値と遅延, P値を返す
if length(X) > length(Y)
    shorterSignal = Y;
    longerSignal = X;
else
    shorterSignal = X;
    longerSignal = Y;
end
signalLength = length(shorterSignal);
index = 0;
maxR = -1*ones(2,2);
returnP = 0;
D = 0;
while (index+signalLength <= length(longerSignal))
    [R,P] = corrcoef(shorterSignal,longerSignal(1+index:index+signalLength));
    index = index + 1;
    if R(1,2)>maxR(1,2)
        maxR = R;
        returnP = P;
        D = index;
    end
end
R = maxR;
P = returnP;
end

