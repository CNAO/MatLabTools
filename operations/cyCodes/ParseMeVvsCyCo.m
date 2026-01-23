function [Eks,cyCodes,mms]=ParseMeVvsCyCo(varIN,kPath,sheetName)
% ParseMeVvsCyCo             parse files like MeVvsCyCo (.xlsx), getting the
%                              mapping between cycle code, extracted beam
%                              energy and Bragg-peak depth
% input:
% - varIN (string or integer):
%   . if string: full path (including name) to file to be parsed;
%   . if integer: the default files are parsed:
%     =1: file for proton;
%     =6: file for carbon;
% - kPath (string, optional): path to K: drive; default: 
%     S:\Accelerating-System\Accelerator-data
%     This parameter is necessary only for default files;
% - sheetName (string, optional): name of sheet in .xlsx file to be parsed.
%
% output:
% - Eks (array of floats): beam energies [MeV/u];
% - cyCodes (array of strings): cycle codes present in the parsed file;
% - mms (array of floats): corresponding position of Bragg peak [mm];
%
% See also: ConvertCyCodes, GetOPDataFromTables and MapCyCode.

    % check input
    if ( ~exist('kPath','var') )
        kPath="P:\Accelerating-System\Accelerator-data";
    end
    if ( ~exist('sheetName','var') )
        sheetName="Sheet1";
    end
    if ( isstring( varIN ) )
        lUp=false;
        % varIN is the (full) path to the file
        fileToParse=varIN;
    else
        lUp=true;
        % varIN specifies if to parse the proton or carbon file
        switch varIN
            case 1
                fileToParse=strcat(kPath,"\Area dati MD\00Setting\MeVvsCyCo_P.xlsx");
            case 6
                fileToParse=strcat(kPath,"\Area dati MD\00Setting\MeVvsCyCo_C.xlsx");
            otherwise
                error("...wrong specification of particle! accepted values: 1=proton, 6=carbon");
        end
    end
    
    % actually do the job
    MeVvsCyCo = GetOPDataFromTables(fileToParse,sheetName);
    if (lUp)
        Eks = cell2mat(MeVvsCyCo(2:end,3));
        mms = cell2mat(MeVvsCyCo(2:end,1));
    else
        Eks = cell2mat(MeVvsCyCo(2:end,1));
        mms = cell2mat(MeVvsCyCo(2:end,3));
    end
    cyCodes = string(MeVvsCyCo(2:end,2)); cyCodes=UpperCyCodes(cyCodes);
    
end
