function MyPlot(file,xSynth,xSynthW,Excite,TractPoles,TractG,formantFreqs)
load(file)
SI = pm.SnapInd; plotEn = pm.pe;
%MyPlot(tOrig,MySound,MyCeps,Ceps2D,pm,Ceps)
figure('pos',[70 50 800 820])
axT(1) = subplot(3,1,1);
plot(axT(1),data.tOrig, data.Sound)
title(axT(1),['Time-domain waveform: ',pm.file])
ylabel(axT(1),'Relative Amplitude')
xlabel(axT(1),'time [sec]')
set(axT(1),'ylim',[-1 1])

% if plotEn(2)
% axT(2)=subplot(3,1,2);
% plot(axT(2),data.tOrig, data.testWindSound)
% title(axT(2),['Time-domain Windowed Output (pre-proc): ',pm.file])
% ylabel(axT(2),'Relative Amplitude'),xlabel(axT(2),'time [sec]')
% set(axT(2),'ylim',[-1 1])
% end

axT(3)=subplot(3,1,3);
plot(axT(3),data.tOrig, xSynth)
title(axT(3),['Time-domain Synthesized LPC output: ',pm.file])
ylabel(axT(3),'Relative Amplitude'),xlabel(axT(3),'time [sec]')
set(axT(3),'ylim',[-1 1])



%% nice plot
figure('pos',[70 50 800 820], Name='Spectral Analysis')
X = 20*log10(abs(fft(data.xFrame(:,SI))));

nfft = fix(length(X)/2);
hold on
[Hejw,freq]=freqz(TractG(SI),TractPoles(:,SI),nfft,'half',data.Fs);
Y = 20*log10(abs(Hejw));
plot(freq,Y,'linewidth',2,'color','r','displayname','LPC Spectrum');
plot(freq,X(1:nfft),'--k','Displayname','Original Spectrum (STFT)');
grid on
Finds = nan;
for i = 1:length(formantFreqs(formantFreqs(:,SI)>0,SI))
    Finds(i) = find(freq>formantFreqs(i,SI),1,'first');
end
if ~isnan(Finds)
plot(freq(Finds-1),Y(Finds-1),'kx','markersize',15,'linewidth',2,'displayname','LPC Poles')
end

EXC = 20*log10(abs(fft(Excite(1:min(length(Excite),2*nfft))))); % ** TEMP **
if length(EXC)>1
plot(freq,EXC(1:nfft),'g','Displayname','Glottal Synth. Spect.')
end

%Sythesized Spectral plot
%SYNTH = 20*log10(abs(fft(xSynth)));
 SYNTH = 20*log10(abs(fft(xSynthW(:,SI)))); % ** TEMP **
plot(freq,SYNTH(1:nfft),'b','Displayname','Synth. VOICED Spect.')

legend('show')
title(['Original spectrum at ',num2str(SI*pm.WinL/2/data.Fs),' sec. vs. LPC model.  File: ',file])
xlabel('Frequency [Hz]'),ylabel('20*log10|X|')
set(gca,'ylim',[-40 40])

if length(Excite)>1
%%glottal excitation
figure('pos',[70 50 520 460], Name='glottal excitation')
stem(data.tOrig(1:pm.WinL),Excite)
title('glottal excitation')
xlabel('time [sec]'),ylabel('amplitude [dimensionless]')
end
%% others
if plotEn(3)
figure
imagesc(data.tOrig,data.fAx,10*log10(abs(data.Pxx)))
set(gca,'Clim',[-100 -10])
axis xy
xlabel('Time [sec]'),ylabel('Frequency [Hz]')
title(['FIR filtered Time-domain input spectrum: ',pm.file])
%surf(10*log10(abs(Pxx)))
end
if plotEn(4)
   fCG= figure; axCepg = axes('parent',fCG);
imagesc(abs(log(data.Ceps2D)))
set(axCepg,'ydir','normal')
ylabel(axCepg,'Quefrency [samples]')
xlabel(axCepg,'frame #')
title('Cepstrogram (real)')
end

if plotEn(5)
figure
axCep = subplot(3,1,1);
plot(axCep,MyCeps(1:pm.tSind))
xlabel('Sample #')
ylabel('Cepstral Value')
title('Overall Cepstrum (real)')

Qlim = pm.CepsOrder;
axS(1) = subplot(3,1,2);
stem(MyCeps(1:Qlim))
title(['first ',int2str(Qlim),' Ceptstral quefrency samples over all t'])
ylabel('cepstral value')

axS(2) = subplot(3,1,3);
stem(Ceps2D(1:Qlim,pm.tFrameInd)); 
title(['first ',int2str(Qlim),' Cepstrum quefrency samples at t=',num2str(data.tOrig(2*pm.tSind),'%03.2f'),' sec'])
set(axS,'xlim',[0,Qlim],'xtick',1:Qlim)
end

if plotEn(5)
figure
subplot(2,1,1)
plot(Ceps.SigSpect)
wavplay(Ceps.SigOut,pm.Fs)
end
end
