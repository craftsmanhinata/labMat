function [coefs,coefsLength] = getDWTCoefs(wname,level,data)
%GETDWTCOEFS ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
[LoD,HiD,LoR,HiR] = getDWTFilters(wname);

[coefs,coefsLength] = wavedec(data,level,LoD,HiD);
end

