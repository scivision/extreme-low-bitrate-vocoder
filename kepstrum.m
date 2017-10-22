function [xHat] = kepstrum(x)
%compute complex, non-unwrapped cepstrum
xHat =  real(ifft(log(abs(fft(x))))); 
end