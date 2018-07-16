function [alignedX,alignedY] = forceAligned(X,Y)
%FORCEALIGNED この関数の概要をここに記述
%   詳細説明をここに記述
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

