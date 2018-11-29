function [xAngle,yAngle,zAngle] = calcAngleFromAcc(xAcc,yAcc,zAcc)
%CALCANGLE ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
xAngle = atan2(xAcc,sqrt(yAcc.^2+zAcc.^2));
yAngle = atan2(yAcc,sqrt(xAcc.^2+zAcc.^2));
zAngle = atan2(sqrt(xAcc.^2+yAcc.^2),zAcc);

end
