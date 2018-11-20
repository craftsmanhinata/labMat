function [spectrum,Freq] = FFTAuto(data, Fs)
%FFTAUTO �Б��U���X�y�N�g����Ԃ�
%   �ڍא����������ɋL�q
if( bitand(length(data),length(data)-1) ~= 0)
    FFTLength = 2^ceil(log2(length(data)));
    data(end+1:FFTLength) = 0;
else
    FFTLength = length(data);
end

windowFunc = hamming(length(data));
preprocData = detrend(data);

if  isrow(preprocData)
    preprocData = preprocData';
end

preprocData = preprocData .* windowFunc;
spectrum = fft(preprocData);
spectrum = spectrum / FFTLength;
spectrum = spectrum(1:FFTLength/2+1);

Freq = Fs * (0:(FFTLength/2)) / FFTLength;

end

