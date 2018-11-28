%RRI��PI�̔�r������
%�菇;ECG����,�@���΂炭�҂�, PPG����, PPG����, ECG����

%  SearchRRIUsingFIR1
% �t�B���^�[�̐ݒ�:Fl:1.35 Fh:1.4
% �덷:8 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g1
% �덷:7 ECG�I�t�Z�b�g:14 PPG�I�t�Z�b�g1
% �덷:6 ECG�I�t�Z�b�g:191 PPG�I�t�Z�b�g1
% SearchRRIUsingFIR1
% �t�B���^�[�̐ݒ�:Fl:1.28 Fh:1.4
% �덷:2 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g1
% �덷:1 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g753
% �덷:0 ECG�I�t�Z�b�g:14 PPG�I�t�Z�b�g753
% �t�B���^�[�̐ݒ�:Fl:1.3 Fh:1.4
% �덷:3 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g1
% �덷:2 ECG�I�t�Z�b�g:14 PPG�I�t�Z�b�g1
% �덷:1 ECG�I�t�Z�b�g:191 PPG�I�t�Z�b�g1
% SearchRRIUsingFIR1
% �t�B���^�[�̐ݒ�:Fl:1.31 Fh:1.4
% �덷:3 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g1
% �덷:2 ECG�I�t�Z�b�g:14 PPG�I�t�Z�b�g1
% �덷:1 ECG�I�t�Z�b�g:191 PPG�I�t�Z�b�g1
% SearchRRIUsingFIR1
% �t�B���^�[�̐ݒ�:Fl:1.26 Fh:1.4 0.2398
% �덷:1 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g1
% �덷:0 ECG�I�t�Z�b�g:1 PPG�I�t�Z�b�g150
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
disp(strcat('�t�B���^�[�̐ݒ�:Fl:',num2str(flc),' Fh:',num2str(fhc)));
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
                
                disp(strcat('�덷:',num2str(minCount),' ECG�I�t�Z�b�g:',num2str(bestECGOffset),' PPG�I�t�Z�b�g',num2str(bestPPGOffset)));
                if error == 0
                    [R,P] = corrcoef(procPI,procDeciRRI);
                    if(R(1,2) >= bestCoef)
                        bestCoef = R(1,2);
                        bestCoefPPGOffset = bestPPGOffset;
                        bestCoefECGOffset = bestECGOffset;
                        disp(strcat('���֌W��:',num2str(R(1,2))));
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
