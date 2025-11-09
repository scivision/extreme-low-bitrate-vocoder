function [A, G] = LevDurb(xWind,WinL,modelOrder)

%% compute autocorrelations
Rxx = nan(modelOrder+1,1);
for k=1:modelOrder+1
  Rxx(k)=sum(xWind(1:WinL-k+1).*xWind(k:WinL));
end

% https://www.mathworks.com/help/signal/ref/levinson.html
[A, EI] = levinson(Rxx, modelOrder);

A = A(:);
G = sqrt(EI);

end
