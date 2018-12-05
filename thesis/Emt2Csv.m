%�ؓd�v�̃f�[�^��csv�ɕϊ�����
clc;
clear;
srcFolderName = '.\ECGRawData\';
fileName = 'ECG20181204_16';
extension = '.emt';
outputExtension = '.csv';
data = dlmread(strcat(srcFolderName,fileName,extension),'\t',11,1);
outputDir = '.\ECG\';
csvwrite(strcat(outputDir,fileName,outputExtension),data);
time = data(:,1);
ECGData = data(:,2);
figure();
plot(time,ECGData);