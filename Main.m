% Michael Hirsch 2011
function  AudioCepProc = Main()

plotFile = tempname; % shared for plotting while isolating namespace
transmitFile = tempname;

%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams();

transmit(plotFile, transmitFile, pm)

[xSynth, xSynthW, Excite, TractPoles, TractG] = receive(transmitFile);

MyPlot(plotFile,xSynth,xSynthW,Excite,TractPoles,TractG)

end
