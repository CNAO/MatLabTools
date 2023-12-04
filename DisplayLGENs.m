% {}~

%% description
% this is a script which displays LGEN currents;

%% include libraries
% - include Matlab libraries
pathToLibrary="./";
addpath(genpath(pathToLibrary));
pathToLibrary="../MachineRefs";
addpath(genpath(pathToLibrary));

%% settings

% -------------------------------------------------------------------------
% USER's input data
machine=["Sala2H" "Sala2H"];%["ISO1" "ISO2" "ISO3" "ISO4" ]; % "ISO1" "ISO2" "ISO3" "ISO4"];
machine="ISO3";%["ISO1" "ISO2" "ISO3" "ISO4" ]; % "ISO1" "ISO2" "ISO3" "ISO4"];
% beamPart=["PROTON" "PROTON" "PROTON" "PROTON" ]; %"CARBON" "CARBON" "CARBON" "CARBON" ];
beamPart=["PROTON" "CARBON" ];
% machine="ISO2";
% beamPart=["PROTON" "CARBON" ];
config="TM"; % select configuration: TM, RFKO
myTitle="LGEN values";
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% check of user input data
nSets=max([length(beamPart) length(machine) length(config)]);
beamPart=ConfigCheck(beamPart,nSets,"beamPart");
machine=ConfigCheck(machine,nSets,"machine");
config=ConfigCheck(config,nSets,"config");

%% clear variables
[cyCodes,ranges,Eks,Brhos,currents,fields,kicks,psNames,FileNameCurrents,magNames]=...
    deal(missing(),missing(),missing(),missing(),missing(),missing(),missing(),missing(),missing(),missing());
clear PSmapping;
myLeg=strings(nSets,1);

%% parse DBs

% - get PS mapping
FullFileName=ReturnDefFile("PSmapping"); PSmapping=readtable(FullFileName);

% - get values
for iSet=1:nSets
    clear tmpCyCodes tmpRanges tmpEks tmpBrhos tmpCurrents tmpFields tmpKicks tmpPsNames tmpFileNameCurrents tmpMagNames ;
    myConfig=sprintf("%s,%s,%s",machine(iSet),beamPart(iSet),config(iSet));
    [tmpCyCodes,tmpRanges,tmpEks,tmpBrhos,tmpCurrents,tmpFields,tmpKicks,tmpPsNames,tmpFileNameCurrents]=AcquireLGENValues(myConfig);
    tmpPsNames=string(tmpPsNames);
    tmpCyCodes=upper(string(tmpCyCodes));
    tmpMagNames=MagNames2LGENnames(tmpPsNames,true,PSmapping);
    myLeg(iSet)=myConfig; % comment me, if single data set
    % - store data
    cyCodes=ExpandMat(cyCodes,tmpCyCodes);
    ranges=ExpandMat(ranges,tmpRanges);
    Eks=ExpandMat(Eks,tmpEks);
    Brhos=ExpandMat(Brhos,tmpBrhos);
    currents=ExpandMat(currents,tmpCurrents);
    fields=ExpandMat(fields,tmpFields);
    kicks=ExpandMat(kicks,tmpKicks);
    psNames=ExpandMat(psNames,tmpPsNames);
    FileNameCurrents=ExpandMat(FileNameCurrents,tmpFileNameCurrents);
    magNames=ExpandMat(magNames,tmpMagNames);
end

% - normalise currents to Brho
clear normCurrents; normCurrents=NaN(size(currents));
for iSet=1:nSets
    normCurrents(:,:,iSet)=currents(:,:,iSet)./Brhos(:,iSet);
end

%% visual checks
LGENvisualCheck(psNames,Eks   ,"Ek [MeV/u]",currents,"I [A]",magNames,myTitle,myLeg);
LGENvisualCheck(psNames,Eks   ,"Ek [MeV/u]",normCurrents,"I/B\rho [A/Tm]",magNames,myTitle,myLeg);
LGENvisualCheck(psNames,ranges,"range [mm]",currents,"I [A]",magNames,myTitle,myLeg,"QUE");
LGENvisualCheck(psNames,ranges,"range [mm]",normCurrents,"I/B\rho [A/Tm]",magNames,myTitle,myLeg);
LGENvisualCheck(psNames,Brhos ,"B\rho [Tm]",currents,"I [A]",magNames,myTitle,myLeg);
LGENvisualCheck(psNames,Brhos ,"B\rho [Tm]",normCurrents,"I/B\rho [A/Tm]",magNames,myTitle,myLeg);

%% local functions
