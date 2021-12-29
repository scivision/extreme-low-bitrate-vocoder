% Michael Hirsch 2011
function  AudioCepProc = Main()
assert(verLessThan('matlab', '9.10'), "dsp LPCToCepstral was removed in R2021a with no replacement")
%% (1a) Load waveform and parameters, and LPF waveform
pm = setParams();
[pm, data] = getSound(pm); %also LPF's and VOX detection
%% (1b) Apply window to data, so we can work with short-time sections
% window data
[data.xWind,data.xFrame,data.nFrames,data.window] = ...
        windowData(data.FiltSound, pm.WinL, pm.FrameL,pm.WinType);
%% (1c) Filterbank of filtered input waveform 
% Could be used to attenuate frequency bands with small amplitudes, that
% are not important to vocal tract resonances, or for a "spectrogram" type
% display
[ Xfb, XfbBins ]  = MyFilterbank(data.xWind,pm.WinL,data.Fs,pm.nFB);
%% (2) Cepstral alanysis to extract fundamental glottal impulse frequency
[fundExcite, LifteredGlottal] = estimateGlottalFreq(...
    data.xWind,data.nFrames,data.Fs,pm.WinL,pm.FrameL,pm.SnapInd,...
    pm.LiftHighQueRecp,pm.file,true);
% compute "cepstrogram" for later plotting
% the cepstrogram, like the spectrogram, is just the windowed short-time
% segments of the input signal put through a cepstral "lifterbank"
 data.Ceps2D = kepstrogram(data.xWind,data.nFrames);
%% LPC coefficient generation: vocal tract
[TractPoles, TractG, FFerr, formantFreqs] = GenerateLPCcoeff(...
    data.xWind,pm.p,data.nFrames,pm.WinL,pm.FrameL,...
    pm.PreEmphAlpha,data.Fs,pm.SnapInd,pm.LiftLowQueRecp,[],pm.file,'vtract',pm.glottMode,true);
%% test receiver w/o transmit TEST ONLY'
%[xSynth Excite] = genLPC(...
 %   TractG,TractPoles,fundExcite,FFerr,pm.Ns,data.Fs,pm.FrameL,pm.WinL,data.nFrames,pm.glottMode,pm.SnapInd,'transmitter',false);
%% LPC to Cepstrum
[LPCcep, CepsPoles, CepsG, CepsFFerr] = LPCceps(...
    data.xWind,TractG,TractPoles,fundExcite,pm.KeepLPCceps,FFerr,...
    data.nFrames,pm.WinL,pm.FrameL,data.Ns,data.Fs,pm.file,pm.glottMode,pm.p,pm.SnapInd,true);
%% plot cepstrum
[data.cepstr] = kepstrum(data.Sound);
Ceps2D = kepstrogram(data.xFrame,data.nFrames);
figure, imagesc(Ceps2D),title('Cepstrogram')
%% "transmit" data by saving to disk
ProcType = 'keps';
switch ProcType
    case 'LPC'
file = transmitter3(TractPoles,TractG,FFerr,...
    fundExcite,data.nFrames,pm.WinL,pm.FrameL,data.Ns,data.Fs,pm.p,pm.glottMode);
    case 'keps'
fileCeps = transmitterCeps(LPCcep,...
    fundExcite,data.nFrames,pm.WinL,pm.FrameL,data.Ns,data.Fs,pm.KeepLPCceps,pm.p,pm.glottMode);
end
save('AllVariables.mat') % used when plotting
%======================================
clear % clear entire Matlab memory    |
%======================================
% end of transmitter
%===========================================================
% lossless channel
%===========================================================
% Receiver Section
%% regenerate speech via glottal excitation
ProcType = 'keps';
switch ProcType
    case 'LPC'
[TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = ...
    receiver3('transmit.mat');
    case 'keps'
[TractPoles,TractG,LPCcep,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = ...
    receiverCeps('transmitCeps.mat');
end
        
[xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
    TractG,TractPoles,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,25,'receiver',false);


MyPlot('AllVariables.mat',xSynth,xSynthW,Excite,TractPoles,TractG)
end
