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
kPath="R:\Accelerating-System\Accelerator-data";
% kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
DCpathMain="\Area dati MD\00monitoraggio\corrente\dcx";
DCpaths=[...
    % 2025-07 SIG
%     strcat(kPath,DCpathMain,"\*\20250705\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20250706\dcx-*_*_*.txt") 
    % 2025-09-07 FOOT (MSD)
%     strcat(kPath,DCpathMain,"\*\20250907\dcx-*_*_*.txt") 
    % 2025-12-13.14 Adapt
    strcat(kPath,DCpathMain,"\*\20251213\dcx-*_*_*.txt") 
    strcat(kPath,DCpathMain,"\*\20251214\dcx-*_*_*.txt") 
    strcat(kPath,DCpathMain,"\*\20251215\dcx-*_*_*.txt") 
    ];
% lDCX=true;
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

ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");
ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,mms,labelsToShow,"R [mm]");
% ShowDCThistograms(dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");

%% do some math
[rangeCodes,partCodes]=DecodeCyCodes(DCcyCodes);
indicesP=FlagPart(partCodes,"p");
indicesC=FlagPart(partCodes,"C");
infmt='dd/MM/uuuu HH:mm:ss';

%% time interval
% 2025-07 SIG
% tMin=datetime('05/07/2025 14:00:00','InputFormat',infmt); tMax=datetime('05/07/2025 22:00:00','InputFormat',infmt);
% tMin=datetime('06/07/2025 14:00:00','InputFormat',infmt); tMax=datetime('06/07/2025 22:00:00','InputFormat',infmt);
% 2025-09-07 FOOT (MSD)
tMin=datetime('07/09/2025 11:30:00','InputFormat',infmt); tMax=datetime('07/09/2025 11:35:00','InputFormat',infmt);
[integralsP,uEksP]=IntegrateMe(DCcurrs(:,1),DCtStamps,tMin,tMax,indicesP,Eks);
[integralsC,uEksC]=IntegrateMe(DCcurrs(:,1),DCtStamps,tMin,tMax,indicesC,Eks);

function [integrals,uEks]=IntegrateMe(What,DCtStamps,tMin,tMax,indices,Eks)
    uEks=unique(Eks(isbetween(DCtStamps,tMin,tMax) & indices));
    integrals=NaN(size(uEks));
    if (~isempty(uEks))
        integrals=NaN(size(uEks));
        for ii=1:length(uEks)
            integrals(ii)=sum(What((isbetween(DCtStamps,tMin,tMax) & indices & (Eks==uEks(ii)))));
            fprintf("...found %g over %d spills;\n",integrals(ii),sum((isbetween(DCtStamps,tMin,tMax) & indices & (Eks==uEks(ii)))));
        end
    end
end
