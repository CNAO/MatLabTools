function indices=FlagPart(partCodes,what)
% particle codes:
% - 0: protons, S01, RFKO;
% - 1: carbon ions, S01;
% - 2: protons, S02, RFKO;
% - 3: carbon ions, S02;
% - 8: protons, S01, BETATRON;
    if ( ~exist('what','var') ), what="P"; end
    switch upper(what)
        case "P"
            indices=( partCodes==0 | partCodes==2 | partCodes==8 );
        case "C"
            indices=( partCodes==1 | partCodes==3 );
        otherwise
            error("unable to identify particle %s!",what);
    end
end
