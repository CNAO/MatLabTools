% {}~

%% description
% this is a basic script which parses DCT/DCX files and plots them:
% - the script crunches as many DCT files as desired, provided the
%   fullpaths;
% - the script shows a spill-per-spill time evolution of the DCT current,
%   together with beam energy/water range, and some statistics data vs 
%   beam energy/water range;
% - the user can customize what to plot. By default, Acc_Part, Inj_Part and
%   Acc_Part/Inj_Part vs beam energy;
% - time plots show data for carbon and protons with different colors;
% - statistics plots show data for carbon separated from that of protons;

%% include libraries
% - include Matlab libraries
if (~exist("pathToLibrary","var"))
    pathToLibrary="..\externalMatLabTools";
    addpath(genpath(pathToLibrary));
    pathToLibrary=".\";
    addpath(genpath(pathToLibrary));
end

%% settings
clear kPath DCpaths

% -------------------------------------------------------------------------
% USER's input data
kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
DCpathMain="\Area dati MD\00monitoraggio\corrente\dcx";
DCpaths=[...
    strcat(kPath,DCpathMain,"\*\20240702\dcx-*_*_*.txt") 
    strcat(kPath,DCpathMain,"\*\20240703\dcx-*_*_*.txt") 
    ];
% -------------------------------------------------------------------------

%% parse files
clear DCcyProgs DCcyCodes DCcurrs DCtStamps Eks mms

% - parse DC log files
[DCcyProgs,DCcyCodes,DCcurrs,DCtStamps]=ParseDCTFiles(DCpaths);
if (length(DCcurrs)<=1), error("...no data aquired, nothing to plot!"); end

% - get Eks corresponding to list of cyCodes
Eks=ConvertCyCodes(DCcyCodes,"Ek","MeVvsCyCo_P.xlsx");
mms=ConvertCyCodes(DCcyCodes,"mm","MeVvsCyCo_P.xlsx");

%% show data

% -------------------------------------------------------------------------
% USER's input data
% - data to show and labels
dataToShow=[DCcurrs*1E9 DCcurrs(:,1)./DCcurrs(:,2)];
labelsToShow=["DC-Acc\_Part []" "DC-Inj\_Part []" "T_{Acc/Inj} []"];
% -------------------------------------------------------------------------

% ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");
ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,mms,labelsToShow,"R [mm]");
% ShowDCThistograms(dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");
