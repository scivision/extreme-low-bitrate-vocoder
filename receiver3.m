function [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode] = receiver3(files)


load(files.transmit, 'p', 'nFrames', 'WinL', 'FrameL', 'Ns', 'Fs', 'glottMode', 'sc');
%% convert integers back to double

fid(1) = fopen(files.tractP,'r');
% TractPoles = fread(fid(1),[p+1,nFrames],'int16=>double') / sc.TPsc/ 32767; %int16
fid(2) = fopen(files.tractG,'r');
fid(3) = fopen(files.excite,'r');


%FFerr = fread(fid(4),[WinL,nFrames],'bit3=>double') / sc.FFerr / 3; % 3 bit
%FFerr = fread(fid(4),[WinL,nFrames],'bit4=>double') / sc.FFerr / 15; %4 bit
%FFerr = fread(fid(4),[WinL,nFrames],'int8=>double') / sc.FFerr / 127; % 8 bit


fMode = 'double';
switch fMode
  case 'double'
    TractPoles  = fread(fid(1),[p+1,nFrames],'double'); %double float
    TractG      = fread(fid(2),'double');
    fundExcite  = fread(fid(3),'double');%no scaling
    if strcmp('feedforward',glottMode)
      fid(4) = fopen(files.fErr,'r');
      FFerr   = fread(fid(4),[WinL,nFrames],'double');
    end
  case '8bit'
    TractPoles = fread(fid(1),[p+1,nFrames],'int8=>double') / sc.TPsc/ 127;
    TractG = fread(fid(2),'uint8=>double') / sc.TGsc / 255;
    fundExcite = (fread(fid(3),'uint8=>double'));%no scaling
    fundExcite(fundExcite==0) = NaN; %patches since later code uses NaN to indicate no speech
end

nFrames = double(nFrames); WinL = double(WinL); FrameL = double(FrameL);
Ns = double(Ns); Fs = double(Fs);

fileInfo = dir([pwd '\' file]);
disp(['Loaded voice file size: ',int2str(fileInfo.bytes),' bytes'])
end
