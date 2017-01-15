function x = OLA(xWind,FrameL,WinL,Ns)

% based off of Oppenheim p 670 and Proakis
% algorithm:
% 1) initialize vector x with zeros, for length of original signal
% 2) insert first column of xWind, length WinL samples into first positions of vector x
% 3) take second column of xWind samples, and increment in x vector by FrameL
% 4) add 2nd column to first column--some values overlap, compensating for
% window originally used
% 5) repeat this process across all columns of xWind

x = zeros(Ns,1); % Step 1

i = 1;
for tCurr = 0 : FrameL : Ns-WinL % steps by FrameL samples each iteration
  iCurr = tCurr + 1:tCurr+WinL; % updates with WinL length, jumping by FrameL each iteration 
  x(iCurr) = x(iCurr) + xWind(:,i); %implements Step 2 
  i = i + 1;  
end
end