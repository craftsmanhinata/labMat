%変数をロードしてから…
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
NLMSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,length(evalAxis));
disp('適応フィルタアルゴリズムによる評価結果');
for trialIndex = 1 : trialLength
    otherDataIndex = 1:1:trialLength;
    otherDataIndex(trialIndex) = '';
    NLMSRMSEMean(trialIndex,:,:,:) = mean(NLMSRMSEArray(otherDataIndex,:,:,...
        evalAxis));
    %各軸について最小を評価
    for axisIndex = 1 : length(evalAxis)
        curRMSEMean = reshape(NLMSRMSEMean(trialIndex,:,:,axisIndex),...
        [searchFilterCoefLengthProcNum NLMSStepProcNum]);
        [val,minFilterParamKey] = min(curRMSEMean(:));
        [coefLenInd,StepInd]= ind2sub(size(curRMSEMean),minFilterParamKey);
        disp(strcat(num2str(trialIndex),'個目のデータの',Dict(evalAxis(axisIndex)),'に対する最適パラメータ:','係数長:',num2str(searchFilterCoefLength(coefLenInd)),...
        'ステップサイズ:',num2str(NLMSStepSizeArray(StepInd)),''));
        disp(strcat(num2str(trialIndex),'個目のデータのRMSE:',num2str(NLMSRMSEArray(trialLength,coefLenInd,StepInd,evalAxis(axisIndex)))));
    end
end