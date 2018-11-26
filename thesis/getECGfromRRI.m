function [alignedRRI,outputECG] = getECGfromRRI(ECGData,RRI,PI,ECGPksTime,delay,Fs)
%GETECGFROMRRI RRIからECGを復元する関数
%
alignedRRI = RRI(delay:delay+length(PI)-1);
startTime = ECGPksTime(delay);
endTime = ECGPksTime(length(alignedRRI)+delay-1);
Ts = 1/ Fs;
outputECG = ECGData(startTime/Ts:endTime/Ts);
end

