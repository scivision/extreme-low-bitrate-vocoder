function [LPCpoles, G, FFerr, formantFreqs] = GenerateLPCcoeff(...
    WindowedAudio,modelOrder,nFrames,WinL,FrameL,PreEmphAlpha,Fs,SnapInd,LiftLowQueRecp,LiftHighQueRecp,file,pMode,gMode,diag)
%MyLPC(pm,data,diag)
%diag: true to enable lifter output plot


%pre-allocate
formantFreqs(1:modelOrder,1:nFrames) = nan; CLift = nan(WinL,nFrames); Cwind = CLift;
G = nan(nFrames,1); LPCpoles = nan(modelOrder+1,nFrames);
FFerr = CLift;
for i = 1:nFrames
%% remove glottal impulses (or vocal tract) via cepstral liftering
if ~all(WindowedAudio(:,i) ==0)
    % preemphasize speech for LPC coding +6dB per octave
% by introducing a zero near w=0. This simulates lips!
            num = [1 -PreEmphAlpha]; den = 1;
WindowedAudio(:,i) = filter(num,den,WindowedAudio(:,i));
%WindowedAudio(:,i) = filter([1 -0.25],den,WindowedAudio(:,i)); %cascade additional pre-emphasis
Cwind(:,i) = cceps(WindowedAudio(:,i));
switch pMode
    case 'vtract'
CLift(:,i) = lifter(Cwind(:,i),Fs,LiftLowQueRecp,'lowcut');
LifteredVocalTract = icceps(CLift(:,i));
%xPreemph = filter([1 -0.65],den,xPreemph);  % cascade filter
    case 'glottal'
        CLift(:,i) = lifter(Cwind,LiftHighQueRecp,'hicut');
        xPreemph = icceps(CLift(:,i)); %no preemph for glottal
    otherwise, error(['unrecognized option',pMode,'in MyLPC'])
end


%% levinson-durbin recursion
    [LPCpoles(:,i),G(i)] = LevDurb(LifteredVocalTract,WinL,modelOrder);
      %[LPCpoles(:,i),G(i)] = lpc(xPreemph,modelOrder); 
      G(i) = sqrt(G(i));

    
    switch pMode
        case 'vtract'
   %% compute prediction errors
    FFerr(:,i) = filter(LPCpoles(:,i),G(i),WindowedAudio(:,i));
    %% find pole center frequencies
    LPCroots = roots(LPCpoles(:,i));
    LPCroots = LPCroots(imag(LPCroots)>0); %select formants on w = 0..pi/2
   % to find the location of a root, find its angle w.r.t. w = 0 using
   % atan2. 
 formantFreqs(1:length(LPCroots),i) = atan2(imag(LPCroots),real(LPCroots)); 




        case 'glottal'
            %formantFreqs(1,i) = NaN;
    end
       else FFerr(:,i) = nan; 
   end
end
formantFreqs = formantFreqs.*Fs/(2*pi); % since f = w/(2pi) and take Fs into account
% remove NaNs from zero data input frames
    G(isnan(G))=eps;
    %% put unstable poles to stable: 1/conj(p)
     %LPCpoles(abs(LPCpoles)>1) = -1./conj(LPCpoles(abs(LPCpoles)>1));
     % need to add all-pole gain scaling!
    Lunstable = sum(abs(LPCpoles)>1);
    iUnstable = find(Lunstable>0);
    Lunstable = sum(Lunstable);
    if Lunstable
      disp(['there were ',int2str(Lunstable),' poles detected outside unit circle in initial LPC model of voice tract.'])
      disp(['The unstable poles were in frames: ',int2str(iUnstable),])
    end
%% diag plot
if diag
    %plot
    figure,
    zplane(G(SnapInd),LPCpoles(:,SnapInd)), 
    title({['Poles/zeros of LPC Vocal Tract model @ Time= ',num2str(SnapInd*FrameL/Fs),' sec.'];...
        ['1/Quefrency cutoff: ',num2str(LiftLowQueRecp,'%03.1f'),' [s]  File: ',file]})
    
    
StartAx=Fs/1000;               
StopAx=Fs/50;                  
q=(StartAx:StopAx)/Fs;
figure, stem(q,CLift(StartAx:StopAx,SnapInd),'displayname','Liftered Cepstrum'), hold on, 
stem(q,Cwind(StartAx:StopAx,SnapInd),'r','displayname','un-liftered cepstrum') 
title({['Liftered Cepstrum into LPC Vocal Tract predictor at Time =  ',num2str(SnapInd*FrameL/Fs), ' sec.'],...
    ['1/Quefrency cutoff: ',num2str(LiftLowQueRecp,'%03.1f'),' [s]  File: ',file]})
xlabel('Quefrency [s]'),ylabel('Cepstral Amplitude (relative)'),legend('show')
end

end
