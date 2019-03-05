%RRIとPIの比較をする
%手順;ECGつける,　しばらく待つ, PPGつける, PPG消す, ECG消す

%  SearchRRIUsingFIR1
% フィルターの設定:Fl:1.35 Fh:1.4
% 誤差:8 ECGオフセット:1 PPGオフセット1
% 誤差:7 ECGオフセット:14 PPGオフセット1
% 誤差:6 ECGオフセット:191 PPGオフセット1
% SearchRRIUsingFIR1
% フィルターの設定:Fl:1.28 Fh:1.4
% 誤差:2 ECGオフセット:1 PPGオフセット1
% 誤差:1 ECGオフセット:1 PPGオフセット753
% 誤差:0 ECGオフセット:14 PPGオフセット753
% フィルターの設定:Fl:1.3 Fh:1.4
% 誤差:3 ECGオフセット:1 PPGオフセット1
% 誤差:2 ECGオフセット:14 PPGオフセット1
% 誤差:1 ECGオフセット:191 PPGオフセット1
% SearchRRIUsingFIR1
% フィルターの設定:Fl:1.31 Fh:1.4
% 誤差:3 ECGオフセット:1 PPGオフセット1
% 誤差:2 ECGオフセット:14 PPGオフセット1
% 誤差:1 ECGオフセット:191 PPGオフセット1
% SearchRRIUsingFIR1
% フィルターの設定:Fl:1.26 Fh:1.4 0.2398
% 誤差:1 ECGオフセット:1 PPGオフセット1
% 誤差:0 ECGオフセット:1 PPGオフセット150
% 1.27~1.5 0.2369
% 0.2656 1.26~1.42
close all;
clear();

PPGInvOn = false;

Fs = 50;
Ts = 1 / Fs;

ECGFolder = 'ECG\';
fileNameECG = '2018112404stay03.csv';
fileNamePPG = '20181124_200114_Stay03.csv';
ECGData = csvread(strcat(ECGFolder,fileNameECG));
ECG = ECGData(:,2);


ECGFs = 1000;
ECGTs = 1 / ECGFs;
dECG = decimate(ECG,(ECGFs/Fs));
dECGTime = (0:length(dECG)-1) * Ts;


[dECGPks,dECGPksTime] = findpeaks(dECG,dECGTime,'MinPeakHeight',0.03,'MinPeakDistance',0.3);
[dRRI,anomalydECGPoint,anomalydECGLocs] = diffPeakAnomalyDetect(dECGPks,dECGPksTime,1.5);

allECGFigure = figure();
plot(dECGTime,dECG);
hold on;
plot(dECGPksTime,dECGPks,'ko');
plot(anomalydECGLocs,anomalydECGPoint,'ro');
title('ECG');


PPGFolder = 'PPG\';
PPGData = csvread(strcat(PPGFolder,fileNamePPG));
%PPGData = swappingDMA(PPGData,32);
PPG = detrend(PPGData(:,1));
if PPGInvOn
    PPG = PPG * -1;
end

% fhc = 1.4; %unit:[Hz]
fhc = 1.42;
NFhc = fhc/(Fs/2);
% flc = 1.1;
flc = 1.26;
NFlc = flc/(Fs/2);
disp(strcat('フィルターの設定:Fl:',num2str(flc),' Fh:',num2str(fhc)));
%orig 3000
b = fir1(3000,[NFlc NFhc]);
fvtool(b,'Fs',Fs);
FilteredPPG = filtfilt(b,1,PPG);
PPGTime = (0:length(FilteredPPG)-1) * Ts;
[PPGPks,PPGPksTime] = findpeaks(FilteredPPG,PPGTime,'MinPeakDistance',min(dRRI)*0.8);
[PI,anomalyPPGPoint,anomalyPPGLocs] = diffPeakAnomalyDetect(PPGPks,PPGPksTime,max(dRRI)*1.5);

allPPGFigure = figure();
plot(PPGTime,FilteredPPG);
hold on;
plot(PPGPksTime,PPGPks,'ko');
plot(anomalyPPGLocs,anomalyPPGPoint,'ro');
title('PPG');
procTime = 120;
procPoint = ( procTime / Ts );

ECGLoopCount = length(dECG) - procPoint;
PPGLoopCount = length(FilteredPPG) - procPoint;

minCount = Inf;
bestECGOffset = 0;
bestPPGOffset = 0;
bestCoef = -Inf;
RRIFig = figure();
if ~isempty(PI)
    for ECGOffset = 1:ECGLoopCount
        procDeciECG = dECG(ECGOffset:ECGOffset+procPoint);
        procDeciECGTime = dECGTime(ECGOffset:ECGOffset+procPoint);
        procECGStartTime = procDeciECGTime(1);
        procECGEndTime = procDeciECGTime(end);
        procDeciRRIIndex = intersect(find((dECGPksTime >= procECGStartTime)),find((dECGPksTime <= procECGEndTime)));
        procDeciRRI = dRRI(procDeciRRIIndex(1):(procDeciRRIIndex(end)-1));
        for PPGOffset = 1:PPGLoopCount
            procFilteredPPG = FilteredPPG(PPGOffset:PPGOffset+procPoint);
            procFilteredPPGTime = PPGTime(PPGOffset:PPGOffset+procPoint);
            procPPGStartTime = procFilteredPPGTime(1);
            procPPGEndTime = procFilteredPPGTime(end);
            procPIIndex = intersect(find((PPGPksTime >= procPPGStartTime)),find((PPGPksTime <= procPPGEndTime)));
            if(isempty(procPIIndex))
                continue;
            end
            procPI = PI(procPIIndex(1):(procPIIndex(end)-1));
            error = abs(length(procDeciRRI) - length(procPI));
            if error <= minCount
                minCount = error;
                bestECGOffset = ECGOffset;
                bestPPGOffset = PPGOffset;
                
                disp(strcat('誤差:',num2str(minCount),' ECGオフセット:',num2str(bestECGOffset),' PPGオフセット',num2str(bestPPGOffset)));
                if error == 0
                    [R,P] = corrcoef(procPI,procDeciRRI);
                    if(R(1,2) >= bestCoef)
                        bestCoef = R(1,2);
                        bestCoefPPGOffset = bestPPGOffset;
                        bestCoefECGOffset = bestECGOffset;
                        disp(strcat('相関係数:',num2str(R(1,2))));
                        figure(RRIFig);
                        plot(procDeciRRI);
                        hold on;
                        plot(procPI);
                        hold off;
                    end
                end
            end
        end
    end
end
