function [LPCcep, CepPoles, TractG, CepsFFerr] = LPCceps(WindowedAudio,TractG,TractPoles,fundExcite,KeepCeps,LPCerr,nFrames,WinL,FrameL,Ns,Fs,file,glottMode,modelOrder,SI,diag)
LPCcep = zeros(modelOrder+1,nFrames);

for i = 1:nFrames
    if ~isnan(TractPoles(:,i))
        %use MATLAB DSP Toolbox to implement LPC to complex Cepstrum recursion
  hlpc2cc = dsp.LPCToCepstral('CepstrumLengthSource','Auto',...
      'PredictionErrorInputPort',true);
 LPCcep(:,i) = step(hlpc2cc, TractPoles(:,i),TractG(i)); % Convert LPC to CC.
    end
end
%remove low values of LPC cepstrum, as they imply "less important"
%quefrency content
LPCcep(KeepCeps+1:end,:) = 0;
%%
for i = 1:nFrames
    %use MATLAB DSP Toolbox to implement Complex Cepstrum of LPCs, with
    %insignificant quefrencies set to zero amplitude, and convert back to
    %LPCs
    hcc2lpc=dsp.CepstralToLPC;
    CepPoles(:,i) = step(hcc2lpc,LPCcep(:,i));
    [Hejw(:,i), w(:,i) ] = freqz(TractG(i),CepPoles(:,i),WinL,'whole',Fs);
%% compute feedforward prediction errors
    CepsFFerr(:,i) = filter(CepPoles(:,i),TractG(i),WindowedAudio(:,i));
end

%%
if diag
 
figure
Y = 20*log10(abs(Hejw));
 title(['Cepstral compressed frequency response at t = ',num2str(SI*FrameL/Fs)])
xlabel('Frequency [Hz]'), ylabel('Cepstral Liftered LPC Magnitude Reponse (dB Relative)')
pCep = plot(w(1:fix(WinL/2),SI),Y(1:fix(WinL/2),SI),'linewidth',2,'color','r','displayname','LPC Spectrum');

for i = 1: numel(CepPoles)
    if abs(CepPoles(i))>1
       % insert code to correct here
    end
end

%     [xCep xCepW Excite] = regenerateSignalFromLPCcoeff(...
%     ones(1,nFrames),CepPoles,fundExcite,LPCerr,Ns,Fs,...
%     FrameL,WinL,nFrames,glottMode,SI,'Cepstral Processor',diag);
%     
stem(mean(LPCcep,2)); set(gca,'ylim',[-1 1])
title(['MEAN of LPC-cepstrum, ',file]),xlabel('quefrency(n)')

end

end