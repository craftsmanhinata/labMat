function [roll,pitch] = calcRollPitchFromAcc(acc)
%CALCROLLPITCHFROMACC 加速度からロールピッチを求める
%   詳細説明をここに記述
xAxis = 1;
yAxis = 2;
zAxis = 3;
roll = atan2(acc(:,yAxis),acc(:,zAxis));
pitch = atan2(-acc(:,xAxis),sqrt(acc(:,yAxis).^2+acc(:,zAxis).^2));
end

