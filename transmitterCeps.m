function file = transmitterCeps(LPCcep,...
    fundExcite,nFrames,WinL,FrameL,Ns,Fs,KeepCeps,p,glottMode) 
%% convert to integers for data size reduction
fMode = '2bit';%'3bit';%'4bit';%'8bit';%'double';%'4bit';

fid(1) = fopen('LPCcep.dat','w+');
sc.Cep = 1/max(max(LPCcep));
fid(2) = fopen('fExcite.dat','w+');
sc.MeanFund = mean(fundExcite(~isnan(fundExcite))); 
sc.fund = 1./max(fundExcite-sc.MeanFund);
switch fMode
    case 'double'
        fwrite(fid(1),LPCcep(1:KeepCeps,:),'double'); %float
        fwrite(fid(2),fundExcite,'double');
      
    case '8bit'
LPCcep = uint8(LPCcep(1:KeepCeps,:) * 127*sc.Cep);
fwrite(fid(1),LPCcep,'int8');
fundExcite = uint8(fundExcite);
fwrite(fid(2),fundExcite,'uint8');

    case '4bit'
LPCcepW = int8(LPCcep(1:KeepCeps,:) * 7 *sc.Cep);%4 bit
fwrite(fid(1),LPCcepW,'bit4');%4 bit

fundExcite = int8((fundExcite-sc.MeanFund) * 7 * sc.fund);
fwrite(fid(2),fundExcite,'bit4');
   case '3bit'
LPCcepW = int8(LPCcep(1:KeepCeps,:) * 3 *sc.Cep);
fwrite(fid(1),LPCcepW,'bit3');

fundExcite = int8((fundExcite-sc.MeanFund) * 3 * sc.fund);
fwrite(fid(2),fundExcite,'bit3');
   case '2bit'
LPCcepW = int8(LPCcep(1:KeepCeps,:) * 1 *sc.Cep);
fwrite(fid(1),LPCcepW,'bit2');

fundExcite = int8((fundExcite-sc.MeanFund) * 1 * sc.fund);
fwrite(fid(2),fundExcite,'bit2');
end

fclose('all');

file = 'transmitCeps.mat';
save(file,'nFrames','WinL','FrameL','Ns','Fs','glottMode','sc','KeepCeps','p')
clear LPCcep  fundExcite fid fMode 
%% get filesize info

LPCcepS = dir([pwd '/LPCcep.dat']); LPCcepS = LPCcepS.bytes;
fundExciteS = dir([pwd '/fExcite.dat']);  fundExciteS= fundExciteS.bytes;

total = whos; tot = 0;
for i = 1:length(total)
    tot = tot + total(i).bytes;
end
disp(['Transmitted Bytes: ',int2str(LPCcepS+fundExciteS)])
disp(['Transmitted at: ',num2str((LPCcepS+fundExciteS)/(Ns/Fs)*8),' bits per second'])
disp('Consisting of: ')
disp([int2str(LPCcepS),' bytes for Cepstral LPC model coeff. (short-time segments),'])
disp([int2str(fundExciteS),' bytes for Glottal Excitation'])
end %function