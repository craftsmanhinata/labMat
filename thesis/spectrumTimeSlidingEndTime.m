function [slideTime] = spectrumTimeSlidingEndTime(spectrumTime,Ts)
%SPECTRUMTIMESLIDINGENDTIME stft�̕Ԃ����Ԃ͒��Ԓn�_����������I�[�ɃX���C�h������
%   
slideTime = spectrumTime + spectrumTime(1) - Ts;
end

