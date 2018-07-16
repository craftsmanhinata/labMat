function [signChanged,oldSigIsPlus] = detectSignChange(x)
%DETECTSIGNCHANGE ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
persistent static_curSigIsPlus;
persistent static_oldSigIsPlus;
signChanged = false;
if length(x) == 1
    if x(1) >= 0
        static_curSigIsPlus = true;
        static_oldSigIsPlus = true;
    else
        static_curSigIsPlus = false;
        static_oldSigIsPlus = false;
    end
else
    if x(end) >= 0
        static_curSigIsPlus = true;
        if static_curSigIsPlus ~= static_oldSigIsPlus
            signChanged = true;
            static_oldSigIsPlus = ~static_oldSigIsPlus;
        end
    else
        static_curSigIsPlus = false;
        if static_curSigIsPlus ~= static_oldSigIsPlus
            signChanged = true;
            static_oldSigIsPlus = ~static_oldSigIsPlus;
        end
    end
end
oldSigIsPlus = static_oldSigIsPlus;
end

