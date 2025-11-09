function[ FundExciteHz, LifteredGlottal ] = estimateGlottalFreq(xWind,nFrames,Fs,WinL,FrameL,SnapInd,LiftHighQue,file,diag)

StartQueSearch = round(Fs/400); %start quefrency index for Glottal Search
StopQueSearch = round(Fs/60); % stop quefrency index for Glottal Search

%pre allocation
C =               nan(WinL,nFrames);
CL =              nan(WinL,nFrames);
LifteredGlottal = nan(WinL,nFrames);
FundExciteHz =    nan(nFrames,1);


for i = 1:nFrames
  %X=fft(xWind);%.*hamming(length(xWind)));
  %C=real(ifft(log(abs(X))));
  C(:,i) = cceps(xWind(:,i)); %used Matlab's instead to get unwrapped phase

  if any(isnan(C(:,i)))
    disp(['bad data frame ',int2str(i)])
    continue
  end
%% lifter
  % remove high-time quefrencies, so glottal impulse train period can be estimated
  CL(:,i) = lifter(C(:,i), Fs, LiftHighQue, 'hicut');

  if nargout > 1
    LifteredGlottal(:,i) = icceps(CL(:,i));
  end
  %find fundamental
  %pick the quefrency with the highest amplitude -- since vocal tract
  %quefrencies have been liftered out, only glottal impulse train is left
  [~,fundFreq] = max(CL(StartQueSearch:StopQueSearch,i));
  FundExciteHz(i) = Fs / (StartQueSearch+fundFreq-1);
end %for


if diag
    StartAx=Fs/2000; %start quefrency for plot
    StopAx=Fs/50; % stop quefrency for plot
    que=(StartAx:StopAx)/Fs;

    figure
    stem(que,C(StartAx:StopAx,SnapInd),'r','displayname','un-liftered cepstrum'), hold on
    stem(que,CL(StartAx:StopAx,SnapInd),'displayname','Liftered Cepstrum'),
    title({['High-time Liftered Cepstrum into Glottal Excitation Estimator at Time: ',num2str(SnapInd*FrameL/Fs),' sec.'],...
        "1/Quefrency cutoff: " + num2str(LiftHighQue,'%03.1f') + " [s]   File: " + file})
    xlabel('Quefrency [s]'),ylabel('Cepstral Amplitude (relative)'),legend('show')

    disp(['For Time=',num2str(SnapInd*FrameL/Fs),' sec., Glottal Excitation Freq =',num2str(FundExciteHz(SnapInd),'%03.1f')]);
end %if

end
