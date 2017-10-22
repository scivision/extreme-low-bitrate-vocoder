function [pm, data] = getSound(pm)
[data.Sound,data.Fs] = audioread(pm.file); % read in file and convert to vector data

data.Ns = length(data.Sound);
data.tOrig = 0:1/data.Fs:6; 
data.tOrig = data.tOrig(1:data.Ns)'; %sets up appropriate time vector

%% VOX
% this code avoids creating models for times when speech does not exist
firstInd = find(data.Sound > pm.thresStart,1);
lastInd = find(data.Sound>pm.thresEnd,1,'last');

data.Sound(1:firstInd-1) = 0;
data.Sound(lastInd+1:end) = 0;

%% filter sound 
%so as to "spend" filter coefficients on lowest, and hence
%most important, formants
if ~isnan(pm.LPFfreq)
FIRorder = 200; 
Wn = pm.LPFfreq /(data.Fs/2); %cutoff freq
FIRcoeff =  fir1(FIRorder,Wn); %designs FIR LPF coefficients
data.FiltSound = filter(FIRcoeff,1,data.Sound(:)); %implements FIR filter coeffcients
disp(['Input sound Low-Pass Filtered with cutoff frequency: ,',num2str(pm.LPFfreq),' Hz.'])
else
%disable LPF filter
data.FiltSound = data.Sound;
disp('Input sound was not Low-Pass filtered')
end

disp(['Frame length: ',num2str(pm.FrameL/data.Fs*1e3),' milliseconds (',num2str(pm.FrameL),' samples per frame)'])
disp(['Window length: ',num2str(pm.WinL/data.Fs*1e3),' milliseconds (',num2str(pm.WinL),' samples in window)'])
disp([pm.WinType,' Window overlap: ',num2str((pm.WinL-pm.FrameL)/pm.WinL*100,'%3.1f'),'%'])

end
