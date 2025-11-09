function [xSynth, xSynthW, Excite, TractPoles, TractG] = Main(inputFile, playSound, doPlot)
arguments
  inputFile (1,1) string = "inputs/eeOrig.wav"
  playSound (1,1) logical = true
  doPlot (1,1) logical = true
end

plotFile = tempname + "_PlotVars.mat";
% shared for plotting while isolating namespace
paramFile = tempname + "_transmitCeps.mat";
lpcFile = tempname + "_LPCcep.dat";
exciteFile = tempname + "_fExcite.dat";
outputFile = tempname + "_output.mat";
%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams(inputFile);

transmit(plotFile, paramFile, pm, lpcFile, exciteFile, doPlot)

[xSynth, xSynthW, Excite, TractPoles, TractG] = receive(paramFile, lpcFile, exciteFile);

save(outputFile, 'xSynth', 'xSynthW', 'Excite', 'TractPoles', 'TractG')

if doPlot
  MyPlot(plotFile,xSynth,xSynthW,Excite)
end

if playSound
  ai = audiodevinfo();
  if isempty(ai)
    disp("no audio device found, skipping playback")
  else
    disp("Playing Synthesized Audio from Transmitted LPC Cepstrum and Excitation generated from " + pm.inputFile)
    player = audioplayer(xSynth, 8000);
    playblocking(player)
  end
end

end
