function [CDelta] = getNormalizationConstantDelta(wname, samplingPeriod,VoicesPerOctave, maxAmp)
%GETNORMALIZATIONCONSTANTDELTA �E�F�[�u���b�g�ɑ΂��Đ��K���萔���v�Z����
%   �ڍא����������ɋL�q

minFreq = 0.01; %�萔�l. ����������قǌv�Z���x�����シ��(��������Ȃ�)
maxFreq = 1 / samplingPeriod / 2; %�i�C�L�X�g���g���̌v�Z

scales = scalesAutoSet(wname,samplingPeriod,[minFreq maxFreq],VoicesPerOctave);

%�f���^�֐����E�F�[�u���b�g�ϊ�����
[coeffs, ~] = cwt(1, scales, wname, samplingPeriod);

%�X�P�[���񂩂�X�P�[�����O�̂��߂̒萔�̌v�Z
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

CDelta = sum(real(coeffs).*scalingCoeffs);
CDelta = CDelta * sqrt(samplingPeriod) / VoicesPerOctave / maxAmp;
disp(CDelta)
end

