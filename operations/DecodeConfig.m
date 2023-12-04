function [machine,beamPart,focus,config]=DecodeConfig(myConfig)
% DecodeConfig(myConfig)     decodes the configuration in its parts, after
%                              some checking;
% input (all optional):
% - myConfig (string): machine configuration to be found. It is a string
%     made of substrings separated by comas, no empty spaces.
%     The string should look like: "<machine>,<beamPart>,<extractionMode>,<focus>";
%      e.g. "SYNCHRO,PROTON,TM"
%     The user can specify a subset of values; for the others, the default
%      values will be used;
%
% ouput:
% - machine (string): beam line (default: SYNCHRO);
% - beamPart (string): transported particle (default: PROTON);
% - focus (string): dimension of focus (default: FG);
% - config (string): extraction method (default: TM);
%
% See also ReturnDefFile.

    stripMeAll=[" " "-" "_"];
    
    % - default values (focus depends on the particle)
    if (~exist("myConfig","var")), myConfig=missing(); end
    machine="SYNCHRO"; beamPart="PROTON"; config="TM"; focus="";
    % - actual requests by user
    if (~ismissing(myConfig) && strlength(myConfig)>0)
        myInfo=split(myConfig,",");
        if (length(myInfo)>=1)
            if ( strlength(myInfo(1))>0 ), machine=myInfo(1); end
        end
        if (length(myInfo)>=2)
            if ( strlength(myInfo(2))>0 ), beamPart=myInfo(2); end
        end
        if (length(myInfo)>=3)
            if ( strlength(myInfo(3))>0 ), config=myInfo(3); end
        end
        if (length(myInfo)>=4)
            if ( strlength(myInfo(4))>0 ), focus=myInfo(4); end
        end
    end
    % - capitalize info
    machine=upper(machine);
    beamPart=upper(beamPart);
    config=upper(config);
    focus=upper(focus);
    % - take into account nick-names, typos, etc...
    switch erase(machine,stripMeAll) % erase characters
        case {"LINEZ","SALA1"}
            machine="Sala1";
        case {"LINEV","SALA2V"}
            machine="Sala2V";
        case {"LINEU","SALA2H"}
            machine="Sala2H";
        case {"LINET","SALA3"}
            machine="Sala3";
        case {"ISO1","XPRX1","X1"}
            machine="Iso1";
        case {"ISO2","XPRX2","X2"}
            machine="Iso2";
        case {"ISO3","XPRX3","X3"}
            machine="Iso3";
        case {"ISO4","XPRX4","X4"}
            machine="Iso4";
        case {"SINCRO","SYNCHRO"}
            machine="SYNCHRO";
        otherwise
            error("machine %s NOT recognised!",machine);
    end
    switch erase(beamPart,stripMeAll) % erase characters
        case {"PROTON","PROTONI","PROT","P"}
            beamPart="P";
            if (~exist("focus","var") || strlength(focus)==0), focus="FG"; end
        case {"CARBON","CARBONIO","CARB","C"}
            beamPart="C";
            if (~exist("focus","var") || strlength(focus)==0), focus="FP"; end
        otherwise
            error("particle %s NOT recognised!",beamPart);
    end
    switch erase(config,stripMeAll) % erase characters
        case {"BETATRONE","BETATRON","BETA","BET"}
            config="Betatrone";
        case {"RFKO","RFKNOCKOUT"}
            config="RFKO";
        case "TM"
            config="Betatrone"; % TM=Betatrone
        otherwise
            error("configuration %s NOT recognised!",config);
    end
    switch erase(focus,stripMeAll) % erase characters
        case {"FG","GRANDE"}
            focus="FG";
        case {"FP","PICCOLO"}
            focus="FP";
        otherwise
            if (strlength(focus)>0)
                error("focus %s NOT recognised!",focus);
            end
    end
    if (strcmp(machine,"SYNCHRO")), focus=""; end
    
end
