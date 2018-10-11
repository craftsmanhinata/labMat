

[LoD,HiD,LoR,HiR] = wfilters(wname); 
subplot(2,2,1)
stem(LoD)
title('Decomposition Lowpass Filter')
subplot(2,2,2)
stem(HiD)
title('Decomposition Highpass Filter')
subplot(2,2,3)
stem(LoR)
title('Reconstruction Lowpass Filter')
subplot(2,2,4)
stem(HiR)
title('Reconstruction Highpass Filter')
xlabel(['The four filters for ',wname])