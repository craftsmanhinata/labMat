function [microState] = observeSignal(microState)
%OBSERVE SIGNAL この関数の概要をここに記述
%   詳細説明をここに記述
microState = microState + observationNoiseReturn();
end

