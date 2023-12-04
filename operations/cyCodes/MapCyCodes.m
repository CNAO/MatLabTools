function [vOut,Refs]=MapCyCodes(cyCodesIN,what,machine)
    if (~exist("what","var")), what=missing(); end
    if (~exist("machine","var")), machine=missing(); end
    
    if (ismissing(what)), what="Ek"; end
    if (ismissing(machine)), machine="SYNCHRO"; end
    
    % - values ref values
    [PcyCodes,whatValsP]=ExtractFromTable(readtable(ReturnDefFile("BRHO",sprintf("%s,PROTON",machine))),"CyCode",what);
    [CcyCodes,whatValsC]=ExtractFromTable(readtable(ReturnDefFile("BRHO",sprintf("%s,CARBON",machine))),"CyCode",what);

    % - get mapping
    [rangeCodes,partCodes]=DecodeCyCodes(cyCodesIN);
    [lCCP,iCCP]=MapCyCode(rangeCodes,upper(PcyCodes));
    [lCCC,iCCC]=MapCyCode(rangeCodes,upper(CcyCodes));
    
    % - assign values
    vOut=NaN(length(cyCodesIN),1);
    indicesP=(lCCP & FlagPart(partCodes,"p") );
    indicesC=(lCCC & FlagPart(partCodes,"C") );
    Refs=NaN(max(length(PcyCodes),length(CcyCodes)),2);
    vOut(indicesP)=whatValsP(iCCP(indicesP));
    vOut(indicesC)=whatValsC(iCCC(indicesC));
    Refs(1:length(PcyCodes),1)=whatValsP;
    Refs(1:length(CcyCodes),2)=whatValsC;
end
