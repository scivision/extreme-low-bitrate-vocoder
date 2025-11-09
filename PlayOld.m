function PlayOld()

o = load('archive/output.mat');

MyPlot('archive/AllVariables.mat', o.xSynth, o.xSynthW, o.Excite, o.TractPoles, o.TractG)

player = audioplayer(o.xSynth, 8000);
playblocking(player)

end