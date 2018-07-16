close all;
clear();
clc();
Fs = 50;
Ts = 1/Fs;

fhc = 1; %unit:[Hz]
NFhc = fhc/(Fs/2);
flc = 0.6;
NFlc = flc/(Fs/2);

adcBit = 12;
maxVoltage = 3.3;
minResVol = maxVoltage / (2^adcBit);
minResVoldb = db(minResVol);
margin = -2;
minResVoldb = minResVoldb + margin;
highFreqMargin = 3;
lowFreqMargin = 1.2;
Ap = 1.0;


D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',NFlc,NFlc*lowFreqMargin,NFhc,NFhc*highFreqMargin,-1*minResVoldb,Ap,-1*minResVoldb);
M = designmethods(D);
for index = 1:length(M)
    Hd(index) = design(D,cell2mat(M(index)));
end
fig = fvtool(Hd);
fig.Fs = Fs;
legend(M);