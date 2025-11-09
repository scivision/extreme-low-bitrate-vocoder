function [xSynth, xSynthW, Excite, TractPoles, TractG] = receive(files)
%% regenerate speech via glottal excitation
ProcType = 'keps';
switch ProcType
  case 'LPC', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiver3(files.transmit);
  case 'keps', [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiverCeps(files.transmit, files.lpc, files.excite);
end

[xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
  TractG,TractPoles,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,25,'receiver',false);

end
