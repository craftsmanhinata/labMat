function [] = plotScaleogram(coeffMat,time,scales,frequencies)
%SCA この関数の概要をここに記述
%   詳細説明をここに記述
figure();
imagesc(time,scales,abs(coeffMat));
c = colorbar;
c.Label.String = 'Magnitude';
%set(gca,'YDir','normal');
%yticklabels(frequencies);
ytickLabelStr = get(gca,'YTickLabel');
ytickLabelNum = ones(length(ytickLabelStr),1);
newYTickLabel = ones(length(ytickLabelStr),1);
for labelIndex = 1:length(ytickLabelStr)
    LabelItem = cell2mat(ytickLabelStr(labelIndex));
    ytickLabelNum(labelIndex) = str2double(LabelItem);
    newYTickLabel(labelIndex) = frequencies(knnsearch(scales',ytickLabelNum(labelIndex)));
end
yticklabels(newYTickLabel);
ylabel("Approx frequency(Hz)");
xlabel("Time(sec.)");
end

