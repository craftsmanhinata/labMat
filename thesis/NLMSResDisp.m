%変数をロードしてから…
clc;
close all;
paramLength = 2;
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
NLMSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,NLMSStepProcNum,length(evalAxis));
RMSEResponse = zeros(length(evalAxis),trialLength);
filterParamResponse = zeros(length(evalAxis),trialLength,paramLength);
coefLengthParamNum = 1;
adapParamNum = 2;
dispDigit = 4;
paramDisp = true;
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
        filterParamResponse(axisIndex,trialIndex,coefLengthParamNum) = searchFilterCoefLength(coefLenInd);
        filterParamResponse(axisIndex,trialIndex,adapParamNum) = NLMSStepSizeArray(StepInd);
    end
end

disp(strcat(Dict(evalAxis(1)),'のRMSEの平均値',num2str(mean(RMSEResponse(1,:)))));
disp(strcat(Dict(evalAxis(1)),'のRMSEの標準偏差',num2str(std(RMSEResponse(1,:)))));
disp(strcat(Dict(evalAxis(2)),'のRMSEの平均値',num2str(mean(RMSEResponse(2,:)))));
disp(strcat(Dict(evalAxis(2)),'のRMSEの標準偏差',num2str(std(RMSEResponse(2,:)))));
disp(strcat(Dict(evalAxis(3)),'のRMSEの平均値',num2str(mean(RMSEResponse(3,:)))));
disp(strcat(Dict(evalAxis(3)),'のRMSEの標準偏差',num2str(std(RMSEResponse(3,:)))));
[p,tbl,stats] = anova1(RMSEResponse');
[c,m,h,nms] = multcompare(stats,'CType','bonferroni');
disp(strcat(Dict(evalAxis(1)),'と',Dict(evalAxis(2)),'のt検定の結果'));
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
ylabel('RMSE (beat / min.)','FontSize',FontSize);
set(gca,'xticklabel',{'Acceleration','Gyro','Angular Speed'});
set(gca,'FontSize',FontSize);


%tableの作製
AdapFiltParamName = '$\mu$';
fprintf('\\begin{table}[H]\n');
fprintf('\t\\begin{center}\n');
fprintf('\t\t\\caption{dummyCaption}\n');
fprintf('\t\t\\footnotesize \\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|} \\hline\n');
fprintf('\t\t\t{}&\\multicolumn{3}{c|}{%s}&\\multicolumn{3}{c|}{%s}&\\multicolumn{3}{c|}{%s}\\\\ \\hline\n',Dict(evalAxis(1)),Dict(evalAxis(2)),Dict(evalAxis(3)));
fprintf('\t\t\t{DataSet}&{$N$}&{%s}&{$RMSE$}&{$N$}&{%s}&{$RMSE$}&{$N$}&{%s}&{$RMSE$}\\\\ \\hline\n',AdapFiltParamName,AdapFiltParamName,AdapFiltParamName);

for trialIndex = 1 : trialLength
    fprintf('\t\t\t{%d}&',trialIndex);
    for axisIndex = 1 : length(evalAxis)
        fprintf('{%d}&{%.*f}&{%.*f}',filterParamResponse(axisIndex,trialIndex,coefLengthParamNum)...
            ,dispDigit,round(filterParamResponse(axisIndex,trialIndex,adapParamNum),dispDigit)...
            ,dispDigit,round(RMSEResponse(axisIndex,trialIndex),dispDigit));
        if axisIndex <= (length(evalAxis) -1)
            fprintf('&');
        end
    end
    fprintf('\\\\ \\hline \n');
end
fprintf('\t\t\t{$MEAN$}&\\multicolumn{2}{c|}{}&{%.*f}&\\multicolumn{2}{c|}{}&{%.*f}&\\multicolumn{2}{c|}{}&{%.*f}\\\\ \\hline\n'...
    ,dispDigit,round(mean(RMSEResponse(1,:)),dispDigit)...
    ,dispDigit,round(mean(RMSEResponse(2,:)),dispDigit)...
    ,dispDigit,round(mean(RMSEResponse(3,:)),dispDigit));
fprintf('\t\t\t{$SD$}&\\multicolumn{2}{c|}{}&{%.*f}&\\multicolumn{2}{c|}{}&{%.*f}&\\multicolumn{2}{c|}{}&{%.*f}\\\\ \\hline\n'...
    ,dispDigit,round(std(RMSEResponse(1,:)),dispDigit)...
    ,dispDigit,round(std(RMSEResponse(2,:)),dispDigit)...
    ,dispDigit,round(std(RMSEResponse(3,:)),dispDigit));
fprintf('\t\t\\end{tabular}\n');
fprintf('\t\t\\label{tab:dummyLabel}\n');
fprintf('\t\\end{center}\n');
fprintf('\\end{table}\n');

if paramDisp
    fprintf('\\begin{table}[H]\n');
    fprintf('\t\\begin{center}\n');
    fprintf('\t\t\\caption{dummyCaption}\n');
    fprintf('\t\t\\small \\begin{tabular}{|l||c|c|c|c|c|c|} \\hline\n');
    tableColNum = 6;
    tableRowNum = ceil(NLMSStepProcNum / tableColNum);
    tableCenterNum = ceil(tableRowNum / 2);
    tableParamIndex = 1;
    
    for tableRowIndex = 1:tableRowNum
        fprintf('\t\t\t');
        if tableRowIndex == tableCenterNum
                fprintf('\\begin{tabular}{c}Step Size Parameter $\\mu$ \\\\in NLMS Algorithm\\end{tabular}');
        end
        for tableColumnIndex = 1:tableColNum
            fprintf('&{%.*f}',dispDigit,round(NLMSStepSizeArray(tableParamIndex),dispDigit));
            tableParamIndex = tableParamIndex + 1;
        end
        if tableRowIndex ~= tableRowNum
            fprintf(' \\\\ \\cline{2-7}\n');
        else
            fprintf(' \\\\ \\hline\n');
        end
    end
    fprintf('\t\t\\end{tabular}\n');
    fprintf('\t\t\\label{tab:dummyLabel}\n');
    fprintf('\t\\end{center}\n');
    fprintf('\\end{table}\n');
end