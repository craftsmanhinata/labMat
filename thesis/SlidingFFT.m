function [freq,stftDatas,time] = SlidingFFT(signal,Fs,FFTLength,Overlap)
%SLIDINGFFT FFT���I�[�o�[���b�v���Ȃ��炩���Ă���, �Б��U���X�y�N�g����Ԃ�
%   FFT�ɂ̓n�~���O�����g�p.

disp(strcat('�ݒ肳�ꂽ���g������\:',num2str(Fs/FFTLength)));

offset = 1;
signalLength = length(signal);
newSignalLength = FFTLength - Overlap;
if newSignalLength < 0
    %�G���[
end
procNum = floor((signalLength)/newSignalLength) - 1;
hammingWindow = hamming(FFTLength);
time = zeros(procNum,1);
Ts = 1 / Fs;
stftDatas = zeros(FFTLength/2+1,procNum);
freq = Fs * (0:(FFTLength/2)) / FFTLength;
for index = 1:procNum
    procData = signal(offset:offset+FFTLength-1);
    time(index) = Ts * (offset+FFTLength);
    windowedProcData = procData .* hammingWindow;
    spectrum = fft(windowedProcData);
    powerSpectrum = abs(spectrum/FFTLength);
    oneSidedPowerSpectrum = powerSpectrum(1:FFTLength/2+1);
    oneSidedPowerSpectrum(2:end-1) = 2 * oneSidedPowerSpectrum(2:end-1);
    stftDatas(:,index) = oneSidedPowerSpectrum;
    offset = offset + Overlap;
end
end

