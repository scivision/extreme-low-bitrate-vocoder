function CompareOld()

lpcOld = 'archive/LPCcep.dat';
exciteOld = 'archive/fExcite.dat';
paramOld = 'archive/transmitCeps.mat';
plotOld = 'archive/AllVariables.mat';
outOld = 'archive/output.mat';

lpcNew = 'ref/LPCcep.dat';
exciteNew = 'ref/fExcite.dat';
paramNew = 'ref/transmitCeps.mat';
plotNew = 'ref/AllVariables.mat';
outNew = 'ref/output.mat';


[xSyntho, xSynthWo, Exciteo, TractPoleso, TractGo] = receive(paramOld, lpcOld, exciteOld);

[xSynthn, xSynthWn, Exciten, TractPolesn, TractGn] = receive(paramNew, lpcNew, exciteNew);

outputOld = load(outOld);
outputNew = load(outNew);

figure, hold on
title('old and new output waveform')
plot(xSyntho, DisplayName='old')
plot(xSynthn, DisplayName='new')
colorbar

figure
subplot(2,1,1)
title('old - new waveform')
plot(xSyntho - xSynthn)
subplot(2,1,2)
plot(outputOld.xSynth - outputNew.xSynth)




end