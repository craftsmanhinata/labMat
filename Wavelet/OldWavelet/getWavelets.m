function [] = getWavelets(wname,scales,samplingFreq)
%UNTITLED �X�P�[���ϒ������E�F�[�u���b�g��plot����֐�
%   �ڍא����������ɋL�q
WT_Check_1 = 5; % WT��5�̂Ƃ�, �X�P�[�����O�֐�(�t�@�U�[�E�F�[�u���b�g)���܂܂Ȃ����f�E�F�[�u���b�g�ł���
WT_Check_2 = 4; % WT��4�̂Ƃ�, �X�P�[�����O�֐�(�t�@�U�[�E�F�[�u���b�g)���܂܂Ȃ������E�F�[�u���b�g�ł���
precis = 10; %�v�Z���x.wave�̒����𐧌䂷��. wave����2^precis

figure();

WT = wavemngr('type',wname);
if(WT_Check_1 ~= WT)&&(WT_Check_2 ~= WT)
    msgID = 'GETWAVELET:InvalidWaveletmae';
    msg = strcat(wname,'�͂��̊֐��Ŏg�p�ł��Ȃ��E�F�[�u���b�g�ł�.');
    baseException = MException(msgID,msg);
    throw(baseException)
end
[Wave,timeWave] = wavefun(wname,precis);
%�E�F�[�u���b�g�̃T���v�����O�����̌v�Z
WaveSamplingPeriod = timeWave(2) - timeWave(1);
%�E�F�[�u���b�g�̃V�t�g. t = 0�Ŕg�`���n�܂�悤��.
timeWave = timeWave - timeWave(1);
%�E�F�[�u���b�g���I��鎞�����L�^.
EndTime = timeWave(end);
for scaleIndex = 1 : length(scales)
    %�E�F�[�u���b�g�̃X�P�[���W��a�̎擾
    scaleCoeffA = scales(scaleIndex);
    waveIndex = 1 + floor((0:scaleCoeffA*EndTime)/...
        (scaleCoeffA*WaveSamplingPeriod));
    wavelet = 1/sqrt(scaleCoeffA) * Wave(waveIndex);
    waveletTime = timeWave(waveIndex)*scaleCoeffA-(EndTime / 2 * (scaleCoeffA - 1));
    %[resampleWavelet,resampleWaveletTime] = resample(wavelet,waveletTime,samplingFreq,'spline');
    
    %
    %plot(resampleWaveletTime,real(resampleWavelet));
    %hold on;
    plot(waveletTime,real(wavelet));
    hold on;
end

end

