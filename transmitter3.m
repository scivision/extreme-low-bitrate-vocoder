function transmitter3(files, TractPoles,TractG,FFerr, fundExcite,nFrames,WinL,FrameL,Ns,Fs, p, glottMode)
%% convert scale factors to integers for data size reduction

fMode = 'double';

fid(1) = fopen(files.tractP,'w+');
sc.TPsc = 1/max(max(TractPoles));
%TractPoles = int16(TractPoles * 32767*sc.TPsc);%16 bit
%fwrite(fid(1),TractPoles,'int16');%16 bit

fid(2) = fopen(files.tractG,'w+');
sc.TGsc = 1/max(max(TractG));

fid(3) = fopen(files.excite,'w+');

%FFerr = int8(FFerr * sc.FFerr * 3); % 3 bit
%fwrite(fid(4),FFerr,'bit3'); % 3 bit

% FFerr = int8(FFerr * sc.FFerr * 15); % 4 bit
% fwrite(fid(4),FFerr,'bit4'); % 4 bit

switch fMode
  case 'double'
    fwrite(fid(1),TractPoles,'double');
    fwrite(fid(2),TractG,'double');
    fwrite(fid(3),fundExcite,'double');
    if glottMode == "feedforward"
      fid(4) = fopen(files.err, 'w+');
      sc.FFerr = 1/max(max(FFerr));
      fwrite(fid(4),FFerr,'double');
    end
  case '8bit'
    fwrite(fid(1), int8(TractPoles * 127*sc.TPsc), 'int8');

    fwrite(fid(2), uint8(TractG * 255*sc.TGsc), 'uint8');

    fwrite(fid(3), uint8(fundExcite), 'uint8');

    FFerr = int8(FFerr * sc.FFerr * 127); % 8 bit
    if glottMode == "feedforward"
      fid(4) = fopen(files.err, 'w+');
      sc.FFerr = 1/max(max(FFerr));
      FFerr = int8(FFerr * sc.FFerr * 255); % 8 bit
      fwrite(fid(4),FFerr,'bit8'); % 8 bit
    end
end

if glottMode == "feedforward"
  FFerrS = dir(files.err);
  FFerrS = FFerrS.bytes;
else
  FFerrS = 0;
end

fclose('all');

nFrames = uint16(nFrames);
WinL = uint16(WinL);
FrameL = uint16(FrameL);
Ns = uint32(Ns); Fs = uint32(Fs);

save(files.transmit,'FFerr','nFrames','WinL','FrameL','Ns','Fs','glottMode','sc','p')

clear('TractG', 'TractPoles', 'GlottalG', 'GlottalPoles', 'fundExcite', 'FFerr', 'fid')

%% get file size info
TractPolesS = dir(files.tractP);
TractGS = dir(files.tractG);
TractS = TractPolesS.bytes + TractGS.bytes;

fundExciteS = dir(files.excite);
fundExciteS= fundExciteS.bytes;

total = whos;
tot = 0;
for i = 1:length(total)
  tot = tot + total(i).bytes;
end


fileInfo = dir(files.transmit);
disp(['MATLAB Compressed stored voice file size: ',int2str(fileInfo.bytes),' bytes'])
disp(['Transmitted Bytes: ',int2str(tot)])
disp(['Transmitted at: ',num2str(ceil((fundExciteS+FFerrS+TractS)/(double(Ns)/double(Fs)))*8),' bits per second'])
disp('Consisting of: ')
disp([int2str(TractS),' bytes for Vocal Tract LPC model (short-time segments),'])
disp([int2str(FFerrS),' bytes for Residual factors of Vocal Tract (correction factors)'])
disp([int2str(fundExciteS),' bytes for Glottal Excitation'])
disp([int2str(tot-(fundExciteS+FFerrS+TractS)),' bytes for all other overhead'])
end
