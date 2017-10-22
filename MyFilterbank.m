function [Xfb, fAx] = MyFilterbank(xWind,WinL,Fs,nfft)
% we use each column of data, and create frequency bins of data.

% note: the output is NOT amplitude scaled -- it's only relative amplitude
% algorithm:

% Step 1: take FFT of each DT column
X = fft(xWind,nfft,1); %operates down rows of windowed data

%Step 2: create labels for sampled value of DT frequency omega
FBbins = Fs/nfft; %how many frequency bins there will be
fAx = FBbins*(0:nfft-1); % set incremented values
fAx = fAx( 1:round(length(fAx)/2) ); %we only need lower half of values, since spectrum is symmetric due to real input signal

% Step 3: take only half the FFT outputs (since we are using symmetric
% freq. data)
Xfb = X(1:length(fAx),:);

end