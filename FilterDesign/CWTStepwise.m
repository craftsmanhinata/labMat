%close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'Out\';
%fileNamePPG = '20180628_224453_Data_Res.csv';
%fileNamePPG = '20180710_193815_Test_Res.csv';
fileNamePPG = '20180712_143039_Test_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG))';
PPGTime = (0:1:length(PPGData)-1)'*Ts;
figure();

%sinÇç¨ì¸Ç≥ÇπÇÈ
%PPGData(1,:) = PPGData(1,:) + 0.5*sin(2*pi*1*PPGTime)';
for index = 1:4
    subplot(4,1,index);
    plot(PPGTime,PPGData(index,:)');
    hold on;
end

[cwtMat,f,coi] = cwtMultiAnimation(PPGData,PPGTime,[0.7 1.7],false);
cwtPowerMat = abs(cwtMat);
cwtEnergyMat = squeeze(sum(power(cwtPowerMat,2)));
% freq x time x channel
meanSignal = zeros(1,4);
meanSignal(1) = mean(PPGData(1,:));

[timeArray] = multiICWT(cwtMat,f,meanSignal);


ResCwtMat = zeros([length(f) length(PPGTime)]);
for index = 1:length(PPGTime)
    
    %[~,~,~,inmodel,stats,~,~] = stepwisefit(X,real(cwtMat(:,index,1)),'display','off');
    %mdl = stepwiselm(X,real(cwtMat(:,index,1)),'Intercept',false,'Verbose',0);
    if (cwtEnergyMat(index,1) < cwtEnergyMat(index,2))...
            || (cwtEnergyMat(index,1) < cwtEnergyMat(index,3))...
            || (cwtEnergyMat(index,1) < cwtEnergyMat(index,4))
        X = [real(cwtMat(:,index,2)) real(cwtMat(:,index,3)) real(cwtMat(:,index,4))];
        mdl = stepwiselm(X,real(cwtMat(:,index,1)),'linear','Verbose',0,'Intercept',false,'Upper','linear','Criterion','rsquared');
        %ResCwtMat(:,index) = stats.yr + stats.intercept;
        %angleOrig = angle(cwtMat(:,index,1));
        %ResCwtMat(:,index) = mdl.Residuals.Raw .* real(exp(1j * angleOrig));
        ResCwtMat(:,index) = mdl.Residuals.Raw;
    else
        ResCwtMat(:,index) = real(cwtMat(:,index,1));
    end
end

[timeArray2] = multiICWT(ResCwtMat,f,meanSignal(1,:));
figure();
subplot(3,1,1);
plot(PPGTime,PPGData(1,:));
ylimRaw = ylim;
subplot(3,1,2);
plot(PPGTime,timeArray(:,1));
ylim(ylimRaw);
subplot(3,1,3);
plot(PPGTime,timeArray2);
ylim(ylimRaw);
