function [index,val] = evenDel(index,val)
%EVENDEL ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
count = length(val) / 2;
delIndexArray = 1:1:count;
delIndexArray = delIndexArray * 2;
delIndexArray = delIndexArray - 1;
newIndex = zeros(length(delIndexArray),1);
newVal = zeros(length(delIndexArray),1);
for ind = 1:length(delIndexArray)
    newIndex(ind) = index(delIndexArray(ind));
    newVal(ind) = val(delIndexArray(ind));
end

index = newIndex;
val = newVal;