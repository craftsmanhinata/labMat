%dspic用のフィルタ設計プログラムexample
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

%0x7fff +1
%0x8000 -1
maxFract = float2Fract(1.1);
minFract = float2Fract(-1.1);