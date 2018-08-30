close all;
clear();
clc();

fileName = '20180712_150736_Test';
srcFolderName = '.\Data\';
dstFolderName = '.\Out\';
fileExtension = '.csv';
srcData = readtable(strcat(srcFolderName,fileName,fileExtension),'Delimiter',',','Format','%s%s%s%s');
PPGSig  = srcData(:,1);
PPGSig  = string(table2array(PPGSig));
PPGSig  = hex2Mathex(PPGSig);
PPGSig  = str2Fract(PPGSig);
PPGSig  = PPGSig.double * 1;

FixedPoint = srcData(:,1);
FixedPoint = string(table2array(FixedPoint));
FixedPoint = hex2Mathex(FixedPoint);
FixedPoint = str2Fract(FixedPoint);
FixedPoint = FixedPoint.hex;

test = FixedPoint(34,1:4);
