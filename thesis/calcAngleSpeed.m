function [rollSpeed,pitchSpeed,yawSpeed] = calcAngleSpeed(gyro,roll,pitch)
%CALCANGLESPEED ジャイロとロール, ピッチから世界座標系のロールピッチヨーの角速度を求める
%   詳細説明をここに記述
xAxis = 1;
yAxis = 2;
zAxis = 3;


angleMat = zeros(3,3,length(roll));
angleSpeed = zeros(size(gyro));
for index = 1:length(roll)
    angleMat(:,:,index) = [1 sin(roll(index)).*tan(pitch(index)) cos(roll(index)).*tan(pitch(index));
                    0   cos(roll(index))   -sin(roll(index))
                    0   sin(roll(index)).*sec(pitch(index)) cos(roll(index)).*sec(pitch(index))];
    angleSpeed(index,:) = angleMat(:,:,index)*(gyro(index,:))';
end
rollSpeed = angleSpeed(:,xAxis);
pitchSpeed = angleSpeed(:,yAxis);
yawSpeed = angleSpeed(:,zAxis);


end

