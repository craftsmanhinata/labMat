close all;
clear();
clc();
fileName = '20180627_180529_Test';
srcFolderName = '.\Data\';
dstFolderName = '.\Out\';
fileExtension = '.csv';

srcData = readtable(strcat(srcFolderName,fileName,fileExtension),'Delimiter',',','Format','%s%s%s%s');

PPGSig  = srcData(:,1);
PPGSig  = string(table2array(PPGSig));
PPGSig  = hex2Mathex(PPGSig);
PPGSig  = str2Fract(PPGSig);
PPGSig  = -1 * PPGSig.double;
PPGSig  = PPGSig * 3.3;
pd = fitdist(PPGSig,'normal');

figure();
histfit(PPGSig);
ylabel('Frequency');
xlabel('Voltage(V)');
disp(strcat('mu:',num2str(pd.mu)));
disp(strcat('sigma:',num2str(pd.sigma)));

Fs = 50;
Ts = 1 / Fs;
recordLength = length(PPGSig)*Ts;

disp(strcat('recordTime(sec):',num2str(recordLength)));
disp(strcat('recordTime(min):',num2str(recordLength/60)));

%–ñ30•ªŠÔ‚ÌŠÏ‘ª•ª•z‚ğZo