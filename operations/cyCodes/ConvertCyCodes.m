function [vOut,Refs]=ConvertCyCodes(cyCodesIN,what,pathP,pathC,lDebug)
% ConvertCyCodes             converts a given list of cycle codes into a list 
%                              of corresponding beam energies or mm range
% input:
% - cyCodesIN (array of strings): array of cycle codes to be indentified/converted;
% - what (string, optional): variable requested:
%   . Ek (default): kinetic energies corresponding to the cyCodes [MeV(u];
%   . mm: mm-range corresponding to the cyCodes;
% - pathP (string, optional): path to MeVvsCyCo file for protons;
% - pathC (string, optional): path to MeVvsCyCo file for carbon ions;
% - lDebug (boolean, optional): activates debug mode;
%
% output:
% - vOut (array of floats): either beam energies [MeV/u] or range [mm] of each
%                           cyCodesIN;
% - Refs (array of floats x2): reference values in parsed .xlsx files
%                          (either beam energies [MeV/u] or range [mm]);
%
% NB: length(vOut)=length(cyCodesIN)=length(ZZin)
%
% See also: DecodeCyCodes, GetOPDataFromTables, MapCyCode and ParseMeVvsCyCo.

    % default requests
    if ( ~exist('what','var') ), what="Ek"; end
    if ( ~exist('pathP','var') ), pathP=1; end
    if ( ~exist('pathC','var') ), pathC=6; end
    if ( ~exist('lDebug','var') ), lDebug=false; end
    if ( ~strcmpi(what,"EK") & ~strcmpi(what,"MM") )
        error("Unable to recognize request %s",what);
    end
   
    % get reference cyCodes
    [P_Eks,P_cyCodes,P_mms]=ParseMeVvsCyCo(pathP);
    [C_Eks,C_cyCodes,C_mms]=ParseMeVvsCyCo(pathC);

    % in case of debug, show reference data
    if ( lDebug )
        switch upper(what)
            case "EK"
                ShowDebugRefData(P_Eks,"E_k [MeV/u]","Proton");
                ShowDebugRefData(C_Eks,"E_k [MeV/u]","Carbon");
            case "MM"
                ShowDebugRefData(P_mms,"range in water [mm]","Proton");
                ShowDebugRefData(C_mms,"range in water [mm]","Carbon");
        end
    end
    
    fprintf("converting cycodes into %s...\n",what);
    
    % get maps
    [rangeCodes,partCodes]=DecodeCyCodes(cyCodesIN);
    % verify that all particle codes are recognizable
    unidentified=(partCodes<0 | ( partCodes>3 & partCodes~=8 ) );
    if ( sum(unidentified)>0 )
        warning("unidentified particle in some cyCodes:\n%s",PrintUnidentified(cyCodesIN(unidentified)));
    end
    [lCCP,iCCP]=MapCyCode(rangeCodes,P_cyCodes);
    [lCCC,iCCC]=MapCyCode(rangeCodes,C_cyCodes);
    % verify that all ranges are recognizable
    unidentified=find(~lCCC & ~lCCP);
    if ( sum(unidentified)>0 )
        warning("unidentified range in some cyCodes:\n%s",PrintUnidentified(cyCodesIN(unidentified)));
    end
    
    % assign values
    vOut=NaN(length(cyCodesIN),1);
    indices_P=(lCCP & FlagPart(partCodes,"p") );
    indices_C=(lCCC & FlagPart(partCodes,"C") );
    Refs=NaN(max(length(P_cyCodes),length(C_cyCodes)),2);
    switch upper(what)
        case "EK"
            vOut(indices_P)=P_Eks(iCCP(indices_P));
            vOut(indices_C)=C_Eks(iCCC(indices_C));
            Refs(1:length(P_cyCodes),1)=P_Eks;
            Refs(1:length(C_cyCodes),2)=C_Eks;
        case "MM"
            vOut(indices_P)=P_mms(iCCP(indices_P));
            vOut(indices_C)=C_mms(iCCC(indices_C));
            Refs(1:length(P_cyCodes),1)=P_mms;
            Refs(1:length(C_cyCodes),2)=C_mms;
    end
    
end

function ShowDebugRefData(whatToShow,myYlabel,myTitle)
    figure();
    plot(whatToShow,"o"); hold on; plot(sort(whatToShow),".");
    grid(); xlabel("ID []"); ylabel(myYlabel); title(myTitle);
    legend("Raw data","sorted data","Location","best");
end

function myMessage=PrintUnidentified(cyCodesINun)
    % based on https://it.mathworks.com/matlabcentral/answers/299479-finding-the-frequency-of-unique-values
    missingIndices=ismissing(cyCodesINun);
    [ii,jj,kk]=unique(cyCodesINun(~missingIndices));
    freq=accumarray(kk,1);
    myMessage=strcat(sprintf("cycle code: %s - occurrences: %.0f;\n",[ii freq]'),...
                sprintf("cycle code: <missing> - occurrences: %.0f;\n",sum(missingIndices)));
end
