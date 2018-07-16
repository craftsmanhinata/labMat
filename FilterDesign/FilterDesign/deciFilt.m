Fs = 200;
Ts = 1 / Fs;


adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = 1;
minResVoldb = minResVoldb + margin;

scale = 4;
FilterTap = scale * 2 - 1;
D = fdesign.lowpass('N,Fc,Ap,Ast',FilterTap,1/scale,1,-1*minResVoldb);
%designmethods(D)
Hd = design(D,'equiripple');
Hd.Arithmetic = 'fixed';
Hd.CoeffWordLength = 16;
fvtool(Hd,'Fs',Fs);

filterGroupDelay = grpdelay(Hd,100,Fs);
filterGroupDelay = mean(filterGroupDelay);
filterDelayTime = Ts * filterGroupDelay;

fixFilt = float2Fract(Hd.numerator);
fixFilt = fract2HexStr(fixFilt);