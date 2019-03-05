function [oneSidedSpectrum] = convertOneSidedSpectrum(spectrum,FFTLength)
%CONVERTONESIDEDSPECTRUM STFTのデータを片側振幅スペクトルに変換する
%   詳細説明をここに記述
oneSidedSpectrum = abs(spectrum/FFTLength);
oneSidedSpectrum(2:end-1,:) = 2 * oneSidedSpectrum(2:end-1,:);
end

