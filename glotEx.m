function [g, G, w] = glotEx(Ag,t0,tf,Tp,t,diag)
%  Produces simulated Glottal excitation pulses
%  Michael Hirsch Dec 2011
%
%  OUTPUTS:
%  --------
%  g = time-domain pulses
%  G = spectrum of pulses
%  w = frequency bin centers of G
% 
%  INPUTS:
%  --------
%  Ag = peak glottal pulse amplitude
%  t0 = time to start pulse waveform
%  tf = time of peak of waveform
%  Tp = end of waveform (most important parameter)
%  t = VECTOR of time samples used by calling program
%
%
%  References;
%  [1] Rosenberg
%  [2] J. Linden and J. Skoglund, Investigation on the Audibility of 
%  Glottal Parameter Variations in Speech Synthesis
if isnan(tf), g = nan; G = nan; w = nan; return, end
%% before excitation starts
t0ind = find(t>t0,1,'first');
g(1:t0ind) = 0; % find t0 index and fill with zeros

%% from excitation start to peak
tfInd = find(t>tf,1,'first');
g(t0ind:tfInd) = Ag*sin(pi/2*(t(t0ind:tfInd)-t0)/(tf-t0)).^2;

%% from excitation peak to end of pulse
TpInd = find(t>Tp,1,'first');
g(tfInd:TpInd) = Ag*cos(pi/2*(t(tfInd:TpInd)-tf)/(Tp-tf));

%% patch last point to be non-negative
if g(end)<0, g(end) = 0; end

%% make a column vector
g = g(:);
%% diag plot
if diag
    plot(t(1:length(g)),g,'.-k'),title('one cycle of glottal pulse')
    xlabel('time (time unit of input ''t'')')
    ylabel('Amplitude (dimensionless)')
end
%% spectrum
if nargout>1
    G = fft(g);
    w =[];
else
    G = []; w=[];
end

end %function
