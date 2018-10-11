function [LoD,HiD,LoR,HiR] = getDWTFilters(wname)
%GETDWTFILTERS wfilters���Ă�
%   wfilters���ĂԂ���. wname�ɃG���[��������
WT = wavemngr('type',wname);
WT_Check_Orthogonal = 1;
WT_Check_Birthogonal = 2;
if((WT ~= WT_Check_Orthogonal)&&(WT ~= WT_Check_Birthogonal))
    msgID = 'GETWAVELET:InvalidWaveletmae';
    msg = strcat(wname,'�͑��d�𑜓x��͂Ɏg�p�ł��܂���.');
    baseException = MException(msgID,msg);
    throw(baseException)
end
[LoD,HiD,LoR,HiR] = wfilters(wname);


end

