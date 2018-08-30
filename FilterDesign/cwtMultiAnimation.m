function [resWaves,f,coi] = cwtMultiAnimation(observedValueMat,time,freqLimits,animeEnable)
%CWTMULTIANIMATION この関数の概要をここに記述
%   詳細説明をここに記述
if ~isrow(freqLimits)
    freqLimits = freqLimits';
end
if length(freqLimits) <= 1
    msgID = 'cwtMultiAnimation:inputError';
    msgtext = 'Frequency limits must have 2 elements';
    ME = MException(msgID,msgtext);
    throw(ME);
elseif length(freqLimits) > 2
    freqLimits = [freqLimits(1) freqLimits(2)];
end
cwtTimeBandWidth = 3.1;
cwtVoicesPerOctave = 48;
Ts = time(2) - time(1);
Fs = 1 / Ts;
[row,column] = size(observedValueMat);
if (row>column)
    %行ベクトル
    x = observedValueMat(:,1);
    dataDim = column;
else
    %列ベクトル
    x = observedValueMat(1,:);
    dataDim = row;
end
[wt,f,coi] = cwt(x,'morse',Fs,'TimeBandwidth',cwtTimeBandWidth,'VoicesPerOctave',cwtVoicesPerOctave,'FrequencyLimits',freqLimits);
resWaves = zeros([size(wt) dataDim]);
resWaves(:,:,1) = wt;

if dataDim >1
    for cwtLoop = 2:dataDim
        resWaves(:,:,cwtLoop) =  cwt(observedValueMat(cwtLoop,:),'morse',Fs,'TimeBandwidth',cwtTimeBandWidth,'VoicesPerOctave',cwtVoicesPerOctave,'FrequencyLimits',freqLimits);
    end
end
if animeEnable
    powerResWave = abs(resWaves);
    animeWindow = figure();
    ymin = min(min(min(powerResWave)));
    ymax = max(max(max(powerResWave)));
    LineInit = false;
    for timeIndex = 1:length(time)
        endIndex = find(f>coi(timeIndex));
        animeFreq = f(f>coi(timeIndex));
        if ~isempty(endIndex)
            endIndex = endIndex(end);
            animeLineData = zeros(endIndex,1,dataDim);
        end
        for cwtLoop = 1:dataDim
            if ~isempty(endIndex)
                animeLineData(:,:,cwtLoop) = powerResWave(1:endIndex,timeIndex,cwtLoop);
            else
                animeLineData = '';
                break;
            end
            if timeIndex == 1 && animeEnable
                if ~null(animeFreq)
                    animeLine(cwtLoop) = plot(animeFreq,animeLineData(:,:,cwtLoop));
                    hold on;
                    animeLine(cwtLoop).XDataSource = 'animeFreq';
                    animeLine(cwtLoop).YDataSource = 'animeLineData(:,:,cwtLoop)';
                    if cwtLoop == dataDim
                        LineInit = true;
                    end
                end
            elseif (timeIndex > 1) && animeEnable
                if (~isempty(animeFreq)) && (~LineInit)
                    animeLine(cwtLoop) = plot(animeFreq,animeLineData(:,:,cwtLoop));
                    hold on;
                    animeLine(cwtLoop).XDataSource = 'animeFreq';
                    animeLine(cwtLoop).YDataSource = 'animeLineData(:,:,cwtLoop)';
                    if cwtLoop == dataDim
                        LineInit = true;
                    end
                elseif ~isempty(animeFreq)
                    refreshdata(animeLine(cwtLoop),'caller');
                    drawnow
                end
            end
        end
        xlabel('Frequency(Hz)');
        ylabel('Amplitude spectrum');
        ylim([ymin , ymax]);
        xlim(freqLimits);
        title(strcat('Time:',num2str(time(timeIndex)),'sec'));
        hold off;
    end
end
%fb = cwtfilterbank('Wavelet','morse','TimeBandwidth',cwtTimeBandWidth,'VoicesPerOctave',cwtVoicesPerOctave,'SamplingFrequency',Fs,'FrequencyLimits',freqLimits);
%figure();
%freqz(fb);
%xlim([0 max(freqLimits)]);
%title('');
%ylabel('Magnitude','FontSize',26);
%xlabel('Frequency(Hz)','FontSize',26);
%gca.FontSize = 26;
%
end

