function xLift = lifter(xHat, Fs,Nq, select)

%xHat = complex cepstrum
%NL = quefrency cutoff sample index
% select = 'hicut' for rejecting high-time quefrencies, 'lowcut' for
% rejecting low-time quefrencies
L = length(xHat);
Lcent = round(L/2);

nNL = round(Fs/Nq*2); % index of cutoff quefrency
xLift = xHat;
% do low-time or high-time liftering
switch select
    case 'lowcut', xLift(Lcent-nNL+1 : Lcent + nNL - 1) = 0;
    case 'hicut', xLift([1:Lcent-nNL+1 , Lcent + nNL - 1:end]) = 0;
    otherwise, error('Improper select input to lifter.m')
end

