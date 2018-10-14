function [CDelta] = getNormalizationConstantDelta(wname, samplingPeriod,VoicesPerOctave, maxAmp)
%GETNORMALIZATIONCONSTANTDELTA �E�F�[�u���b�g�ɑ΂��Đ��K���萔���v�Z����
%   �ڍא����������ɋL�q
minFreq = 0.1;
maxFreq = 1 / samplingPeriod / 2; %�i�C�L�X�g���g���̌v�Z
scales = scalesAutoSet(wname,samplingPeriod,[minFreq maxFreq],VoicesPerOctave);


% WaveletPoint = samplingPeriod^(-1)*100;
% %�X�P�[��1�̎��g�����v�Z����
% scaleOneFreq = scal2frq(1,wname,samplingPeriod); 
% %�X�P�[��1�̎��g��������g��-�X�P�[���Ԃ̊֌W�̐���
% minScale =  scaleOneFreq / maxFreq;
% scaleNum = ceil(VoicesPerOctave * log2(WaveletPoint*samplingPeriod/minScale));
% scales = minScale * 2 .^ (VoicesPerOctave.^-1 * (0:1:scaleNum - 1));

%�f���^�֐����E�F�[�u���b�g�ϊ�����
coeffs = cwt(1, scales, wname);

%�X�P�[���񂩂�X�P�[�����O�̂��߂̒萔�̌v�Z
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

CDelta = sum(real(coeffs).*scalingCoeffs);
CDelta = mean(CDelta .* sqrt(samplingPeriod) ./ VoicesPerOctave ./ maxAmp);
end

