close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;
points = 9000;

PPGFolder = 'Out\';
fileNamePPG = '20180712_143039_Test_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPGData = PPGData(1:points,:);
PPGTime = (0:1:points-1)'*Ts;
[PPGCwtMat,f,coi] = cwtMultiAnimation(PPGData',PPGTime,[0.7 3.0],false);
PPGCwtPowerMat = abs(PPGCwtMat);

corrCwt = zeros(length(PPGTime),3);

for index = 1:points
    for axisIndex = 1:3
        bufR = corrcoef(squeeze(PPGCwtPowerMat(:,index,1)),squeeze(PPGCwtPowerMat(:,index,axisIndex+1)));
        corrCwt(index,axisIndex) = bufR(1,2);
    end
end

[mostCorrVal,mostAxis] = max(abs(corrCwt),[],2);
negCorrIndex = corrCwt(1:end,1:3)<0;
negCorrIndex = and(and(negCorrIndex(:,1),negCorrIndex(:,2)),negCorrIndex(:,3));
mostAxis(negCorrIndex) = 0;

weakCorr = mostCorrVal<0.7;
mostAxis(weakCorr) = 0;

coiIndex = coi<0.7;

figure();
plot(PPGTime(coiIndex),mostAxis(coiIndex),'s','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',3);
ylim([0 3]);
yticks(0:1:3);
yticklabels({'None','XaxisAcc','YaxisAcc','ZaxisAcc'});
ylabel('Strong correlation Sensor','FontSize',40);
xlabel('Time[sec.]','FontSize',40);
xlim([0 180])

set(gca,'FontSize',40);
noEstimate = sum(mostAxis == 0)*Ts;


xTime = sum((abs(corrCwt(:,1))>=0.7));
yTime = sum((abs(corrCwt(:,2))>=0.7));
zTime = sum((abs(corrCwt(:,3))>=0.7));