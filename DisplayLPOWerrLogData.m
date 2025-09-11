% {}~

%% description
% this is a basic script which parses LPOW error log files and plots them:
% - the script crunches as many LPOW error log files as desired, provided the
%   fullpaths;
% - the script shows a spill-per-spill time evolution of the PS currents
%   found in the LPOW error log, together with beam energy/water range;
% - time plots show data for carbon and protons with different colors;

%% include libraries
% - include Matlab libraries
if (~exist("pathToLibrary","var"))
    pathToLibrary="..\externalMatLabTools";
    addpath(genpath(pathToLibrary));
    pathToLibrary=".\";
    addpath(genpath(pathToLibrary));
end

%% settings

% -------------------------------------------------------------------------
% USER's input data
kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
LPOWerrLogPathMain="\Area dati MD\LPOWmonitor\ErrorLog";
LPOWerrLogPaths=[...
    strcat(kPath,LPOWerrLogPathMain,"\2024-10-30\2*.txt") 
    strcat(kPath,LPOWerrLogPathMain,"\2024-10-31\*.txt") 
    ];
% -------------------------------------------------------------------------

%% parse files
clear tStampsLPOWMon LGENsLPOWMon LPOWsLPOWMon racksLPOWMon repoValsLPOWMon appValsLPOWMon cyCodesLPOWMon cyProgsLPOWMon endCycsLPOWMon Eks mms

% - parse LPOW error log files
[tStampsLPOWMon,LGENsLPOWMon,LPOWsLPOWMon,racksLPOWMon,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,cyProgsLPOWMon,endCycsLPOWMon]=ParseLPOWLog(LPOWerrLogPaths);
if (length(appValsLPOWMon)<=1), error("...no data aquired, nothing to plot!"); end

% - get Eks corresponding to list of cyCodes
Eks=ConvertCyCodes(cyCodesLPOWMon,"Ek","MeVvsCyCo_P.xlsx");
mms=ConvertCyCodes(cyCodesLPOWMon,"mm","MeVvsCyCo_P.xlsx");

%% show data
% -------------------------------------------------------------------------
% USER's input data
% - which LGEN to show
uniqueLGENs=unique(LGENsLPOWMon);
requestedLGENs=uniqueLGENs;
% -------------------------------------------------------------------------

ShowLPOWerrLogTime(tStampsLPOWMon,LGENsLPOWMon,requestedLGENs,repoValsLPOWMon,appValsLPOWMon,cyCodesLPOWMon,Eks,"HEBT E_k [MeV/u]",10);
