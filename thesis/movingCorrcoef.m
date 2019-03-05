function [R,P,D] = movingCorrcoef(X,Y)
%MOVINGCORRCOEF "‘ŠŠÖŒW”"‚ðˆÚ“®‚µ‚È‚ª‚ç‹‚ß‚é
%   ‘ŠŠÖŒW”‚ÌÅ‘å’l‚Æ’x‰„, P’l‚ð•Ô‚·
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

