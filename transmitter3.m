function transmitter3(transmitFile, TractPoles,TractG,FFerr, fundExcite,nFrames,WinL,FrameL,Ns,Fs, p, glottMode, tractPfile, tractGfile, exciteFile)
%% convert scale factors to integers for data size reduction

fMode = 'double';

fid(1) = fopen(tractPfile,'w+');
sc.TPsc = 1/max(max(TractPoles));
%TractPoles = int16(TractPoles * 32767*sc.TPsc);%16 bit
%fwrite(fid(1),TractPoles,'int16');%16 bit

fid(2) = fopen(tractGfile,'w+');
sc.TGsc = 1/max(max(TractG));

fid(3) = fopen(exciteFile,'w+');

%FFerr = int8(FFerr * sc.FFerr * 3); % 3 bit
%fwrite(fid(4),FFerr,'bit3'); % 3 bit

% FFerr = int8(FFerr * sc.FFerr * 15); % 4 bit
% fwrite(fid(4),FFerr,'bit4'); % 4 bit

switch fMode
  case 'double'
    fwrite(fid(1),TractPoles,'double');
    fwrite(fid(2),TractG,'double');
    fwrite(fid(3),fundExcite,'double');
    % if strcmp('feedforward',glottMode)
    %   fid(4) = fopen('fErr.dat','w+');
    %   sc.FFerr = 1/max(max(FFerr));
    %   fwrite(fid(4),FFerr,'double');
    % end
  case '8bit'
    TractPoles = int8(TractPoles * 127*sc.TPsc);%8 bit
    fwrite(fid(1),TractPoles,'int8');%8 bit
    TractG = uint8(TractG * 255*sc.TGsc);
    fwrite(fid(2),TractG,'uint8');
    fundExcite = uint8(fundExcite);
    fwrite(fid(3),fundExcite,'uint8');
    % FFerr = int8(FFerr * sc.FFerr * 127); % 8 bit
    % if strcmp('feedforward',glottMode)
    %   fid(4) = fopen('fErr.dat','w+');
    %   sc.FFerr = 1/max(max(FFerr));
    %   FFerr = int8(FFerr * sc.FFerr * 255); % 8 bit
    %   fwrite(fid(4),FFerr,'bit8'); % 8 bit
    % end
end

% FFerrS = dir(fullfile(pwd, 'fErr.dat'));
% FFerrS = FFerrS.bytes;

fclose('all');

nFrames = uint16(nFrames);
WinL = uint16(WinL);
FrameL = uint16(FrameL);
Ns = uint32(Ns); Fs = uint32(Fs);

save(transmitFile,'FFerr','nFrames','WinL','FrameL','Ns','Fs','glottMode','sc','p')

clear('TractG', 'TractPoles', 'GlottalG', 'GlottalPoles', 'fundExcite', 'FFerr', 'fid')

%% get filesize info
TractPolesS = dir(tractPfile);
TractGS = dir(tractGfile);
TractS = TractPolesS.bytes + TractGS.bytes;

fundExciteS = dir(exciteFile);  fundExciteS= fundExciteS.bytes;

total = whos;
tot = 0;
for i = 1:length(total)
  tot = tot + total(i).bytes;
end


fileInfo = dir(transmitFile);
disp(['MATLAB Compressed stored voice file size: ',int2str(fileInfo.bytes),' bytes'])
disp(['Transmitted Bytes: ',int2str(tot)])
disp(['Transmitted at: ',num2str(ceil((fundExciteS+FFerrS+TractS)/(double(Ns)/double(Fs)))*8),' bits per second'])
disp('Consisting of: ')
disp([int2str(TractS),' bytes for Vocal Tract LPC model (short-time segments),'])
disp([int2str(FFerrS),' bytes for Residual factors of Vocal Tract (correction factors)'])
disp([int2str(fundExciteS),' bytes for Glottal Excitation'])
disp([int2str(tot-(fundExciteS+FFerrS+TractS)),' bytes for all other overhead'])
end
