function cepstrogram = kepstrogram(x,nFrames)
%% cepstrogram
cepstrogram = nan(size(x));

for i = 1:nFrames
  cepstrogram(:,i) = kepstrum(x(:,i));
end
%% pickoff real, unmirrored part of spectrum rows
cepstrogram = cepstrogram(1:fix(size(cepstrogram,1)/2),:);
end