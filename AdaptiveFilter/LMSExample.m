FrameSize = 100; 
NIter = 10;
lmsfilt2 = dsp.LMSFilter('Length',11,'Method','Normalized LMS', ...
    'StepSize',0.05);
firfilt2 = dsp.FIRFilter('Numerator', fir1(10,[.5, .75]));
sinewave = dsp.SineWave('Frequency',0.01, ...
    'SampleRate',1,'SamplesPerFrame',FrameSize);
TS = dsp.TimeScope('TimeSpan',FrameSize*NIter,'TimeUnits','Seconds',...
    'YLimits',[-3 3],'BufferLength',2*FrameSize*NIter, ...
    'ShowLegend',true,'ChannelNames', ...
    {'Noisy signal', 'Error signal'});
for k = 1:NIter
    x = randn(FrameSize,1);      
    d = firfilt2(x) + sinewave();
    [y,e,w] = lmsfilt2(x,d);
    TS([d,e])        
end
release(TS) 