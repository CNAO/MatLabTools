function indices=FlagPart(partCodes,what)
% particle codes:
% - 0: protons, S01, RFKO;
% - 1: carbon ions, S01, BETATRON;
% - 2: protons, S02, RFKO (occhio);
% - 3: carbon ions, S02, RFKO;
% - 5: He ions, SO3, RFKO;
% - 8: protons, S03, BETATRON (anche occhio);
% - 9: He ions, SO3, RFKO (occhio);
    if ( ~exist('what','var') ), what="P"; end
    switch upper(what)
        case "P"
            indices=( partCodes==0 | partCodes==2 | partCodes==8 );
        case "HE"
            indices=( partCodes==5 | partCodes==9 );
        case "C"
            indices=( partCodes==1 | partCodes==3 );
        otherwise
            error("unable to identify particle %s!",what);
    end
end
