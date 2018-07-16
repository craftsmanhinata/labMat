function [x] = arrayEleDel(x,delIndex)
%ARRAYDEL この関数の概要をここに記述
%   詳細説明をここに記述
delCount = 0;
for index = 1:length(delIndex)
    x(delIndex(index)-delCount) = [];
    delCount = delCount+1;
end
end

