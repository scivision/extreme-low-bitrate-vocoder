function [xSynth, xSynthW, Excite, TractPoles, TractG] = receive(paramFile, lpcFile, exciteFile)
%% regenerate speech via glottal excitation
ProcType = 'keps';
switch ProcType
  case 'LPC', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiver3(paramFile);
  case 'keps', [TractPoles,TractG,LPCcep,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiverCeps(paramFile, lpcFile, exciteFile);
end

[xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
  TractG,TractPoles,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,25,'receiver',false);

end