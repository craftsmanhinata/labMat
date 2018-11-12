function [] = plotScaleogram2(coeffMat,time,frequencies)
%plotScaleogram2 対数表示バージョン.再構成を考慮したスケールによってウェーブレット変換を行った場合は
%                この関数でプロットを行うとイイ感じになる
%   coeffMat:係数行列
%   time:時間
%   frequencies:係数行列と対応する周波数の情報
%要改善: octaveが小さいとy軸の範囲が負になって表示されなくなる
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


