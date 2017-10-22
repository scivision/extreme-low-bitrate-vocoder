function [xWind,xFramed,nFrames,window] = windowData(x, WinL, FrameL,WinType)
% x = input data vector to be windows
% WinL = length of each window [samples]
% FrameL = number of samples to "hop" over for each window. 
%    e.g. if FrameL = WinL/2, then there is 50% overlap of samples in each
%    window
% WinType = MATLAB standard window type to use
sizeX = size(x);
if numel(sizeX)>2, error('x must be a vector input to windowData.m')
elseif min(sizeX)>1, error('x must be a vector input to windowData.m')
end

x = x(:); %make column vector

Ns = max(sizeX);
Overlap = WinL-FrameL; %[samples] number of overlapped samples in each window
%postpend zeros if window length wasn't an even divisor of overall # of
%samples
nZeroPad = mod(Ns,WinL); 
if nZeroPad, x(end+1:end+nZeroPad) = 0; 
disp([int2str(nZeroPad),' zeros were postpended to the last frame of data'])
end

switch WinType
    case 'hann', window = hann(WinL,'symmetric');
    case 'bartlett', window = bartlett(WinL);
    case 'hamming', window = hamming(WinL,'symmetric');
    case 'rect', window = ones(WinL);
    otherwise, error('Unknown window type used in windowData.m')
end
%% vectorized approach to windowing data
%note: when you see 'ones(1,nFrames)' used, it's just like using 'repmat'
%to replicate the window or i data across each column!

% each column of data is a windowed segment of data. 
nFrames = fix((Ns-Overlap)/FrameL); % Number of short-time frames
 % stores start value for each frame of windows data. "Hops" over by FrameL
 % data points for each window
cInd = (0:(nFrames-1)) * (WinL-Overlap) + 1; 
% we will have WinL values of data in each frame
rInd = (1:WinL)';
xFramed = zeros(WinL,nFrames); %initialize matrix
% Put x into windowed columns
xFramed(:) = x( repmat(rInd,1,nFrames) +...
                 repmat(cInd,WinL,1)...
                 - 1);

% Apply the window to short-time segments
xWind = repmat(window,1,nFrames).*xFramed;
end