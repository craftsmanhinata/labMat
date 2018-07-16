function [errorArray] = errorsMatToArray(errors)
%ERRORSMATTOARRAY ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
rowLen = length(errors(:,1));
columnLen = length(errors);
ArrayLength = (rowLen * columnLen);
errorArray = ones(ArrayLength,1);
for index = 0:length(errorArray)-1
    if index == 0
        errorArray(index+1) = errors(mod(index,rowLen)+1,1);
    else
        errorArray(index+1) = errors(mod(index,rowLen)+1,ceil((index+1)/rowLen));
    end
end
end

