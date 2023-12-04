% {}~

%% description
% this is a script which displays basic beam properties which depend on beam energy;

%% include libraries
% - include Matlab libraries
pathToLibrary="./";
addpath(genpath(pathToLibrary));
pathToLibrary="../MachineRefs";
addpath(genpath(pathToLibrary));

%% settings

% -------------------------------------------------------------------------
% USER's input data
% what to load
machine="ISO1";
beamPart=["PROTON" "CARBON"];
% what to show
showX="range";
showXlabel="R [mm]";
showY=[ "beta" "gamma" "betagamma" "pc" "Brho" "Ek" ];
showYlabel=["\beta_{rel} []" "\gamma_{rel} []" "\beta_{rel}\gamma_{rel} []" "pc [MeV/c/u]" "B\rho [Tm]" "E_k [MeV/u]"];
nCoupled=3;
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% check of user input data
nSets=max([length(beamPart) length(machine)]);
beamPart=ConfigCheck(beamPart,nSets,"beamPart");
machine=ConfigCheck(machine,nSets,"machine");
mSets=max([length(showX) length(showXlabel) length(showY) length(showYlabel)]);
showX=ConfigCheck(showX,mSets,"showX");
showXlabel=ConfigCheck(showXlabel,mSets,"showXlabel");
showY=ConfigCheck(showY,mSets,"showY");
showYlabel=ConfigCheck(showYlabel,mSets,"showYlabel");

%% clear variables
xVals=missing();
yVals=missing();

%% parse DBs

% - get values
myLeg=strings(nSets,1);
for iSet=1:nSets
    clear EnData tmpDataX tmpDataY;
    myConfig=sprintf("%s,%s",machine(iSet),beamPart(iSet));
    FullFileName=ReturnDefFile("BRHO",myConfig); EnData=readtable(FullFileName);
    myLeg(iSet)=myConfig;
    % - store data
    [tmpDataX,tmpDataY]=ExtractFromTable(EnData,showX,showY);
    xVals=ExpandMat(xVals,tmpDataX);
    yVals=ExpandMat(yVals,tmpDataY);
end
xVals=permute(xVals,[1 3 2]); % what to show is the outermost dimension
yVals=permute(yVals,[1 3 2]);

%% show stuff
ShowSeries(xVals,yVals,showXlabel,showYlabel,myLeg);

%% local functions
