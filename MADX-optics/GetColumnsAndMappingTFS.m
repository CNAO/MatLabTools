function [ colNames, colUnits, colFacts, mapping, readFormat ] = ...
    GetColumnsAndMappingTFS(whichTFS,genBy,fileName)
% GetColumnsAndMappingTFS     return column names, units and column
%                                    mapping of (predefined) twiss tables
%
% [ colNames, colUnits, colFacts, mapping, readFormat ] =
%                                  GetColumnsAndMappingTFS(whichTFS)
%
% input arguments:
%   whichTFS: format of the table:
%       'OPTICS': optics table by MAD-X;
%       'GEOMETRY': lattice geometry by MAD-X;
%       'RMATRIX': (selected elements of) response matrix by MAD-X;
%       'CURR': a TFS table listing scan currents;
%       'LOSSES': an ASCII table listing particle losses;
%       'TRACKS': an ASCII table listing particle coordinates;
%   genBy: format of the table:
%       'TWISS': a TFS table as generated by a MADX TWISS command;
%       'SCAN': a TFS table as generated by a current scan;
%   fileName (optional): name of file;
%       the file is parsed for auto-detection of format.
%       FOR THE TIME BEING, ONLY "CURR" TYPE IS SUPPORTED!
%
% output arguments:
%   colNames: array with name of columns/variables;
%   colUnits: array with units of columns/variables;
%   colFacts: array of multiplotcation factors to columns/variables;
%   mapping: on which column a given variable is found;
%   readFormat: format string necessary to correctly parse the file;
%
% This function states that the optics, geometry and Rmatrix TFS tables
%   have specific pre-defined formats:
% - generated by a MADX TWISS command (genBy=="TWISS")
%   . optics:
%   NAME, KEYWORD, L, S, BETX, ALFX,  BETY, ALFY, X, PX, Y, PY,
%         DX, DPX, DY, DPY, MUX, MUY;
%   . geometry:
%   NAME, KEYWORD, L, S, KICK, HKICK, VKICK, ANGLE, K0L, K1L, K2L,
%         APERTYPE, APER_1, APER_2, APER_3, APER_4, APOFF_1, APOFF_2;
%   . response matrix:
%   NAME, KEYWORD, L, S, RE11, RE12, RE21, RE22, RE16, RE26, RE33, RE34,
%         RE43, RE44, RE36, RE46, RE51, RE52, RE55, RE56, RE66;
%   . losses:
%   NUMBER, TURN, X, PX, Y, PY, T, PT, S, E, ELEMENT
% - generated by a scan (genBy=="SCAN")
%   . optics:
%   Brho[Tm], BP[mm], myID[], BETX, ALFX,  BETY, ALFY, X, PX, Y, PY,
%         DX, DPX, DY, DPY, MUX, MUY;
%   . geometry:
%   Brho[Tm], BP[mm], myID[], KICK, HKICK, VKICK, ANGLE, K0L, K1L, K2L,
%         APERTYPE, APER_1, APER_2, APER_3, APER_4, APOFF_1, APOFF_2;
%   . response matrix:
%   Brho[Tm], BP[mm], myID[], RE11, RE12, RE21, RE22, RE16, RE26, RE33, RE34,
%         RE43, RE44, RE36, RE46, RE51, RE52, RE55, RE56, RE66;
%
% NB: current .tfs tables are custom-made, hence no pre-defined format.
%
% See also ParseTfsTable.
    % default genBy
    if (~exist("genBy","var") | ismissing(genBy))
        if (strcmpi(whichTFS,"CURR"))
            genBy="SCAN";
        else
            genBy="TWISS";
        end
    end

    % from label to data column
    if (exist("fileName","var"))
        fprintf("auto-detecting header of file %s ...\n",fileName);
        if (~strcmpi(whichTFS,"CURR"))
            error("auto-detection of file header only available for the CURR type!");
        end
        fileID = fopen(fileName,'r');
        colNames=missing();
        while ~feof(fileID)
            tline=strip(fgetl(fileID)); % drop new-line char
            if (startsWith(tline,"*"))
                colNames=split(tline);
                colNames=colNames(strlength(colNames)>0); % forget about empty strings due to consecutive blanks
                colNames=colNames(2:end); % forget about heading "*"
                colNames=strrep(colNames,"_A",""); % drop closing _A
                break
            end
        end
        fclose(fileID);
        if (ismissing(colNames))
            error("No line headed by '*' char was found. Are you sure about the file format?");
        end
        colUnits=strings(length(colNames),1);
        colUnits(:)="A";
        readFormat=strings(1,length(colNames));
        readFormat(:)="%f";
        readFormat=join(readFormat);
    else
        % pre-defined formats
        if (strcmpi(whichTFS,"CURR"))
            error("NO pre-defined format for CURR .tfs files!");
        end
        switch upper(genBy)
            case {"TWISS","PTC_TWISS"}
                switch upper(whichTFS)
                    case {'OPT','OPTICS'}
                        colNames=[ "NAME" "KEYWORD" "L" "S"  "BETX" "ALFX" "BETY" "ALFY" ...
                                   "X"    "PX"      "Y" "PY" "DX"   "DPX"  "DY"   "DPY"  ...
                                   "MUX"  "MUY" ];
                        colUnits=[ ""     ""        "m" "m"  "m"    ""     "m"    ""     ...
                                   "m"    ""        "m" ""   "m"    ""     "m"    ""     ...
                                   "2\pi" "2\pi"];
                        readFormat = '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
                    case {'GEO','GEOMETRY','GEOM'}
                        colNames=[ "NAME"     "KEYWORD" "L"      "S"                                         ...
                                   "KICK"     "HKICK"   "VKICK"  "ANGLE"  "K0L"    "K1L"        "K2L"        ...
                                   "APERTYPE" "APER_1"  "APER_2" "APER_3" "APER_4" "APOFF_1"    "APOFF_2"    ];
                        colUnits=[ ""         ""        "m"      "m"                                         ...
                                   "rad"      "rad"     "rad"    "rad"    "rad"    "rad m^{-1}" "rad m^{-2}" ...
                                   ""         "m"       "m"      "m"      "m"      "m"          "m"          ];
                        readFormat = '%s %s %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f';
                    case {'RM','RMATRIX','RE'}
                        colNames=[ "NAME"     "KEYWORD"    "L"           "S"                                 ...
                                   "RE11"     "RE12"       "RE21"        "RE22"   "RE16"    "RE26"           ...
                                   "RE33"     "RE34"       "RE43"        "RE44"   "RE36"    "RE46"           ...
                                   "RE51"     "RE52"       "RE55"        "RE56"   "RE66"    ];
                        colUnits=[ ""         ""           "m"           "m"                                 ...
                                   ""         "m rad^{-1}" "rad m^{-1}"  ""       "m"       "rad"            ...
                                   ""         "m rad^{-1}" "rad m^{-1}"  ""       "m"       "rad"            ...
                                   "s m^{-1}" "s rad^{-1}" ""            "s"      "m"       ];
                        readFormat = '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
                    case {'LOSS','LOSSES','LOST'}
                        colNames=[ "NUMBER"   "TURN"                                                         ...
                                   "X"        "PX"         "Y"           "PY"     "T"       "PT"             ...
                                   "S"        "E"          "ELEMENT" ];
                        colUnits=[ ""         ""                                                             ...
                                   "m"        ""           "m"           ""       "m"       ""               ...
                                   "m"        "GeV"        ""        ];
                        readFormat = '%f %f %f %f %f %f %f %f %f %f %s';
                    case {'TRACK','TRACKS','TRACKING','SURV','SURVS','SURVIVOR','SURVIVORS'}
                        colNames=[ "NUMBER"   "TURN"                                                         ...
                                   "X"        "PX"         "Y"           "PY"     "T"       "PT"             ...
                                   "S"        "E"          ];
                        colUnits=[ ""         ""                                                             ...
                                   "m"        ""           "m"           ""       "m"       ""               ...
                                   "m"        "GeV"        ];
                        readFormat = '%f %f %f %f %f %f %f %f %f %f';
                    otherwise
                        error('which column mapping for TFS table?');
                end
            case "SCAN"
                mySep=',';
                switch upper(whichTFS)
                    case {'OPT','OPTICS'}
                        colNames=[ "BRHO" "BP"   "ID"           ...
                                   "BETX" "ALFX" "BETY" "ALFY"  ...
                                   "X"    "PX"   "Y"    "PY"    ...
                                   "DX"   "DPX"  "DY"   "DPY"   ...
                                   "MUX"  "MUY" ];
                        colUnits=[ "Tm"   "mm"   ""             ...
                                   "m"    ""     "m"    ""      ...
                                   "m"    ""     "m"    ""      ...
                                   "m"    ""     "m"    ""      ...
                                   "2\pi" "2\pi"];
                        readFormat = strcat('%f',mySep,'%f',mySep,'%f',mySep,            ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f'                              );
                    case {'GEO','GEOMETRY'}
                        colNames=[ "BRHO"     "BP"      "ID"                                                 ...
                                   "KICK"     "HKICK"   "VKICK"  "ANGLE"  "K0L"    "K1L"        "K2L"        ...
                                   "APERTYPE" "APER_1"  "APER_2" "APER_3" "APER_4" "APOFF_1"    "APOFF_2"    ];
                        colUnits=[ "Tm"       "mm"      ""                                                   ...
                                   "rad"      "rad"     "rad"    "rad"    "rad"    "rad m^{-1}" "rad m^{-2}" ...
                                   ""         "m"       "m"      "m"      "m"      "m"          "m"          ];
                        readFormat = strcat('%f',mySep,'%f',mySep,'%f',mySep,                                             ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f'        );
                    case {'RM','RMATRIX'}
                        colNames=[ "BRHO"     "BP"      "ID"                                                 ...
                                   "RE11"     "RE12"       "RE21"        "RE22"   "RE16"    "RE26"           ...
                                   "RE33"     "RE34"       "RE43"        "RE44"   "RE36"    "RE46"           ...
                                   "RE51"     "RE52"       "RE55"        "RE56"   "RE66"    ];
                        colUnits=[ "Tm"       "mm"      ""                                                   ...
                                   ""         "m rad^{-1}" "rad m^{-1}"  ""       "m"       "rad"            ...
                                   ""         "m rad^{-1}" "rad m^{-1}"  ""       "m"       "rad"            ...
                                   "s m^{-1}" "s rad^{-1}" ""            "s"      "m"       ];
                        readFormat = strcat('%f',mySep,'%f',mySep,'%f',mySep,                                  ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep, ...
                                            '%f',mySep,'%f',mySep,'%f',mySep,'%f',mySep,'%f'                   );
                    case {'LOSS','LOSSES','TRACK','TRACKS','TRACKING'}
                        error('... %s .tfs type generated by %s NOT available yet!',whichTFS,genBy);
                    otherwise
                        error('which column mapping for TFS table?');
                end
            otherwise
                error("How was the .tfs table generated (TWISS/SCAN)? %s NOT recognised!",genBy);
        end
    end
    colFacts = ones(1,length(colNames));
    mapping = 1:length(colNames);

end
