function [Eks,Mms,FWHMs,myPos]=ParseMPrefFWHMfile(fileName,beamPart,loc)
% output vars:
% - size(FWHMs,1)=length(Ek)=lenght(Mms);
% - size(FWHMs,2)=length(myPos);
    if (~exist("beamPart","var")), beamPart=missing(); end
    if (~exist("loc","var")), loc=missing(); end
    if (ismissing(beamPart)), beamPart="Prot"; end % default
    if (ismissing(loc)), loc="ISO"; end % default
    fprintf("parsing MedPhys ref file for FWHM values %s ...\n",fileName);
    myData=readmatrix(fileName,"NumHeaderLines",1);
    switch upper(beamPart)
        case {"P","PROT","PROTON"}
            Eks=myData(:,3);
        case {"C","CARB","CARBON"}
            Eks=myData(:,2);
        otherwise
            error("Unknown particle %s!",beamPart);
    end
    Mms=myData(:,4);
    switch upper(loc)
        case "ISO"
            FWHMs=myData(:,8);
            myPos=713E-3; % [m]
        case "ALL"
            FWHMs=myData(:,6:9);
            myPos=[40 363 713 1213]*1E-3; % [mm]
        otherwise
            error("Unknown location to filter: %s",loc);
    end
    fprintf("...load data at %d locations;\n",length(myPos));
end
