function c = lpc2cepstral(a, g)
% lpc2cepstral - Convert LPC coefficients to cepstral coefficients
% Replacement for obsolete dsp.LPCToCepstral
%
% Syntax:
%   c = lpc2cepstral(a)
%   c = lpc2cepstral(a, g)
%
% Inputs:
%   a - LPC polynomial coefficients as column vector [a1 a2 ... ap]'
%       (predictor coefficients, does NOT include leading 1)
%   g - Optional: prediction error gain (scalar)
%       If provided, c(1) will be adjusted by log(g)
%
% Outputs:
%   c - Cepstral coefficients as column vector with length p+1
%       c(1) contains the gain term, c(2:end) are cepstral coeffs
%
% The recursion formulas are:
%   c(1) = log(g) if g provided, else log of error variance
%   c(n) = -a(n) - sum_{k=1}^{n-1} (k/n) * a(k) * c(n-k)  for 1 <= n <= p
%
% Reference: Rabiner & Schafer, "Digital Processing of Speech Signals"

p = length(a);  % LPC order

% Initialize cepstral coefficients
c = zeros(p+1, 1);

% First cepstral coefficient is related to the gain
if nargin >= 2 && ~isempty(g)
    c(1) = log(g);
else
    % If gain not provided, use a(1) to estimate
    c(1) = -a(1);
end

% Compute remaining cepstral coefficients using recursion
for n = 1:p
    if n == 1
        c(n+1) = -a(n);
    else
        sum_term = 0;
        for k = 1:(n-1)
            sum_term = sum_term + (k/n) * a(k) * c(n+1-k);
        end
        c(n+1) = -a(n) - sum_term;
    end
end

end
