%�ϐ������[�h���Ă���c
clc;
close all;
evalAxis = [TriAccKey TriGyroKey TriAngleKey];
RLSRMSEMean = zeros(trialLength,searchFilterCoefLengthProcNum,RLSStepProcNum,length(evalAxis));
RMSEResponse = zeros(length(evalAxis),trialLength);
disp('RLS�A���S���Y���ɂ��]������');
for trialIndex = 1 : trialLength
    otherDataIndex = 1:1:trialLength;
    otherDataIndex(trialIndex) = '';
    RLSRMSEMean(trialIndex,:,:,:) = mean(RLSRMSEArray(otherDataIndex,:,:,...
        evalAxis));
    %�e���ɂ��čŏ���]��
    for axisIndex = 1 : length(evalAxis)
        curRMSEMean = reshape(RLSRMSEMean(trialIndex,:,:,axisIndex),...
        [searchFilterCoefLengthProcNum RLSStepProcNum]);
        [val,minFilterParamKey] = min(curRMSEMean(:));
        [coefLenInd,StepInd]= ind2sub(size(curRMSEMean),minFilterParamKey);
        disp(strcat(num2str(trialIndex),'�ڂ̃f�[�^��',Dict(evalAxis(axisIndex)),'�ɑ΂���œK�p�����[�^:','�W����:',num2str(searchFilterCoefLength(coefLenInd)),...
        '�X�e�b�v�T�C�Y:',num2str(RLSForgettingFactorArray(StepInd)),''));
        disp(strcat(num2str(trialIndex),'�ڂ̃f�[�^��RMSE:',num2str(RLSRMSEArray(trialIndex,coefLenInd,StepInd,evalAxis(axisIndex)))));
        RMSEResponse(axisIndex,trialIndex) = RLSRMSEArray(trialIndex,coefLenInd,StepInd,evalAxis(axisIndex));
    end
end


disp(strcat('�����x�Z���T��RMSE�̕��ϒl',num2str(mean(RMSEResponse(1,:)))));
disp(strcat('�����x�Z���T��RMSE�̕W���΍�',num2str(std(RMSEResponse(1,:)))));
disp(strcat('�W���C���Z���T��RMSE�̕��ϒl',num2str(mean(RMSEResponse(2,:)))));
disp(strcat('�W���C���Z���T��RMSE�̕W���΍�',num2str(std(RMSEResponse(2,:)))));
disp(strcat('�p���x��RMSE�̕��ϒl',num2str(mean(RMSEResponse(3,:)))));
disp(strcat('�p���x��RMSE�̕W���΍�',num2str(std(RMSEResponse(3,:)))));
[p,tbl,stats] = anova1(RMSEResponse');
[c,m,h,nms] = multcompare(stats,'CType','bonferroni');
disp('�����x�Ɗp���x��t����̌���');
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
set(gca,'xticklabel',{'Acceleration','Gyro','Angle Speed'});
set(gca,'FontSize',FontSize);