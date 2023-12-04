function [refFWHM,xVals]=Spots_LoadEffectiveSpecs(beamPart,myXwhat,config,spotType,relLev,absLev)
    if (~exist("myXwhat","var")), myXwhat="Range"; end
    if (~exist("config","var")), config="TM"; end
    if (~exist("spotType","var")), spotType="STEERPAZ"; end
    if (~exist("relLev","var")), relLev=0.1; end % default: 10%
    if (~exist("absLev","var")), absLev=1.0; end % default: 1 mm
    machine=["Sala1" "Sala2H" "Sala2V" "Sala3"];
    nSets=length(machine);
    FWHMs=missing();
    for iSet=1:nSets
        % - parse DB file
        [tmpEks,tmpMms,tmpFWHMs]=Spots_LoadRef(machine(iSet),beamPart,config,spotType);
        % - store data
        FWHMs=ExpandMat(FWHMs,tmpFWHMs);
        if (iSet==1)
            switch upper(myXwhat)
                case {"RANGE","R","MM"}
                    xVals=tmpMms;
                case {"ENERGY","EK","MEV"}
                    xVals=tmpEks;
                otherwise
                    error("...unable to understand request %s!",myXwhat);
            end
        end
    end
    % - compute actual reference
    switch upper(spotType)
        case {"STEERINGPAZIENTI","SP","STEERPAZ"}
            [refFWHM,refASYM]=Spots_MeritFWHM(FWHMs);
        case {"MEDICALPHYSICS","MP","MEDPHYS"}
            refFWHM=FWHMs;
        otherwise
            error("Unknown spot type %s!",spotType);
    end
    refFWHM=Spots_FWHMRefSeries(refFWHM,relLev,absLev);
end
