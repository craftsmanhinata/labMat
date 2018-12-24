%変数をロードしてから…
clc;
close all;
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
NLMSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,length(evalAxis));
RMSEResponse = zeros(length(evalAxis),trialLength);
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
        disp(strcat(num2str(trialIndex),'個目のデータのRMSE:',num2str(NLMSRMSEArray(trialIndex,coefLenInd,StepInd,evalAxis(axisIndex)))));
        RMSEResponse(axisIndex,trialIndex) = NLMSRMSEArray(trialIndex,coefLenInd,StepInd,evalAxis(axisIndex));
    end
end

disp(strcat('加速度センサのRMSEの平均値',num2str(mean(RMSEResponse(1,:)))));
disp(strcat('加速度センサのRMSEの標準偏差',num2str(std(RMSEResponse(1,:)))));
disp(strcat('ジャイロセンサのRMSEの平均値',num2str(mean(RMSEResponse(2,:)))));
disp(strcat('ジャイロセンサのRMSEの標準偏差',num2str(std(RMSEResponse(2,:)))));
disp(strcat('角速度のRMSEの平均値',num2str(mean(RMSEResponse(3,:)))));
disp(strcat('角速度のRMSEの標準偏差',num2str(std(RMSEResponse(3,:)))));
[p,tbl,stats] = anova1(RMSEResponse');
[c,m,h,nms] = multcompare(stats,'CType','bonferroni');
disp('加速度と角速度のt検定の結果');
[h,p] = ttest2(RMSEResponse(1,:),RMSEResponse(2,:),'Vartype','unequal')

figure();
FontSize = 20;
meanRes = [mean(RMSEResponse(1,:)) mean(RMSEResponse(2,:)) mean(RMSEResponse(3,:))];
stdRes = [std(RMSEResponse(1,:)) std(RMSEResponse(2,:)) std(RMSEResponse(3,:))];
bar(meanRes,'FaceColor', 'cyan');
hold on;
er = errorbar(meanRes,stdRes);
er.Color = [0 0 0];
er.LineStyle = 'none';
ylabel('RMSE','FontSize',FontSize);
set(gca,'xticklabel',{'Acceleration','Gyro','Angular Speed'});
set(gca,'FontSize',FontSize);