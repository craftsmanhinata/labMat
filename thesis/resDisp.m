%�ϐ������[�h���Ă���c
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
NLMSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,length(evalAxis));
disp('�K���t�B���^�A���S���Y���ɂ��]������');
for trialIndex = 1 : trialLength
    otherDataIndex = 1:1:trialLength;
    otherDataIndex(trialIndex) = '';
    NLMSRMSEMean(trialIndex,:,:,:) = mean(NLMSRMSEArray(otherDataIndex,:,:,...
        evalAxis));
    %�e���ɂ��čŏ���]��
    for axisIndex = 1 : length(evalAxis)
        curRMSEMean = reshape(NLMSRMSEMean(trialIndex,:,:,axisIndex),...
        [searchFilterCoefLengthProcNum NLMSStepProcNum]);
        [val,minFilterParamKey] = min(curRMSEMean(:));
        [coefLenInd,StepInd]= ind2sub(size(curRMSEMean),minFilterParamKey);
        disp(strcat(num2str(trialIndex),'�ڂ̃f�[�^��',Dict(evalAxis(axisIndex)),'�ɑ΂���œK�p�����[�^:','�W����:',num2str(searchFilterCoefLength(coefLenInd)),...
        '�X�e�b�v�T�C�Y:',num2str(NLMSStepSizeArray(StepInd)),''));
        disp(strcat(num2str(trialIndex),'�ڂ̃f�[�^��RMSE:',num2str(NLMSRMSEArray(trialLength,coefLenInd,StepInd,evalAxis(axisIndex)))));
    end
end