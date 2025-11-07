% Michael Hirsch 2011
function  AudioCepProc = Main()

plotFile = tempname; % shared for plotting while isolating namespace
paramFile = tempname;
lpcFile = tempname;
exciteFile = tempname;
%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams();

transmit(plotFile, paramFile, pm, lpcFile, exciteFile)

[xSynth, xSynthW, Excite, TractPoles, TractG] = receive(paramFile, lpcFile, exciteFile);

MyPlot(plotFile,xSynth,xSynthW,Excite,TractPoles,TractG)

end
