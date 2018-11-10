function [scale] = scalesAutoSet(wname,samplingPeriod,freqRange,voicesPerOctave)
%SCALESAUTOSET �X�P�[��a��������������
%   �ڍא����������ɋL�q

if ~ isrow(freqRange) && ~ iscolumn(freqRange)
    msgID = 'SCALEAUTOSET:InvalidArgument';
    msg = strcat('����freqRange�̓x�N�g���ł���K�v������܂�.');
    baseException = MException(msgID,msg);
    throw(baseException)
end

%��͎��g���̍ō����g���̌v�Z.
maxFrequency = 1 / samplingPeriod / 2; %�f�t�H���g�̓i�C�L�X�g���g��
if max(freqRange) < maxFrequency
    maxFrequency = max(freqRange);
end

%�X�P�[��1�̎��g�����v�Z����
scaleOneFreq = scal2frq(1,wname,samplingPeriod); 
%�X�P�[��1�̎��g��������g��-�X�P�[���Ԃ̊֌W�̐���
minScale =  scaleOneFreq / maxFrequency;
maxScale =  scaleOneFreq / min(freqRange);

scaleStepParam = 1 / voicesPerOctave;


%5
scaleNum = ceil(voicesPerOctave * log2(maxScale/minScale));

scale = minScale * 2 .^ (scaleStepParam * (0:1:scaleNum - 1));

end

