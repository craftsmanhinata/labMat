function [LoD,HiD,LoR,HiR] = getDWTFilters(wname)
%GETDWTFILTERS wfiltersを呼ぶ
%   wfiltersを呼ぶだけ. wnameにエラー処理がつく
WT = wavemngr('type',wname);
WT_Check_Orthogonal = 1;
WT_Check_Birthogonal = 2;
if((WT ~= WT_Check_Orthogonal)&&(WT ~= WT_Check_Birthogonal))
    msgID = 'GETWAVELET:InvalidWaveletmae';
    msg = strcat(wname,'は多重解像度解析に使用できません.');
    baseException = MException(msgID,msg);
    throw(baseException)
end
[LoD,HiD,LoR,HiR] = wfilters(wname);


end

