function [resWave] = cwtPeakDetect(x,Fs,lowFreq,highFreq,animeEnable,lowCatSize,highCatSize,movieSaveIs)
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述

cwtTimeBandWidth = 119;
cwtVoicesPerOctave = 48;
[wt,f,coi] = cwt(x,'morse',Fs,'TimeBandwidth',cwtTimeBandWidth,'VoicesPerOctave',cwtVoicesPerOctave,'FrequencyLimits',[lowFreq highFreq]);
Ts = 1 / Fs;
time = (0:1:length(x)-1)*Ts;
if animeEnable
    animeWindow = figure();
    ymin = min(min(abs(wt)));
    ymax = max(max(abs(wt)));
end


if movieSaveIs && animeEnable
    video(length(x)) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('.\hideo\res.avi','Uncompressed AVI');
    open(v);
else
    video = '';
end

%freqPks = zeros(1,length(x));
%freqPksLocs = zeros(1,length(x));
FreqSpaceRes = zeros(length(f),length(x));
for timeIndex = 1:length(wt)
    instFreqSpace = wt(:,timeIndex);
    instFreqSpace = abs(instFreqSpace);
    [freqPks,freqPksLocs] = findpeaks(flipud(instFreqSpace),flipud(f),'MinPeakHeight',mean(instFreqSpace));
    for freqIndex = 1:length(freqPks)
        freqPosition = find(f==freqPksLocs(freqIndex));
        FreqSpaceRes(freqPosition,timeIndex) = wt(freqPosition,timeIndex);
        for freqSerachIndex = 1:highCatSize
            searchIndex = freqPosition - freqSerachIndex;
            if searchIndex <= 0 
                break;
            end
            FreqSpaceRes(searchIndex,timeIndex) = wt(searchIndex,timeIndex);
        end
        for freqSerachIndex = 1:lowCatSize
            searchIndex = freqPosition + freqSerachIndex;
            if searchIndex > length(f)
                break;
            end
            FreqSpaceRes(searchIndex,timeIndex) = wt(searchIndex,timeIndex);
        end
    end
    if animeEnable
        endIndex = find(f>coi(timeIndex));
        if ~isempty(endIndex)
            endIndex = endIndex(end);
            animeLineData = instFreqSpace(1:endIndex);
        else
            animeLineData = '';
        end
        animeFreq = f(f>coi(timeIndex));
    end
    if timeIndex == 1 && animeEnable
        animeLine = plot(animeFreq,animeLineData);
        hold on;
        if ~null(animeFreq)
            animeLine.XDataSource = 'animeFreq';
            animeLine.YDataSource = 'animeLineData';
        end
    elseif (timeIndex > 1) && animeEnable
        if size(animeLine,1) == 0 && (~isempty(animeFreq))
            animeLine = plot(animeFreq,animeLineData);
            hold on;
            animeLine.XDataSource = 'animeFreq';
            animeLine.YDataSource = 'animeLineData';
        elseif ~isempty(animeFreq)
            refreshdata(animeLine,'caller');
            drawnow
        end
    end
    if animeEnable
        if ~isempty(freqPks)
            hold on;
            if exist('peakAnime','var')
                delete(peakAnime);
            end
            peakAnime = plot(freqPksLocs,freqPks,'ro');
            hold off;
        end
        xlabel('Frequency(Hz)');
        ylabel('Amplitude spectrum');
        ylim([ymin , ymax]);
        xlim([lowFreq , highFreq]);
        title(strcat('Time:',num2str(time(timeIndex)),'sec'));
        if movieSaveIs
            video(timeIndex) = getframe(animeWindow);
            writeVideo(v,video(timeIndex));
        end
    end
end
resWave = icwt(FreqSpaceRes,'morse','VoicesPerOctave',cwtVoicesPerOctave,'TimeBandwidth',cwtTimeBandWidth);
close;
end

