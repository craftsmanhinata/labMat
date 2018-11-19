%筋電計のデータをcsvに変換する
clc;
clear;
srcFolderName = '.\ECGRawData\';
fileName = '0001~aa~627';
extension = '.emt';
outputExtension = '.csv';
data = dlmread(strcat(srcFolderName,fileName,extension),'\t',11,1);
outputDir = '.\ECG\';
csvwrite(strcat(outputDir,fileName,outputExtension),data);
time = data(:,1);
ECGData = data(:,2);
figure();
plot(time,ECGData);