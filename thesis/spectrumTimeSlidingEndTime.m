function [slideTime] = spectrumTimeSlidingEndTime(spectrumTime)
%SPECTRUMTIMESLIDINGENDTIME stft�̕Ԃ����Ԃ͒��Ԓn�_����������I�[�ɃX���C�h������
%   
slideTime = spectrumTime + spectrumTime(1);
end

