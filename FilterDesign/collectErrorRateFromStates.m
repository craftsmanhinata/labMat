function [errors] = collectErrorRateFromStates(states)
%CORRECTERRORRATEFROMSTATES ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
stateNum = length(states);
signalLen = floor(length(states(:,1))/2);
errors = zeros(signalLen,stateNum-1);
for index = 1:stateNum - 1
    errors(:,index) = compStateGraph(states,index,index+1,false);
end

end

