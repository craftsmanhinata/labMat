function [coefs,coefsLength] = getDWTCoefs(wname,level,data)
%GETDWTCOEFS この関数の概要をここに記述
%   詳細説明をここに記述
[LoD,HiD,LoR,HiR] = getDWTFilters(wname);

[coefs,coefsLength] = wavedec(data,level,LoD,HiD);
end

