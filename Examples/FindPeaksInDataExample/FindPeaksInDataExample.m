%% Find Peaks and Their Locations
% Create a signal that consists of a sum of bell curves. Specify the location,      
% height, and width of each curve.

% Copyright 2015 The MathWorks, Inc.


x = linspace(0,1,1000);

Pos = [1 2 3 5 7 8]/10;
Hgt = [4 4 4 2 2 3];
Wdt = [2 6 3 3 4 6]/100;

for n = 1:length(Pos)
    Gauss(n,:) =  Hgt(n)*exp(-((x - Pos(n))/Wdt(n)).^2);
end

PeakSig = sum(Gauss);
%% 
% Plot the individual curves and their sum.

plot(x,Gauss,'--',x,PeakSig)
%% 
% Use |findpeaks| with default settings to find the peaks of the signal and
% their locations.

[pks,locs] = findpeaks(PeakSig,x);
%% 
% Plot the peaks using |findpeaks| and label them.

findpeaks(PeakSig,x)

text(locs+.02,pks,num2str((1:numel(pks))'))
%% 
% Sort the peaks from tallest to shortest.

[psor,lsor] = findpeaks(PeakSig,x,'SortStr','descend');

findpeaks(PeakSig,x)

text(lsor+.02,psor,num2str((1:numel(psor))'))