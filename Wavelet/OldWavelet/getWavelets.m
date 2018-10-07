function [] = getWavelets(wname,scales)
%UNTITLED スケール変調したウェーブレットをplotする関数
%   詳細説明をここに記述
WT_Check = 5; % WTが5のとき, スケーリング関数(ファザーウェーブレット)を含まない複素ウェーブレットである
precis = 10; %計算精度.waveの長さを制御する. wave長は2^precis

figure();

WT = wavemngr('type',wname);
if(WT_Check ~= WT)
    msgID = 'GETWAVELET:InvalidWaveletmae';
    msg = strcat(wname,'はこの関数で使用できないウェーブレットです.');
    baseException = MException(msgID,msg);
    throw(baseException)
end
[Wave,timeWave] = wavefun(wname,precis);
%ウェーブレットのサンプリング周期の計算
WaveSamplingPeriod = timeWave(2) - timeWave(1);
%ウェーブレットのシフト. t = 0で波形が始まるように.
timeWave = timeWave - timeWave(1);
%ウェーブレットが終わる時刻を記録.
EndTime = timeWave(end);
for scaleIndex = 1 : length(scales)
    %ウェーブレットのスケール係数aの取得
    scaleCoeffA = scales(scaleIndex);
    waveIndex = 1 + floor((0:scaleCoeffA*EndTime)/...
        (scaleCoeffA*WaveSamplingPeriod));
    wavelet = 1/sqrt(scaleCoeffA) * Wave(waveIndex);
    waveletTime = timeWave(waveIndex)*scaleCoeffA-(EndTime / 2 * (scaleCoeffA - 1));
    curPeriod = waveletTime(2) - waveletTime(1);
    plot(waveletTime,real(wavelet));
    hold on;
end
end

