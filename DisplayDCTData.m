% {}~

%% description
% this is a basic script which parses DCT files and plots them:
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
clear kPath DCTpaths

% -------------------------------------------------------------------------
% USER's input data
kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
DCTpathMain="\Area dati MD\00monitoraggio\corrente\dcx";
DCTpaths=[...
    strcat(kPath,DCTpathMain,"\*\20241023\dcx-*_*_*.txt") 
    strcat(kPath,DCTpathMain,"\*\20241024\dcx-*_*_*.txt") 
    strcat(kPath,DCTpathMain,"\*\20241025\dcx-*_*_*.txt") 
    ];
lDCX=true;
% -------------------------------------------------------------------------

%% parse files
clear DCTcyProgs DCTcyCodes DCTcurrs DCTtStamps Eks mms

% - parse DCT log files
[DCTcyProgs,DCTcyCodes,DCTcurrs,DCTtStamps]=ParseDCTFiles(DCTpaths,lDCX);
if (length(DCTcurrs)<=1), error("...no data aquired, nothing to plot!"); end

% - get Eks corresponding to list of cyCodes
Eks=ConvertCyCodes(DCTcyCodes,"Ek","MeVvsCyCo_P.xlsx");
mms=ConvertCyCodes(DCTcyCodes,"mm","MeVvsCyCo_P.xlsx");

%% show data

% -------------------------------------------------------------------------
% USER's input data
% - data to show and labels
dataToShow=[DCTcurrs*1E9 DCTcurrs(:,1)./DCTcurrs(:,2)];
labelsToShow=["DCT-Acc\_Part []" "DCT-Inj\_Part []" "T_{Acc/Inj} []"];
% -------------------------------------------------------------------------

ShowDCTtime(DCTtStamps,dataToShow,DCTcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");
% ShowDCThistograms(dataToShow,DCTcyCodes,Eks,labelsToShow,"HEBT E_k [MeV/u]");

%% do some math
[rangeCodes,partCodes]=DecodeCyCodes(DCTcyCodes);
indicesP=FlagPart(partCodes,"p");
indicesC=FlagPart(partCodes,"C");

% time interval
% tMin=datetime('23/10/2024 22:00:00'); tMax=datetime('24/10/2024 03:42:00');
tMin=datetime('24/10/2024 22:00:00'); tMax=datetime('25/10/2024 03:42:00');
[integralsP,uEksP]=IntegrateMe(DCTcurrs(:,1),DCTtStamps,tMin,tMax,indicesP,mms);
[integralsC,uEksC]=IntegrateMe(DCTcurrs(:,1),DCTtStamps,tMin,tMax,indicesC,mms);

function [integrals,uEks]=IntegrateMe(What,DCTtStamps,tMin,tMax,indices,Eks)
    uEks=unique(Eks(isbetween(DCTtStamps,tMin,tMax) & indices));
    integrals=NaN(size(uEks));
    if (~isempty(uEks))
        integrals=NaN(size(uEks));
        for ii=1:length(uEks)
            integrals(ii)=sum(What((isbetween(DCTtStamps,tMin,tMax) & indices & (Eks==uEks(ii)))));
        end
    end
end