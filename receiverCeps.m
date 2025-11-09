function [TractPoles,TractG,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames, glottMode] = receiverCeps(files)

FFerr = [];

d = load(files.transmit);
glottMode = d.glottMode;
%% convert integers back to double

fid(1) = fopen(files.lpc,'r');
fid(2) = fopen(files.excite,'r');

fMode = '2bit';%'3bit';%'4bit';%'8bit';%'double'; %'4bit';
switch fMode
  case 'double'
    LPCcep  = fread(fid(1),[d.KeepCeps, d.nFrames],'double'); %double float
    fundExcite  = fread(fid(2),'double');
    if d.glottMode == "feedforward"
      fid(3) = fopen('fErr.dat','r');
      FFerr   = fread(fid(3),[d.WinL, d.nFrames],'double');
    end
  case '8bit'
    LPCcep = fread(fid(1),[d.KeepCeps, d.nFrames],'int8=>double') / d.sc.Cep / 127;
    fundExcite = (fread(fid(2),'uint8=>double'));%no scaling
    % fundExcite(fundExcite==0) = NaN; %patches since later code uses NaN to indicate no speech
  case '4bit'
    LPCcep = fread(fid(1),[d.KeepCeps, d.nFrames],'bit4=>double') / d.sc.Cep / 7;
    fundExcite = fread(fid(2),d.nFrames,'bit4=>double') / d.sc.Cep / 7 + d.sc.MeanFund;
  case '3bit'
    LPCcep = fread(fid(1),[d.KeepCeps, d.nFrames],'bit3=>double') / sc.Cep / 3;
    fundExcite = fread(fid(2),d.nFrames,'bit3=>double') / d.sc.Cep / 3 + d.sc.MeanFund;
  case '2bit'
    LPCcep = fread(fid(1),[d.KeepCeps, d.nFrames],'bit2=>double') / d.sc.Cep / 1;
    fundExcite = fread(fid(2),d.nFrames,'bit2=>double') / d.sc.Cep / 1 + d.sc.MeanFund;
end

fclose('all');

%% put cepstral coeffs back to LPC coeffs
LPCcep(end+1:d.p,:) = 0;

TractPoles = nan(d.p, d.nFrames);

for i = 1:d.nFrames
    TractPoles(:,i) = cepstral2lpc(LPCcep(:,i));
end
TractG = ones(1,d.nFrames);
% saved space by not sending gains

fundExcite(fundExcite == 0) = nan;

nFrames = double(d.nFrames);
WinL = double(d.WinL);
FrameL = double(d.FrameL);
Ns = double(d.Ns);
Fs = double(d.Fs);

end
