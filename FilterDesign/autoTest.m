function [h,p,distname] = autoTest(testData)
%AUTOTEST この関数の概要をここに記述
%   詳細説明をここに記述
distnameList = {'Beta','Binomial','BirnbaumSaunders','Burr','Exponential'...
    ,'ExtremeValue','Gamma','GeneralizedExtremeValue','GeneralizedPareto'...
    ,'InverseGaussian','Kernel','Logistic','Loglogistic','Lognormal'...
    ,'Nakagami','NegativeBinomial','Normal','Poisson','Rayleigh','Rician'...
    ,'Stable','tLocationScale','Weibull'};
distname = distnameList;
h = zeros(length(distnameList),1);
p = zeros(length(distnameList),1);
delcount = 0;
warning('off');
for index = 1:length(distnameList)
    try
        pd = fitdist(testData,cell2mat(distnameList(index)));
    catch
        h(index-delcount) = [];
        p(index-delcount) = [];
        distname(index-delcount) = [];
        delcount = delcount + 1;
        continue;
    end
    [h(index-delcount),p(index-delcount)] = chi2gof(testData,'CDF',pd);
    if h(index-delcount) == 1
        distname(index-delcount) = [];
        h(index-delcount) = [];
        p(index-delcount) = [];
        delcount = delcount + 1;
    elseif isnan(p(index-delcount)) 
        distname(index-delcount) = [];
        h(index-delcount) = [];
        p(index-delcount) = [];
        delcount = delcount + 1;
    end
end
warning('on');
end

