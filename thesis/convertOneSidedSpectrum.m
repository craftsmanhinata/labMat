function [oneSidedSpectrum] = convertOneSidedSpectrum(spectrum,FFTLength)
%CONVERTONESIDEDSPECTRUM STFT�̃f�[�^��Б��U���X�y�N�g���ɕϊ�����
%   �ڍא����������ɋL�q
oneSidedSpectrum = abs(spectrum/FFTLength);
oneSidedSpectrum(2:end-1,:) = 2 * oneSidedSpectrum(2:end-1,:);
end

