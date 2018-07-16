function [startXIndex,endXIndex] = drawWindow(x,y,fig,startPos,endPos)
%DRAWWINDOW この関数の概要をここに記述
%   詳細説明をここに記述
startXIndex = [];
endXIndex = [];
if isa(fig,'matlab.ui.Figure')
    endXIndex = knnsearch(x,endPos);
    startXIndex = knnsearch(x,startPos);
    maxVal = max(y);
    minVal = min(y);
    figure(fig);
    hold on;
    lowerLeftPos = [x(startXIndex), minVal];
    rectWidth = x(endXIndex) - x(startXIndex);
    rectHeight = maxVal - minVal;
    pos = [lowerLeftPos rectWidth rectHeight];
    rectangle('Position',pos,'LineStyle','--','EdgeColor','r','LineWidth',3);
    hold off;
end
end

