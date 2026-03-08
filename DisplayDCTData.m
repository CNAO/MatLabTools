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
clear kPath DCpaths;
clear all;
close all;

% -------------------------------------------------------------------------
% USER's input data
kPath="R:\Accelerating-System\Accelerator-data";
% kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
DCpathMain="\Area dati MD\00monitoraggio\corrente\dcx";
DCpaths=[...
%     % 2024-07 ChNetMaxi
%     strcat(kPath,DCpathMain,"\*\20240702\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20240703\dcx-*_*_*.txt") 
%     % 2025-07 SIG
%     strcat(kPath,DCpathMain,"\*\20250705\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20250706\dcx-*_*_*.txt") 
%     % 2025-07-13.15 UniMi
%     strcat(kPath,DCpathMain,"\*\20250712\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20250713\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20250714\dcx-*_*_*.txt") 
%     % 2025-09-07 FOOT (MSD)
%     strcat(kPath,DCpathMain,"\*\20250907\dcx-*_*_*.txt") 
%     % 2025-10-18 Borghi
%     strcat(kPath,DCpathMain,"\*\20251018\dcx-*_*_*.txt") 
% %     2025-10-25.26 CREMA
%     strcat(kPath,DCpathMain,"\*\20251025\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20251026\dcx-*_*_*.txt") 
%     % 2025-12-13.14 Adapt
%     strcat(kPath,DCpathMain,"\*\20251213\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20251214\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20251215\dcx-*_*_*.txt") 
%     % 2026-02-14.15 TOFpRAD
%     strcat(kPath,DCpathMain,"\*\20260214\dcx-*_*_*.txt") 
%     strcat(kPath,DCpathMain,"\*\20260215\dcx-*_*_*.txt") 
%     % 2026-03-07 sospetto problema ESI
%     strcat(kPath,DCpathMain,"\*\20260307\dcx-*_*_*.txt") 
    % 2026-03-07.08 ATLAS/UniMi (Andreazza)
    strcat(kPath,DCpathMain,"\*\20260307\dcx-*_*_*.txt") 
    strcat(kPath,DCpathMain,"\*\20260308\dcx-*_*_*.txt") 
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

ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");
ShowDCTtime(DCtStamps,dataToShow,DCcyCodes,mms,labelsToShow,"R [mm]");
% ShowDCThistograms(dataToShow,DCcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");

%% do some math
[rangeCodes,partCodes]=DecodeCyCodes(DCcyCodes);
indicesP=FlagPart(partCodes,"p");
indicesC=FlagPart(partCodes,"C");
indicesHe=FlagPart(partCodes,"He");
infmt='dd/MM/uuuu HH:mm:ss';

%% time interval
% % 2024-07 ChNetMaxi
% tMin=datetime('23/10/2024 22:00:00'); tMax=datetime('24/10/2024 03:42:00');
% tMin=datetime('24/10/2024 22:00:00'); tMax=datetime('25/10/2024 03:42:00');
% % 2025-07 UniMi
% tMin=datetime('12/07/2025 22:00:00','InputFormat',infmt); tMax=datetime('13/07/2025 06:00:00','InputFormat',infmt);
% tMin=datetime('13/07/2025 22:00:00','InputFormat',infmt); tMax=datetime('14/07/2025 04:10:00','InputFormat',infmt);
% % 2025-07 SIG
% tMin=datetime('05/07/2025 14:00:00','InputFormat',infmt); tMax=datetime('05/07/2025 22:00:00','InputFormat',infmt);
% tMin=datetime('06/07/2025 14:00:00','InputFormat',infmt); tMax=datetime('06/07/2025 22:00:00','InputFormat',infmt);
% % 2025-09-07 FOOT (MSD)
% tMin=datetime('07/09/2025 11:30:00','InputFormat',infmt); tMax=datetime('07/09/2025 11:35:00','InputFormat',infmt);
% [integralsP,uEksP]=IntegrateMe(DCcurrs(:,1),DCtStamps,tMin,tMax,indicesP,Eks);
% [integralsC,uEksC]=IntegrateMe(DCcurrs(:,1),DCtStamps,tMin,tMax,indicesC,Eks);
% % 2025-10-18 Borghi
% tMin=datetime('18/10/2025 13:05:00','InputFormat',infmt); tMax=datetime('18/10/2025 13:20:00','InputFormat',infmt);
% % 2025-10-25.26 CREMA
% tMin=datetime('25/10/2025 14:00:00','InputFormat',infmt); tMax=datetime('25/10/2025 22:15:00','InputFormat',infmt);
% tMin=datetime('26/10/2025 14:00:00','InputFormat',infmt); tMax=datetime('26/10/2025 22:30:00','InputFormat',infmt);
% 2026-03-07.08 ATLAS/UniMi (Andreazza)
tMin=datetime('07/03/2026 14:00:00','InputFormat',infmt); tMax=datetime('07/03/2026 22:00:00','InputFormat',infmt);
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
