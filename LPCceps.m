function [LPCcep, CepPoles, CepsFFerr] = LPCceps(WindowedAudio,TractG,TractPoles,KeepCeps,nFrames,WinL,FrameL,Fs,file,modelOrder,SI,diag)

LPCcep = zeros(modelOrder+1,nFrames);

for i = 1:nFrames
  if ~isnan(TractPoles(:,i))
    % Convert LPC to cepstral coefficients
    LPCcep(:,i) = lpc2cepstral(TractPoles(2:end,i), TractG(i));
  end
end
% remove low values of LPC cepstrum, as they imply "less important" quefrency content
LPCcep(KeepCeps+1:end,:) = 0;

if diag

  for i = 1:nFrames
    % Convert cepstral coefficients back to LPC using custom function
    CepPoles(:,i) = cepstral2lpc(LPCcep(:,i));
    [Hejw(:,i), w(:,i) ] = freqz(TractG(i),CepPoles(:,i),WinL,'whole',Fs);
    % compute feedforward prediction errors
    if nargout > 2
      CepsFFerr(:,i) = filter(CepPoles(:,i),TractG(i),WindowedAudio(:,i));
    end
  end

%% diagnostic plot

  figure
  Y = 20*log10(abs(Hejw));
  title(['Cepstral compressed frequency response at t = ',num2str(SI*FrameL/Fs)])
  xlabel('Frequency [Hz]')
  ylabel('Cepstral Liftered LPC Magnitude Reponse (dB Relative)')
  plot(w(1:fix(WinL/2),SI),Y(1:fix(WinL/2),SI),'linewidth',2,'color','r','displayname','LPC Spectrum');

  for i = 1: numel(CepPoles)
    if abs(CepPoles(i))>1
      % FIXME: insert code to correct here
    end
  end

  stem(mean(LPCcep,2))
  ylim([-1 1])
  title("MEAN of LPC-cepstrum " + file)
  xlabel('quefrency(n)')

end

end
