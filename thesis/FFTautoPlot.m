function [Y] = FFTautoPlot(x,Fs)
%FFTAUTOPLOT FFTをそれっぽくプロットしてくれる関数
%   詳細説明をここに記述
Y = fft(x);
Y = fftshift(Y);
powerSpect = abs(Y/length(x));
phaseSpect = unwrap(angle(Y))*180/pi;
f = (-length(x)/2:length(x)/2-1)/length(x)*Fs;
figure();
subplot(1,2,1);
plot(f,powerSpect);
xlabel('f (Hz)');
ylabel('Power spectrum');
subplot(1,2,2);
plot(f,phaseSpect);
xlabel('f (Hz)');
ylabel('Phase spectrum');
end

