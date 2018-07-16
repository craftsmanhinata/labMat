close all;
clear();
clc();
addpath('.\FastICA_25');

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'Out\';
fileNamePPG = '20180709_180616_Test_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG))';
PPGTime = (0:1:length(PPGData)-1)'*Ts;
figure();
for index = 1:4
    subplot(4,1,index);
    plot(PPGTime,PPGData(index,:)');
    hold on;
end

[cwtMat,f,coi] = cwtMultiAnimation(PPGData,PPGTime,[0.7 3],false);
cwtPowerMat = abs(cwtMat);
% freq x time x channel
meanSignal = zeros(1,4);
meanSignal(1) = mean(PPGData(1,:));
meanSignal(2) = mean(PPGData(2,:));
meanSignal(3) = mean(PPGData(3,:));
meanSignal(4) = mean(PPGData(4,:));
% 
[timeArray] = multiICWT(cwtMat,f,meanSignal);


ResCwtMat = zeros([length(f) length(PPGTime)]);
for index = 1:length(PPGTime)
    %X = [ones(size(cwtPowerMat(:,index,1))) cwtPowerMat(:,index,2) cwtPowerMat(:,index,3) cwtPowerMat(:,index,4) cwtPowerMat(:,index,2).*cwtPowerMat(:,index,3) cwtPowerMat(:,index,2).*cwtPowerMat(:,index,4) cwtPowerMat(:,index,3).*cwtPowerMat(:,index,4)];
    X = [ones(size(real(cwtMat(:,index,1)))) real(cwtMat(:,index,2)) real(cwtMat(:,index,3)) real(cwtMat(:,index,4))];
    [~,~,~,~,stats,~,~] = stepwisefit(X,real(cwtMat(:,index,1)),'display','off');

%     if (maxCorrcoefArray(index) > 0.7) && (maxCorrcoefPValueArray(index) < 0.05)
%         plot(f,squeeze(cwtPowerMat(:,index,1)));
%         hold on;
%         plot(f,squeeze(cwtPowerMat(:,index,maxCorrcoefChannel(index))));
%         hold off;
%         title(maxCorrcoefArray(index));
%     end
    ResCwtMat(:,index) = stats.yr;
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

% maxR = -1;
% maxRIndex = zeros(1,3);
% for index = 1:3
%     R = corrcoef(timeArray(:,1),timeArray(:,index+1))
% end

% cwtPowerMat = abs(cwtMat);

%icasig = zeros(fliplr(size(cwtPowerMat)));
% icasig = zeros(3,5408,101);
% icaSource = permute(cwtPowerMat,[3 2 1]);
%rng default;
% for index = 1:length(f)
%     [icasig(:,:,index)] = fastica (icaSource(:,:,index), 'numOfIC', 3, 'displayMode', 'off','verbose', 'off');
% %     [m,n] = size(A);
% %     if m ~= n
% %         disp('error');
% %         break;
% %     end
% end

% [icasig] = fastica (timeArray', 'numOfIC', 4, 'displayMode', 'off','verbose', 'off');

% icaDst = permute(icasig,[3 2 1]);
% dummyMean = zeros(1,3);
% [timeICAArray] = multiICWT(icaDst,f,dummyMean);
% figure();
% % maxR = -1;
% % maxRIndex = zeros(1,3);
% for index = 1:4
%    subplot(4,1,index);
%    plot(PPGTime,icasig(index,:));
% %    for subIndex = 1:4
% %        R = corrcoef(timeArray(:,subIndex)+meanSignal(1),timeICAArray(:,index));
% %        if R(1,2) > maxR
% %            maxR = R(1,2);
% %            maxRIndex(index) = subIndex;
% %        end
% %    end
% %    maxR = -1;
% end