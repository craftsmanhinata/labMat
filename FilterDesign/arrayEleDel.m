function [x] = arrayEleDel(x,delIndex)
%ARRAYDEL ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
delCount = 0;
for index = 1:length(delIndex)
    x(delIndex(index)-delCount) = [];
    delCount = delCount+1;
end
end

