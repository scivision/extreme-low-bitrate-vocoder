%% configuration and load

function pm = setParams(inputFile)
% file can be:
% 'ahOrig.wav','ohOrig.wav','eeOrig.wav','Mine.wav','sinTest.wav'
pm.inputFile = inputFile;
pm.lpcProc = false; %if false, uses Cepstral coeff of LPC model
pm.pe = [1 0 0 0 0]; %decides which plots will be enabled
pm.SnapInd = 25; %index to look at a short-time frame for testing
pm.LPFfreq = NaN; %[Hz] frequency to low-pass input audio. If "NaN", filter is disabled

pm.glottMode = 'simul'; %'feedforward' % 'simul' for simulated response
pm.p = 15; %order of LPC model

% to lifter out glottal impulses when making LPC
pm.LiftHighQueRecp = 200; % 1/quefrency --> keeps quefrencies below this for glottal excitation measurement
pm.LiftLowQueRecp = 180; % 1/quefrency --> keeps quefrencies above this for vocal tract


pm.KeepLPCceps = 4; %how many LPC roots to keep from cepstrum
pm.PreEmphAlpha = .99; %PreEmphasis for LPC modeling--typical 0.95 for 6dB/octave

pm.WinType = 'hamming'; % window used on windowed sections of data
pm.WinL = 256; %Samples for windows data
pm.FrameL = fix(pm.WinL/2); %Samples for frame--for this project, I chose to fix this at 50%
pm.OverLap = pm.FrameL / pm.WinL;

pm.thresStart = 0.12;
pm.thresEnd = 0.15;

pm.nFB = 512; % number of filters in filter bank. pm.nFM >= pm.WinL  "M>=Nw" must be true.
if pm.nFB<pm.WinL, error('pm.nFB must be greater or equal to pm.WinL in setParams.m'), end

end
