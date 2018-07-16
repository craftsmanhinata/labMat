close all;
clear();
clc();

Fs = 50;
Ts = 1 / Fs;

PPGFolder = 'Out\';
fileNamePPG = '20180628_224453_Data_Res.csv';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
PPG = PPGData(:,1);
PPGTime = (0:1:length(PPG)-1)'*Ts;

fhc = 3; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.7;
NFlc = flc/(Fs/2);
adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 1.1;
lowFreqMargin = 1.16;
Ap = 1.0;

D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
Hd = design(D,'equiripple');
FilteredPPG = filtfilt(Hd.numerator,1,PPG);

[PPGTime,FilteredPPG] = trimSig(PPGTime,FilteredPPG,0,180);


NoiseDataName = '20180712_150736_Test_Noise.csv';
NoiseData = csvread(strcat(PPGFolder,NoiseDataName));
NoiseData(:,1) = NoiseData(:,1) + FilteredPPG;
NoiseData((NoiseData(:,1)>1)) = 1;

[cwtMat,f,coi] = cwtMultiAnimation(NoiseData',PPGTime,[0.7 1.7],false);
cwtPowerMat = abs(cwtMat);
cwtEnergyMat = squeeze(sum(power(cwtPowerMat,2)));
% freq x time x channel
meanSignal = zeros(1,4);
meanSignal(1) = mean(NoiseData(:,1));

[timeArray] = multiICWT(cwtMat,f,meanSignal);

[ansMat,f,coi] = cwtMultiAnimation(FilteredPPG,PPGTime,[0.7 1.7],false);
ansMat = real(ansMat);

ResCwtMatAns = squeeze(real(cwtMat(:,:,1)));

RArray = zeros(length(ansMat),1);
R_XArray = zeros(length(ansMat),1);
R_YArray = zeros(length(ansMat),1);
R_ZArray = zeros(length(ansMat),1);
for index = 1:length(ansMat)
	bufR = corrcoef(ResCwtMatAns(:,1),ansMat(:,1));
	RArray(index) = bufR(1,2);
    bufR = corrcoef(ResCwtMatAns(:,1),squeeze(real(cwtMat(:,index,2))));
    R_XArray(index) = bufR(1,2);
    bufR = corrcoef(ResCwtMatAns(:,1),squeeze(real(cwtMat(:,index,3))));
    R_YArray(index) = bufR(1,2);
    bufR = corrcoef(ResCwtMatAns(:,1),squeeze(real(cwtMat(:,index,4))));
    R_ZArray(index) = bufR(1,2);
end

R_ans = [R_XArray R_YArray R_ZArray zeros(length(ansMat),1)];
buf = (R_ans(:,1:3) > 0.7);
R_ans(:,4) = or(buf(:,1),buf(:,2));
R_ans(:,4) = or(R_ans(:,4),buf(:,3));
ResCwtMat = zeros([length(f) length(PPGTime)]);

for index = 1:length(PPGTime)
    
    %[~,~,~,inmodel,stats,~,~] = stepwisefit(X,real(cwtMat(:,index,1)),'display','off');
    %mdl = stepwiselm(X,real(cwtMat(:,index,1)),'Intercept',false,'Verbose',0);
    if ((cwtEnergyMat(index,1) < cwtEnergyMat(index,2))...
            || (cwtEnergyMat(index,1) < cwtEnergyMat(index,3))...
            || (cwtEnergyMat(index,1) < cwtEnergyMat(index,4)) && (R_ans(index,4)))
        X = [cwtPowerMat(:,index,2) cwtPowerMat(:,index,3) cwtPowerMat(:,index,4)];
        mdl = stepwiselm(X,cwtPowerMat(:,index,1),'interactions','Verbose',0,'Intercept',true,'Upper','interactions','Criterion','adjrsquared');
        %[~,~,~,~,stats,~,~] = stepwisefit(X,real(cwtMat(:,index,1)),'display','off');
        %ResCwtMat(:,index) = stats.yr + stats.intercept;
        angleOrig = angle(cwtMat(:,index,1));
        if mdl.Formula.HasIntercept
            ResCwtMat(:,index) = real(cwtMat(:,index,1));% -table2array(mdl.Coefficients('Intercept','Estimate'));
        else
            ResCwtMat(:,index) = real(cwtMat(:,index,1));
        end
        if table2array(mdl.VariableInfo('x1','InModel'))
            ResCwtMat(:,index) = ResCwtMat(:,index) - table2array(mdl.Coefficients('x1','Estimate'))*real(cwtMat(:,index,2));
        end
        if table2array(mdl.VariableInfo('x2','InModel'))
            ResCwtMat(:,index) = ResCwtMat(:,index) - table2array(mdl.Coefficients('x2','Estimate'))*real(cwtMat(:,index,3));
        end
        if table2array(mdl.VariableInfo('x3','InModel'))
            ResCwtMat(:,index) = ResCwtMat(:,index) - table2array(mdl.Coefficients('x3','Estimate'))*real(cwtMat(:,index,4));
        end 
        %ResCwtMat(:,index) = ResCwtMat(:,index).* real(exp(1j * angleOrig));
        %ResCwtMat(:,index) = (mdl.Residuals.Raw + table2array(mdl.Coefficients('(Intercept)','Estimate'))).* real(exp(1j * angleOrig));
        %ResCwtMat(:,index) = mdl.Residuals.Raw;
        %ResCwtMat(:,index) = stats.yr + stats.intercept;
    else
        ResCwtMat(:,index) = real(cwtMat(:,index,1));
    end
end

[timeArray2] = multiICWT(ResCwtMat,f,meanSignal);
figure();
subplot(3,1,1);
plot(PPGTime,NoiseData(:,1));
ylimRaw = ylim;
subplot(3,1,2);
plot(PPGTime,timeArray(:,1));
ylim(ylimRaw);

NoiseFilterData = filtfilt(Hd.numerator,1,NoiseData(:,1));
filterTimeArray2 = filtfilt(Hd.numerator,1,timeArray2);
R = corrcoef(NoiseFilterData,FilteredPPG);
R2 = corrcoef(timeArray2,FilteredPPG);
R3 = corrcoef(filterTimeArray2,FilteredPPG);

subplot(3,1,3);
plot(PPGTime,filterTimeArray2);
ylim(ylimRaw);
[timeArray2Pks,timeArray2Locs] = findpeaks(filterTimeArray2,PPGTime,'MinPeakDistance',0.5);
hold on;
plot(timeArray2Locs,timeArray2Pks,'b*');
[diffTimeArrayPPGPks,anomalyTimeArrayPPGPoint,anomalyTimeArrayPPGLocs] = diffPeakAnomalyDetect(timeArray2Pks,timeArray2Locs,1.2);
plot(anomalyTimeArrayPPGLocs,anomalyTimeArrayPPGPoint,'ro');
[filteredPPGPks,filteredPPGLocs] = findpeaks(FilteredPPG,PPGTime,'MinPeakDistance',0.5);

[diffPPGPks,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(filteredPPGPks,filteredPPGLocs,1.2);



errorRate = ansMat -ResCwtMat;
errorRate = sum(errorRate);
errorRate = sum(errorRate);