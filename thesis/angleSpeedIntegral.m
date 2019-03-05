function [angle] = angleSpeedIntegral(angleSpeed,Fs)
%ANGLE Šp‘¬“x‚ğÏ•ª‚·‚éƒvƒƒOƒ‰ƒ€
%   
Ts = 1 / Fs;

angle = zeros(1,length(angleSpeed)-1);

firstTermIndex = 1:length(angle);
secondTermIndex = 2:length(angleSpeed);
angle = (angleSpeed(firstTermIndex)+angleSpeed(secondTermIndex)) * Ts / 2;
angle =  [0 angle'];
end

