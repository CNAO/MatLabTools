function [Mms,FWHMs]=ParseSphinxRefFWHMfile(fileName,machine,beamPart)
% output vars:
% - size(FWHMs,1)=length(Mms);
% - size(FWHMs,2)=3 (ie FWHMx, FWHMy, mean(FWHMx,FWHMy));
    if (~exist("machine","var")), machine=missing(); end
    if (~exist("beamPart","var")), beamPart=missing(); end
    if (ismissing(machine)), machine="Sala1"; end % default
    if (ismissing(beamPart)), beamPart="Prot"; end % default
    fprintf("parsing Sphinx ref file for FWHM values %s ...\n",fileName);
    switch upper(beamPart)
        case {"P","PROT","PROTON"}
            myData=readmatrix(fileName,"Range","A3:M11");
        case {"C","CARB","CARBON"}
            myData=readmatrix(fileName,"Range","A15:M24");
        otherwise
            error("Unknown particle %s!",beamPart);
    end
    Mms=myData(:,1);
    switch upper(machine)
        case "SALA1"
            FWHMs=myData(:,2:4);
        case "SALA2H"
            FWHMs=myData(:,5:7);
        case "SALA2V"
            FWHMs=myData(:,11:13);
        case "SALA3"
            FWHMs=myData(:,8:10);
        otherwise
            error("Unknown machine: %s",machine);
    end
    fprintf("...data loaded: %d energies, %d series;\n",size(FWHMs,1),size(FWHMs,2));
end
