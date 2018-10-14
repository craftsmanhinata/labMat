function [] = plotScaleogram2(coeffMat,time,frequencies)
%plotScaleogram2 �ΐ��\���o�[�W����.�č\�����l�������X�P�[���ɂ���ăE�F�[�u���b�g�ϊ����s�����ꍇ��
%                ���̊֐��Ńv���b�g���s���ƃC�C�����ɂȂ�
%   coeffMat:�W���s��
%   time:����
%   frequencies:�W���s��ƑΉ�������g���̏��
%�v���P: octave����������y���͈̔͂����ɂȂ��ĕ\������Ȃ��Ȃ�
figure();
imagesc(time,frequencies,abs(coeffMat));
c = colorbar;
c.Label.String = 'Magnitude';
set(gca,'YScale','log');
set(gca,'YDir','normal');

% maxFreq = max(frequencies);
% intWidth = ceil(log10(maxFreq));
% minFreq = min(frequencies);
% decimalWidth = 0;
% if(minFreq < 1.0)
%     minFreq = minFreq^-1;
%     decimalWidth = ceil(log10(minFreq));
% end
% format = strcat('%',num2str(intWidth),'.',num2str(decimalWidth),'f');
% set(gca,'yticklabel',num2str(get(gca,'ytick')',format));
ylabel("Approx frequency(Hz)");
xlabel("Time(sec.)");
end


