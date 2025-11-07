function x = icceps(xceps,ndelay)
%ICCEPS Inverse complex cepstrum.
%   ICCEPS(xceps,ndelay) returns the inverse complex cepstrum of real xceps
%   that was delayed by ndelay samples.
%
% ported from https://github.com/python-acoustics/python-acoustics/blob/master/acoustics/cepstrum.py
% which has 3-clause BSD license.
%

if nargin<2
    ndelay = 0;
end

  log_spectrum = fft(xceps);
  spectrum = exp(real(log_spectrum) + 1j * wrap(imag(log_spectrum), ndelay));
  x = real(ifft(spectrum));
end %function


function wrapped = wrap(phase, ndelay)
    N = length(phase); % Number of samples
    center = (N+1)/2;
    wrapped = phase + pi * ndelay * (1:N)' / center;
end %function
