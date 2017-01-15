function [xSynth, xSynthW, Excite] = regenerateSignalFromLPCcoeff(...
    TractG,TractPoles,fundExcite,LPCerr,Ns,Fs,FrameL,WinL,nFrames,glottMode,SnapInd,Xmode,diag)
tOrig = 0:1/Fs:Ns/Fs;
tOrig = tOrig(1:Ns);
% consider moving excitation to front of window
xSynthW = zeros(WinL,nFrames);

for i = 1:nFrames
  switch glottMode
    case 'simul'
  if ~isnan(fundExcite(i)) && fundExcite(i)~=0
    FundPeriod = 1./fundExcite; %second

    Excite = glotEx(.5,FundPeriod(i)-0.0005,FundPeriod(i),FundPeriod(i)+0.00005,tOrig,false);

    Excite = repmat(Excite,ceil(WinL/length(Excite)),1);
    Excite = Excite(1:WinL);


    % consider moving excitation to front of window
    xSynthW(:,i) = filter(TractG(i),...
                      TractPoles(:,i),...
                      Excite);
  else 
        %leave zeros in this column of xSynthW
  end %if
        case 'feedforward'
        xSynthW(:,i) = filter(TractG(i), TractPoles(:,i),LPCerr(:,i));   
        Excite = nan;
  end %switch
end %for

if diag
    figure,zplane(TractG(SnapInd),TractPoles(:,SnapInd))
    title([Xmode,' pole/zero plot'])
end %if

xSynth = OLA(xSynthW,FrameL,WinL,Ns);  
xSynth = xSynth-mean(xSynth); %xSynth = xSynth./max(xSynth);
%plot(tOrig,xSynth)
player=audioplayer(xSynth,8000);
play(player)

end