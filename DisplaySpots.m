% {}~

%% description
% this is a script which displays beam spots;

%% include libraries
% - include Matlab libraries
if (~exist("pathToLibrary","var"))
    pathToLibrary="./";
    addpath(genpath(pathToLibrary));
    pathToLibrary="../MachineRefs";
    addpath(genpath(pathToLibrary));
end

%% clear
clear all;
close all;

%% settings

% -------------------------------------------------------------------------
% USER's input data
machine=["Sala1" "Sala2H" "Sala2V" "Sala3"];
beamPart="PROTON";
config="TM"; % select configuration: TM, RFKO
myXwhat="Range"; % show stuff as a function of
showXlabel="R_{H_2O} [mm]";
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% check of user input data
nSets=max([length(beamPart) length(machine) length(config)]);
beamPart=ConfigCheck(beamPart,nSets,"beamPart");
machine=ConfigCheck(machine,nSets,"machine");
config=ConfigCheck(config,nSets,"config");

%% clear variables
[SP_Eks SP_Mms SP_FWHMs]=deal(missing(),missing(),missing());
[MP_Eks MP_Mms MP_FWHMs MP_myPos]=deal(missing(),missing(),missing(),missing());
[SPHINX_Mms SPHINX_FWHMs]=deal(missing(),missing());

%% get values

% - acquire Steering Pazienti stuff
for iSet=1:nSets
    % - parse DB file
    [tmpEks,tmpMms,tmpFWHMs]=Spots_LoadRef(machine(iSet),beamPart(iSet),config(iSet),"SteerPaz");
    % - store data
    SP_Eks=ExpandMat(SP_Eks,repmat(tmpEks,[1 size(tmpFWHMs,2)]));
    SP_Mms=ExpandMat(SP_Mms,repmat(tmpMms,[1 size(tmpFWHMs,2)]));
    SP_FWHMs=ExpandMat(SP_FWHMs,tmpFWHMs);
end

% - acquire Medical Physics stuff
for iSet=1:nSets
    % - parse DB file
    [tmpEks,tmpMms,tmpFWHMs,tmpMyPos]=Spots_LoadRef(machine(iSet),beamPart(iSet),config(iSet),"MedPhys","ALL");
    % - store data
    MP_Eks=ExpandMat(MP_Eks,repmat(tmpEks,[1 size(tmpFWHMs,2)]));
    MP_Mms=ExpandMat(MP_Mms,repmat(tmpMms,[1 size(tmpFWHMs,2)]));
    MP_FWHMs=ExpandMat(MP_FWHMs,tmpFWHMs);
    MP_myPos=ExpandMat(MP_myPos,tmpMyPos');
end

% - acquire data from SPHINX
for iSet=1:nSets
    % - parse DB file from SPHINX
    [~,tmpSPHINX_Mms,tmpSPHINX_FWHMs]=Spots_LoadRef(machine(iSet),beamPart(iSet),config(iSet),"sphinx");
    % - store data
    SPHINX_Mms=ExpandMat(SPHINX_Mms,repmat(tmpSPHINX_Mms,[1 size(tmpSPHINX_FWHMs,2)]));
    SPHINX_FWHMs=ExpandMat(SPHINX_FWHMs,tmpSPHINX_FWHMs);
end

if (size(MP_FWHMs,3)~=size(SP_FWHMs,3))
    error("something wrong at parsing: %d MedPhys curves, and %d SteerPaz curves",size(MP_FWHMs,3),size(SP_FWHMs,3));
end
if (size(SPHINX_FWHMs,3)~=size(SP_FWHMs,3))
    error("something wrong at parsing: %d Sphinx curves, and %d SteerPaz curves",size(SPHINX_FWHMs,3),size(SP_FWHMs,3));
end

%% show data
nDataSets=length(machine);
% . labels for longitudinal position
PosLabs=strings(size(MP_myPos,1),1);
iIndices=(MP_myPos(:,1)-0.713<0); PosLabs(iIndices)=MP_myPos(iIndices,1)-0.713; PosLabs(iIndices)="ISO " +PosLabs(iIndices)+"m";
iIndices=(MP_myPos(:,1)-0.713>0); PosLabs(iIndices)=MP_myPos(iIndices,1)-0.713; PosLabs(iIndices)="ISO +"+PosLabs(iIndices)+"m";
iIndices=(MP_myPos(:,1)-0.713==0); PosLabs(iIndices)="ISO";
% . labels for lines
LineLabs=strings(nDataSets,1); 
LineLabs=machine(:)+" - "+beamPart(:);

% - Steering Pazienti vs Medical Physics
myTitles=strings(nDataSets,1); myTitles(:)=LineLabs; myTitles(end+1)="SteerPaz vs MedPhys";
iISO=(MP_myPos(:,1)==713E-3);
xRef=MP_Mms(:,iISO,:); yRef=MP_FWHMs(:,iISO,:); yRef=Spots_FWHMRefSeries(yRef);
ShowSeries(SP_Mms,SP_FWHMs,"R_{H_2O} [mm]","FWHM [mm]",["FWHM_x" "FWHM_y"],myTitles,yRef,xRef,["MP" "MP+" "MP-"]);

% - SPHINX vs Medical Physics
myTitles=strings(nDataSets,1); myTitles(:)=LineLabs; myTitles(end+1)="SPHINX vs MedPhys";
iISO=(MP_myPos(:,1)==713E-3);
xRef=MP_Mms(:,iISO,:); yRef=MP_FWHMs(:,iISO,:); yRef=Spots_FWHMRefSeries(yRef);
ShowSeries(SPHINX_Mms,SPHINX_FWHMs,"R_{H_2O} [mm]","FWHM [mm]",["SPHINX_x","SPHINX_y","SPHINX_{mean}"],myTitles,yRef,xRef,["MP" "MP+" "MP-"]);

%% - Medical Physics: various positions (grouped by line)
myTitles=strings(nDataSets,1); myTitles(:)=LineLabs; myTitles(end)="MedPhys - various longitudinal positions";
myLeg=PosLabs;
ShowSeries(MP_Mms,MP_FWHMs,"R_{H_2O} [mm]","FWHM [mm]",myLeg,myTitles);

% - Medical Physics: various positions (grouped by position)
myTitles=strings(size(MP_myPos,1),1); myTitles(:)=PosLabs; myTitles(end+1)="MedPhys - various longitudinal positions";
myLeg=LineLabs;
ShowSeries(permute(MP_Mms,[1 3 2]),permute(MP_FWHMs,[1 3 2]),"R_{H_2O} [mm]","FWHM [mm]",myLeg,myTitles);

% - Medical Physics: various positions (grouped by position)
myTitles=strings(nDataSets,1); myTitles(:)=LineLabs; myTitles(end+1)="MedPhys - various longitudinal positions";
myLeg=missing();
ShowSeries(MP_myPos(:,1),permute(MP_FWHMs,[2 1 3]),"S [m]","FWHM [mm]",myLeg,myTitles);

%% local functions
