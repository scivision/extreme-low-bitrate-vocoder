function [files, xSynth, xSynthW, Excite, TractPoles, TractG] = Main(inputFile, ProcType, playSound, doPlot)
arguments
  inputFile (1,1) string = "inputs/eeOrig.wav"
  ProcType (1,1) string = "keps"
  playSound (1,1) logical = true
  doPlot (1,1) logical = true
end

files.plot = tempname + "_PlotVars.mat";
% shared for plotting while isolating namespace
files.transmit = tempname + "_transmitCeps.mat";

files.excite = tempname + "_fExcite.dat";
files.out = tempname + "_output.mat";
switch ProcType
  case "keps"
    files.lpc = tempname + "_LPCcep.dat";
  case "LPC"
    files.tractG = tempname + "_tractG.dat";
    files.tractP = tempname + "_tractP.dat";
    files.err = tempname + "_err.dat";
  otherwise, error('unknown ProcType')
end
%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams(inputFile);

transmit(pm, files, ProcType, doPlot)

[xSynth, xSynthW, Excite, TractPoles, TractG] = receive(files, ProcType);

save(files.out, 'xSynth', 'xSynthW', 'Excite', 'TractPoles', 'TractG')

if doPlot
  MyPlot(files.plot, xSynth, xSynthW, Excite)
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
