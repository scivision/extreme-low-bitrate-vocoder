function [xSynth, xSynthW, Excite, TractPoles, TractG] = receive(files, ProcType)
%% regenerate speech via glottal excitation
switch ProcType
  case 'LPC', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiver3(files);
  case 'keps', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiverCeps(files);
  otherwise, error('unknown ProcType')
end

[xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
  TractG,TractPoles,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,25,'receiver',false);

end
