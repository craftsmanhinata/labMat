filterOrder = 2900;
Fs = 50;
cutoffFreq = 1.064;
highPass = fir1(filterOrder,cutoffFreq/(Fs/2),'high');
lowPass = fir1(filterOrder,cutoffFreq/(Fs/2),'low');
    
FontSize = 30;
fvtool(lowPass,1,'Fs',Fs)
xlim([0 3.0]);
title('Amplitude response(dB)','FontSize',FontSize);
ylabel('ylabel(dB)','FontSize',FontSize);
ylabel('Amplitude(dB)','FontSize',FontSize);
xlabel('Frequency(Hz)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
fvtool(highPass,1,'Fs',Fs)
xlim([0 3.0]);
title('Amplitude response(dB)','FontSize',FontSize);
ylabel('ylabel(dB)','FontSize',FontSize);
ylabel('Amplitude(dB)','FontSize',FontSize);
xlabel('Frequency(Hz)','FontSize',FontSize);
set(gca,'FontSize',FontSize);
