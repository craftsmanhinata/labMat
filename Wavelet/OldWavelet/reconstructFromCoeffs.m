function [reconstructionSignal] = reconstructFromCoeffs(wname,coeffMatrix,scales,samplingPeriod,VoicesPerOctave)
%RECONSTRUCTFROMCOEFFS �W������M�����č\������.�^���I�ȋt�ϊ����s��.
%   �ڍא����������ɋL�q

%�X�P�[���񂩂�X�P�[�����O�̂��߂̒萔�̌v�Z
scalingCoeffs = sqrt(scales).^-1;
if isrow(scalingCoeffs)
    scalingCoeffs = transpose(scalingCoeffs);
end

%�E�F�[�u���b�g��t = 0���̐U�����ϑ�
prec = 15;
[psi,time] = wavefun(wname,prec);
maxAmp = abs(psi(knnsearch(time',0)));

%CDelta�͍č\���̗l�q�����Ȃ���ύX����
%ex: CDelta = 1.996(DOG m = 6)
CDelta = getNormalizationConstantDelta(wname,samplingPeriod,VoicesPerOctave,maxAmp);

reconstructionSignal = sum(real(coeffMatrix).*scalingCoeffs);
reconstructionSignal = reconstructionSignal * (sqrt(samplingPeriod) / VoicesPerOctave / maxAmp / CDelta);
end

