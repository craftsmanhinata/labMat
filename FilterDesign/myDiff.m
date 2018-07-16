function [diffX,time] = myDiff(x,time,diffFiltFpass,FilterUsed)
%MYDIFF この関数の概要をここに記述
%   詳細説明をここに記述
if length(time) ~= 1
    Ts = time(2) - time(1);
    Fs = 1 / Ts;
    if FilterUsed
        diffFiltFstop = diffFiltFpass * 1.2;

        Ap = 1.0;
        adcBit = 12;
        maxVoltage = 3.3;
        minResVol = maxVoltage / (2^adcBit);
        stopBandMargin = 10;
        minResVoldb = db(minResVol)+stopBandMargin;
        margin = -2;
        minResVoldb = minResVoldb + margin;

        [diffX,time] = diffFiltering(x,time,diffFiltFpass/(Fs/2),...
            diffFiltFstop/(Fs/2),...
            Ap,...
            -1*minResVoldb);
    else
        diffX = Fs * diff(x);
        time = time(2:end);
    end
else
    diffX = x;
end

end

