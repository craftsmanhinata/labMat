function [slideTime] = spectrumTimeSlidingEndTime(spectrumTime)
%SPECTRUMTIMESLIDINGENDTIME stftの返す時間は中間地点だがそれを終端にスライドさせる
%   
slideTime = spectrumTime + spectrumTime(1);
end

