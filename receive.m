function [xSynth, xSynthW, Excite, TractPoles, TractG] = receive(transmitFile)
%% regenerate speech via glottal excitation
ProcType = 'keps';
switch ProcType
  case 'LPC', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiver3(transmitFile);
  case 'keps', [TractPoles,TractG,LPCcep,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiverCeps(transmitFile);
end

[xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
  TractG,TractPoles,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,25,'receiver',false);

end