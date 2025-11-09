function MyPlot(file,xSynth,xSynthW,Excite,TractPoles,TractG,formantFreqs)
load(file)


SI = pm.SnapInd; plotEn = pm.pe;
%MyPlot(tOrig,MySound,MyCeps,Ceps2D,pm,Ceps)
figure('pos',[70 50 800 820])
ax = subplot(3,1,1);
plot(ax,data.tOrig, data.Sound)
title(ax, "Time-domain waveform: " + pm.inputFile)
ylabel(ax,'Relative Amplitude')
xlabel(ax,'time [sec]')
ylim(ax, [-1 1])

% if plotEn(2)
% ax = subplot(3,1,2);
% plot(axT(2),data.tOrig, data.testWindSound)
% title(ax, "Time-domain Windowed Output (pre-proc): " + pm.inputFile)
% ylabel(ax,'Relative Amplitude'),xlabel(ax,'time [sec]')
% ylim(ax, [-1 1])
% end

ax = subplot(3,1,3);
plot(ax, data.tOrig, xSynth)
title(ax, "Time-domain Synthesized LPC output")
ylabel(ax,'Relative Amplitude'),xlabel(ax,'time [sec]')
ylim(ax, [-1 1])


%% nice plot
figure('pos',[70 50 800 820], Name='Spectral Analysis')
X = 20*log10(abs(fft(data.xFrame(:,SI))));

nfft = fix(length(X)/2);
hold on
[Hejw,freq]=freqz(TractG(SI),TractPoles(:,SI),nfft,'half',data.Fs);
Y = 20*log10(abs(Hejw));

plot(freq,Y, LineWidth=2, Color='r', DisplayName='LPC Spectrum')

plot(freq,X(1:nfft),'--', Color='yellow', Displayname='Original Spectrum (STFT)')

grid on

Finds = nan;
for i = 1:length(formantFreqs(formantFreqs(:,SI)>0,SI))
    Finds(i) = find(freq>formantFreqs(i,SI),1,'first');
end
if ~isnan(Finds)
plot(freq(Finds-1),Y(Finds-1),'x', Color='yellow', MarkerSize=15, LineWidth=2, Displayname='LPC Poles')
end

EXC = 20*log10(abs(fft(Excite(1:min(length(Excite),2*nfft))))); % ** TEMP **
if length(EXC)>1
plot(freq,EXC(1:nfft),'g', Displayname='Glottal Synth. Spect.')
end

% Synthesized Spectral plot
% SYNTH = 20*log10(abs(fft(xSynth)));
 SYNTH = 20*log10(abs(fft(xSynthW(:,SI)))); % ** TEMP **
plot(freq,SYNTH(1:nfft),'b','Displayname','Synth. VOICED Spect.')

legend('show')
title("Original spectrum at " + num2str(SI*pm.WinL/2/data.Fs) + " sec. vs. LPC model.")
xlabel('Frequency [Hz]')
ylabel('20*log10|X|')
ylim([-40 40])

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
clim([-100 -10])
axis('xy')
xlabel('Time [sec]')
ylabel('Frequency [Hz]')
title("FIR filtered Time-domain input spectrum: " + pm.inputFile)
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
