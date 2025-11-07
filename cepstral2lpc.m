function a = cepstral2lpc(c)
% cepstral2lpc - Convert cepstral coefficients to LPC coefficients
% Replacement for obsolete dsp.CepstralToLPC
%
% Syntax:
%   a = cepstral2lpc(c)
%
% Inputs:
%   c - Cepstral coefficients as column vector [c0 c1 c2 ... cp]'
%       where c0 is typically the log gain term
%
% Outputs:
%   a - LPC polynomial coefficients as column vector [1 a1 a2 ... ap]'
%       Returned in standard form with leading 1
%
% The recursion formulas (inverse of LPC to cepstral):
%   a(n) = -c(n) - sum_{k=1}^{n-1} (k/n) * c(k) * a(n-k)  for 1 <= n <= p
%
% Reference: Rabiner & Schafer, "Digital Processing of Speech Signals"

p = length(c) - 1;  % LPC order (subtract 1 for c0)

% Initialize LPC coefficients with leading 1
a = zeros(p+1, 1);
a(1) = 1;

% Compute LPC coefficients using recursion
for n = 1:p
    sum_term = 0;
    for k = 1:(n-1)
        sum_term = sum_term + (k/n) * c(k+1) * a(n+1-k);
    end
    a(n+1) = -c(n+1) - sum_term;
end

end
