function indices=FlagPart(partCodes,what)
% particle codes:
% - 0: protons, S01;
% - 1: carbon ions, S01;
% - 2: protons, S02;
% - 3: carbon ions, S02;
    if ( ~exist('what','var') ), what="P"; end
    switch upper(what)
        case "P"
            indices=( partCodes==0 | partCodes==2 );
        case "C"
            indices=( partCodes==1 | partCodes==3 );
        otherwise
            error("unable to identify particle %s!",what);
    end
end