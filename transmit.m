function transmit(plotFile, transmitFile, pm, lpcFile, exciteFile, diag)

[pm, data] = getSound(pm);
% also LPF's and VOX detection
%% (1b) Apply window to data, so we can work with short-time sections
% window data
[data.xWind,data.xFrame,data.nFrames,data.window] = ...
  windowData(data.FiltSound, pm.WinL, pm.FrameL,pm.WinType);
%% (1c) Filterbank of filtered input waveform
% Could be used to attenuate frequency bands with small amplitudes, that
% are not important to vocal tract resonances, or for a "spectrogram" display
% [ Xfb, XfbBins ]  = MyFilterbank(data.xWind, data.Fs, pm.nFB);
%% (2) Cepstral alanysis to extract fundamental glottal impulse frequency
fundExcite = estimateGlottalFreq(...
  data.xWind,data.nFrames,data.Fs,pm.WinL,pm.FrameL,pm.SnapInd,...
  pm.LiftHighQueRecp, pm.inputFile, diag);
% compute "cepstrogram" for later plotting
% the cepstrogram, like the spectrogram, is just the windowed short-time
% segments of the input signal put through a cepstral "lifterbank"
data.Ceps2D = kepstrogram(data.xWind,data.nFrames);
%% LPC coefficient generation: vocal tract
[TractPoles, TractG, FFerr, formantFreqs] = GenerateLPCcoeff(...
  data.xWind,pm.p,data.nFrames,pm.WinL,pm.FrameL,...
  pm.PreEmphAlpha,data.Fs,pm.SnapInd,pm.LiftLowQueRecp,[], pm.inputFile, 'vtract', diag);
%% test receiver w/o transmit TEST ONLY'
%[xSynth Excite] = genLPC(...
%   TractG,TractPoles,fundExcite,FFerr,pm.Ns,data.Fs,pm.FrameL,pm.WinL,data.nFrames,pm.glottMode,pm.SnapInd,'transmitter',false);
%% LPC to Cepstrum
LPCcep = LPCceps(...
  data.xWind, TractG, TractPoles, pm.KeepLPCceps, ...
  data.nFrames, pm.WinL, pm.FrameL, data.Fs, pm.inputFile, pm.p, pm.SnapInd, diag);
%% plot cepstrum
[data.cepstr] = kepstrum(data.Sound);
Ceps2D = kepstrogram(data.xFrame,data.nFrames);

if diag
figure
imagesc(Ceps2D)
title('Cepstrogram')
end

%% "transmit" data by saving to disk
ProcType = 'keps';
switch ProcType
  case 'LPC', transmitter3(transmitFile, TractPoles,TractG,FFerr, fundExcite,data.nFrames,pm.WinL,pm.FrameL,data.Ns,data.Fs,pm.p,pm.glottMode);
  case 'keps', transmitterCeps(transmitFile, LPCcep, fundExcite, data.nFrames, pm.WinL, pm.FrameL, data.Ns, data.Fs, pm.KeepLPCceps, pm.p, pm.glottMode, lpcFile, exciteFile);
end

save(plotFile, 'TractPoles', 'TractG', 'fundExcite', 'formantFreqs', 'data', 'pm')
% used for plotting only

end
