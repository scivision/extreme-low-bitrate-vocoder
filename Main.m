function plotFile = Main()

plotFile = tempname; % shared for plotting while isolating namespace
paramFile = tempname;
lpcFile = tempname;
exciteFile = tempname;
%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams();

transmit(plotFile, paramFile, pm, lpcFile, exciteFile)

[xSynth, xSynthW, Excite, TractPoles, TractG] = receive(paramFile, lpcFile, exciteFile);

MyPlot(plotFile,xSynth,xSynthW,Excite,TractPoles,TractG)

player = audioplayer(xSynth, 8000);
playblocking(player)

end
