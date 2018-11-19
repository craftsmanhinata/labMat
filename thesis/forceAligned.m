function [alignedX,alignedY] = forceAligned(X,Y)
%FORCEALIGNED データの点数を強制的に揃える関数
%   入力x,yを相関を元に揃える
if length(X) > length(Y)
    shorterSignal = Y;
    longerSignal = X;
    LongerSigIsX = true;
else
    shorterSignal = X;
    longerSignal = Y;
    LongerSigIsX = false;
end
delay = finddelay(shorterSignal-mean(shorterSignal),longerSignal-mean(longerSignal));

if LongerSigIsX
    if delay < 0
        alignedX = X(1:length(shorterSignal)-abs(delay));
    else
        alignedX = X(delay+1:length(shorterSignal));
    end
else
    if delay < 0
        alignedX = X(abs(delay)+1:end);
    else
        alignedX = X(delay+1:end);
    end
end

if LongerSigIsX
    if delay < 0
        alignedY = Y(abs(delay)+1:end);
    else
        alignedY = Y(delay+1:end);
    end
else
    if delay < 0
        alignedY = Y(1:length(shorterSignal)-abs(delay));
    else
        alignedY = Y(delay+1:length(shorterSignal));
    end
end
end

