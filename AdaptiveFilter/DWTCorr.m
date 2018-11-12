function [R_return] = DWTCorr(coeff1,coeffLength1,coeff2,coeffLength2,wname)
%DWTCORR この関数の概要をここに記述
%   詳細説明をここに記述
level = length(coeffLength1) - 2;
R_Length = length(coeffLength1) - 1;
R_return = ones(R_Length,1);
approx1 = appcoef(coeff1,coeffLength1,wname);
approx2 = appcoef(coeff2,coeffLength2,wname);
R = corrcoef(approx1,approx2);
R_return(1) = R(1,2);

for index = 0:level - 1
    cd1 = detcoef(coeff1,coeffLength1,level-index);
    cd2 = detcoef(coeff2,coeffLength2,level-index);
    R = corrcoef(cd1,cd2);
    R_return(index+2) = R(1,2);

end

