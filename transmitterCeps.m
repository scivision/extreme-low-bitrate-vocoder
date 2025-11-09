function transmitterCeps(files, LPCcep,fundExcite,nFrames,WinL,FrameL,Ns,Fs,KeepCeps,p,glottMode)
%% convert to integers for data size reduction
fMode = '2bit';%'3bit';%'4bit';%'8bit';%'double';%'4bit';

fid(1) = fopen(files.lpc,'w+');
sc.Cep = 1/max(max(LPCcep));

fid(2) = fopen(files.excite,'w+');
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

save(files.transmit,'nFrames','WinL','FrameL','Ns','Fs','glottMode','sc','KeepCeps','p')
%% get file size info

LPCcepS = dir(files.lpc);
LPCcepS = LPCcepS.bytes;

fundExciteS = dir(files.excite);
fundExciteS= fundExciteS.bytes;

total = whos; tot = 0;
for i = 1:length(total)
  tot = tot + total(i).bytes;
end

disp(['Transmitted Bytes: ', int2str(LPCcepS+fundExciteS)])
disp(['Transmitted at: ', num2str((LPCcepS+fundExciteS)/(Ns/Fs)*8), ' bits per second'])
disp('Consisting of: ')
disp([int2str(LPCcepS), ' bytes for Cepstral LPC model coeff. (short-time segments),'])
disp([int2str(fundExciteS), ' bytes for Glottal Excitation'])

end
