function [TractPoles,TractG,LPCcep,fundExcite,FFerr,Ns,Fs,FrameL,WinL,nFrames,glottMode]...
    = receiverCeps(file)
FFerr = [];
load(file)
%% convert integers back to double

fid(1) = fopen('LPCcep.dat','r');
fid(2) = fopen('fExcite.dat','r');

fMode = '2bit';%'3bit';%'4bit';%'8bit';%'double'; %'4bit';
switch fMode
    case 'double'
        LPCcep  = fread(fid(1),[KeepCeps,nFrames],'double'); %double float
        fundExcite  = fread(fid(2),'double');
        if strcmp('feedforward',glottMode)
        fid(3) = fopen('fErr.dat','r');
        FFerr   = fread(fid(3),[WinL,nFrames],'double');
        else FFerr = [];
        end
    case '8bit'
LPCcep = fread(fid(1),[KeepCeps,nFrames],'int8=>double') / sc.Cep / 127;
fundExcite = (fread(fid(2),'uint8=>double'));%no scaling
% fundExcite(fundExcite==0) = NaN; %patches since later code uses NaN to indicate no speech
    case '4bit'
LPCcep = fread(fid(1),[KeepCeps,nFrames],'bit4=>double') / sc.Cep / 7;
fundExcite = fread(fid(2),nFrames,'bit4=>double') / sc.Cep / 7 + sc.MeanFund;
    case '3bit'
LPCcep = fread(fid(1),[KeepCeps,nFrames],'bit3=>double') / sc.Cep / 3;
fundExcite = fread(fid(2),nFrames,'bit3=>double') / sc.Cep / 3 + sc.MeanFund;
    case '2bit'
LPCcep = fread(fid(1),[KeepCeps,nFrames],'bit2=>double') / sc.Cep / 1;
fundExcite = fread(fid(2),nFrames,'bit2=>double') / sc.Cep / 1 + sc.MeanFund;
end

%% put cepstral coeffs back to LPC coeffs
LPCcep(end+1:p,:) = 0;
for i = 1:nFrames
hcc2lpc=dsp.CepstralToLPC;
    TractPoles(:,i) = step(hcc2lpc,LPCcep(:,i));
end
TractG = ones(1,nFrames); %saved space by not sending gains
%% nans
fundExcite(fundExcite == 0) = nan;

nFrames = double(nFrames); WinL = double(WinL); FrameL = double(FrameL);
Ns = double(Ns); Fs = double(Fs); 

fileInfo = dir([pwd '\' file]);
%display(['Loaded voice file size: ',int2str(fileInfo.bytes),' bytes'])
end
