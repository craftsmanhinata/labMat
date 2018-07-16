function [error] = compStateGraph(states,stateNum1,stateNum2,plotIs)
%COMPSTATEGRAPH この関数の概要をここに記述
%   詳細説明をここに記述
if stateNum1 <= length(states) && stateNum2 <= length(states)...
        && stateNum1 >= 1 && stateNum2 >= 1
    [time,value1] = stateDisassem(states(:,stateNum1));
    time = timeConvToState(time);
    [~,value2] = stateDisassem(states(:,stateNum2));
    error = value2 - value1;
    if plotIs
        figure();
        plot(time,value1);
        hold on;
        plot(time,value2);
    end
end
end
