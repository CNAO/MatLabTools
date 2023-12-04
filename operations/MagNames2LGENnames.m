function outNames=MagNames2LGENnames(inNames,lInv,PSmapping,separator)
    if (~exist("lInv","var")), lInv=false; end % by default, convert Magnet Name into LGEN
    if (~exist("separator","var")), separator=","; end
    
    outNames=strings(length(inNames),1);
    if (lInv)
        % LGEN name --> Magnet name
        arrayIN=PSmapping.LGEN;
        arrayOUT=PSmapping.Magnet_NAME;
        whatTO="Magnet Name";
    else
        % Magnet name --> LGEN name
        arrayIN=PSmapping.Magnet_NAME;
        arrayOUT=PSmapping.LGEN;
        whatTO="LGEN Name";
    end
    
    % query mapping
    for ii=1:length(inNames)
        if (any(contains(string(arrayIN),separator)))
            jj=find(contains(string(arrayIN),inNames(ii)));
        else
            jj=find(strcmpi(string(arrayIN),inNames(ii)));
        end
        if ( isempty(jj) ), error("%s %s not found in LGEN mapping table!",whatTO,inNames(ii)); end
        if (any(contains(string(arrayOUT),separator)))
            myStrings=split(arrayOUT(jj),separator);
            outNames(ii)=myStrings(1);
        else
            outNames(ii)=string(arrayOUT(jj));
        end
    end
end

