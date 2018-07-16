function [instFreq,time] = instFreqProc(x,time,diffFiltFpass,FilterUsed)
%UNTITLED ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q

Ts = time(2) - time(1);
Fs = 1 / Ts;
x = hilbert(x);

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

    [instFreq,time] = diffFiltering(unwrap(angle(x)),time,diffFiltFpass/(Fs/2),...
        diffFiltFstop/(Fs/2),...
        Ap,...
        -1*minResVoldb);
else
    instFreq = Fs * diff(unwrap(angle(x)));
    time = time(2:end);
end
instFreq = instFreq / (2 * pi);
