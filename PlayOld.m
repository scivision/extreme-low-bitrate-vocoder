function PlayOld()

load('archive/output.mat')

MyPlot('archive/AllVariables.mat',xSynth,xSynthW,Excite,TractPoles,TractG)

player = audioplayer(xSynth, 8000);
playblocking(player)

end