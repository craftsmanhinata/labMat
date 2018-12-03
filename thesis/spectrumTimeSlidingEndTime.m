function [slideTime] = spectrumTimeSlidingEndTime(spectrumTime,Ts)
%SPECTRUMTIMESLIDINGENDTIME stftの返す時間は中間地点だがそれを終端にスライドさせる
%   
slideTime = spectrumTime + spectrumTime(1) - Ts;
end

