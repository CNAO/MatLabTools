% {}~

%% description
% this is a script which parses beam profiles files and plots them
% - the script crunches as many data sets as desired, provided the fullpaths;
% - for the time being, only CAMeretta/DDS/GIM/QPP/SFH/SFM/SFP monitors;
%   QBM/PMM/PIB are NOT supported but the implementation should be
%   straightforward;
% - for CAMeretta/DDS/GIM: both summary files and actual profiles in the same
%   path are aquired;
% - for GIM/SFH/SFM/SFP: profiles are acquired, but only the integral ones are
%   shown;
% - the script visualises in 3D the spill-per-spill profiles, horizontal and
%   vertical planes separately;
% - the script also shows statistics data computed on profiles;
%   for CAMeretta/DDS/GIM only, the script also compares summary data
%   against statistics data computed on profiles;

%% clean
clear all;
close all;

%% manual run
if (~exist("MonPaths","var")) 
    % script manually run by user

    % -------------------------------------------------------------------------
    % default stuff
    % -------------------------------------------------------------------------
    % - include Matlab libraries
    if (~exist("pathToLibrary","var"))
        pathToLibrary=".\";
        addpath(genpath(pathToLibrary));
        pathToLibrary="../MachineRefs";
        addpath(genpath(pathToLibrary));
    end
    % - clear settings
    clear kPath myTit monTypes MonPaths myLabels

    % -------------------------------------------------------------------------
    % USER's input data
    % -------------------------------------------------------------------------
    kPath="P:\Accelerating-System\Accelerator-data";
    monTypes="CAM"; % CAM/CAMdumps, DDS, GIM, QBM/QPP/PIB/PMM/SFH/SFM/SFP
    myLabels=[...
        "Sala1 (16-10-2023)"
        "Sala2H (16-10-2023)"
        "Sala2V (16-10-2023)"
        "Sala3 (16-10-2023)"
        ];
    % myLabels=monTypes;
    lSkip=false; % DDS summary file: skip first 2 lines (in addition to header line)
    myFigPath=".";
    % part-dependent stuff
    % - protoni
    myFigName="Machie Photos";
    myTit="Machine Photos";
    MonPaths=[...
        "P:\Accelerating-System\Accelerator-data\Area dati MD\00Steering\SteeringPazienti\carbonio\sala1\2023\2023.10.16\CarbSO2_LineZ_Size6_16-10-2023_0800\"
        "P:\Accelerating-System\Accelerator-data\Area dati MD\00Steering\SteeringPazienti\carbonio\sala2U\2023\2023.10.16\CarbSO2_LineU_Size6_16-10-2023_0219\"
        "P:\Accelerating-System\Accelerator-data\Area dati MD\00Steering\SteeringPazienti\carbonio\sala2V\2023\2023.10.16\CarbSO2_LineV_Size6_16-10-2023_0908\"
        "P:\Accelerating-System\Accelerator-data\Area dati MD\00Steering\SteeringPazienti\carbonio\sala3\2023\2023.10.15\CarbSO2_LineT_Size6_15-10-2023_2313\"
        ];
%     % - carbonio
%     myFigName="summary_carbonio_GIM_2023-05-09.10";
%     myTit="summary 2023-05-09.10 - Carbonio";
%     MonPaths=[...
%         strcat(kPath,"\Area dati MD\00Summary\Carbonio\2023\Maggio\2023.05.09-10\Steering ridotti\GIM\PRC-544-230511-0028_H2-009B-GIM_AllTrig\") 
%         ];
    vsX="Ek"; % ["Ek"/"En"/"Energy","mm"/"r"/"range","ID"/"IDs"]
    iNotShow=false(127,2); 
    iNotShow(1:2,1)=true;  % do not show left-most fibers on hor plane (broken)
end

%% check of user input data
if ( length(MonPaths)~=length(myLabels) )
    error("number of paths different from number of labels: %d~=%d",length(MonPaths),length(myLabels));
else
    nDataSets=length(MonPaths);
end
if (length(monTypes)~=nDataSets)
    if ( length(monTypes)==1 )
        myStrings=strings(nDataSets,1);
        myStrings(:,1)=monTypes;
        monTypes=myStrings;
    else
        error("please specify a label for each data set");
    end
end
if (~exist("vsX","var")), vsX="mm"; end
if (~exist("iNotShow","var")), iNotShow=NaN(1,2); end

%% clear storage
% - clear summary data
[cyProgsSumm,cyCodesSumm,BARsSumm,FWHMsSumm,ASYMsSumm,INTsSumm,EksSumm,mmsSumm]=...
    deal(missing(),missing(),missing(),missing(),missing(),missing(),missing(),missing());
% - clear profiles
[profiles,cyCodesProf,cyProgsProf,BARsProf,FWHMsProf,INTsProf,EksProf,mmsProf]=...
    deal(missing(),missing(),missing(),missing(),missing(),missing(),missing(),missing());

%% parse files
for iDataAcq=1:nDataSets
    % - parse profiles
    clear tmpCyProgsProf tmpCyCodesProf tmpBARsProf tmpFWHMsProf tmpINTsProf tmpProfiles tmpDiffProfiles tmpEksProf tmpMmsProf;
    switch upper(monTypes(iDataAcq))
        case {"CAM","DDS"}
            [tmpProfiles,tmpCyCodesProf,tmpCyProgsProf]=ParseBeamProfiles(MonPaths(iDataAcq),monTypes(iDataAcq));
            if (length(tmpCyProgsProf)<=1), error("...no profiles aquired!"); end
        otherwise % CAMdumps and BD: GIM, QBM/QPP/PIB/PMM/SFH/SFM/SFP
            [tmpDiffProfiles,tmpCyCodesProf,tmpCyProgsProf]=ParseBeamProfiles(MonPaths(iDataAcq),monTypes(iDataAcq));
            if (length(tmpCyProgsProf)<=1), error("...no profiles aquired!"); end
            % - get integral profiles
            tmpProfiles=SumSpectra(tmpDiffProfiles); 
    end
    % - get statistics out of profiles
    switch upper(monTypes(iDataAcq))
        case "CAM"
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsCAMProcedure(tmpProfiles);
        case "CAMDUMPS"
%             FWHMval=0.5;
%             noiseLevelBAR=0.0; noiseLevelFWHM=0.0;
%             INTlevel=0.0;
%             lDebug=true;
%             [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsCAMProcedure(tmpProfiles,FWHMval,noiseLevelBAR,noiseLevelFWHM,INTlevel,lDebug);
            noiseLevel=0.0;
            INTlevel=0;
            lDebug=true;
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles,noiseLevel,INTlevel,lDebug);
        case {"QPP","SFP"}
            noiseLevel=0.025;
            INTlevel=5;
            lDebug=true;
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles,noiseLevel,INTlevel,lDebug);
        otherwise % BD: DDS,GIM,SFH,SFM
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles);
    end
    % - Eks,mms
    tmpEksProf=MapCyCodes(tmpCyCodesProf,"Ek","SYNCHRO");
    tmpMmsProf=MapCyCodes(tmpCyCodesProf,"Range","SYNCHRO");
    % - store data
    cyProgsProf=ExpandMat(cyProgsProf,tmpCyProgsProf);
    cyCodesProf=ExpandMat(cyCodesProf,tmpCyCodesProf);
    profiles=ExpandMat(profiles,tmpProfiles);
    BARsProf=ExpandMat(BARsProf,tmpBARsProf);
    FWHMsProf=ExpandMat(FWHMsProf,tmpFWHMsProf);
    INTsProf=ExpandMat(INTsProf,tmpINTsProf);
    EksProf=ExpandMat(EksProf,tmpEksProf);
    mmsProf=ExpandMat(mmsProf,tmpMmsProf);

    % - parse summary files
    if ( strcmpi(monTypes(iDataAcq),"CAM") | strcmpi(monTypes(iDataAcq),"DDS") | strcmpi(monTypes(iDataAcq),"GIM") )
        clear tmpCyProgsSumm tmpCyCodesSumm tmpBARsSumm tmpFWHMsSumm tmpASYMsSumm tmpINTsSumm tmpEksSumm tmpMmsSumm;
        [tmpCyProgsSumm,tmpCyCodesSumm,tmpBARsSumm,tmpFWHMsSumm,tmpASYMsSumm,tmpINTsSumm]=ParseBeamProfileSummaryFiles(MonPaths(iDataAcq),monTypes(iDataAcq),lSkip);
        if (length(tmpCyProgsSumm)<=1), error("...no summary data aquired!"); end
        % - quick check of consistency of parsed data
        if (length(tmpCyProgsSumm)~=length(tmpCyProgsProf)), error("...inconsistent data set between summary data and actual profiles"); end
        % - Eks,mms
        tmpEksSumm=MapCyCodes(tmpCyCodesSumm,"Ek","SYNCHRO");
        tmpMmsSumm=MapCyCodes(tmpCyCodesSumm,"Range","SYNCHRO");
        % - store data
        cyProgsSumm=ExpandMat(cyProgsSumm,tmpCyProgsSumm);
        cyCodesSumm=ExpandMat(cyCodesSumm,tmpCyCodesSumm);
        BARsSumm=ExpandMat(BARsSumm,tmpBARsSumm);
        FWHMsSumm=ExpandMat(FWHMsSumm,tmpFWHMsSumm);
        ASYMsSumm=ExpandMat(ASYMsSumm,tmpASYMsSumm);
        INTsSumm=ExpandMat(INTsSumm,tmpINTsSumm);
        EksSumm=ExpandMat(EksProf,tmpEksSumm);
        mmsSumm=ExpandMat(mmsProf,tmpMmsSumm);
    end
    
end

%% show data
switch upper(vsX)
    case {"EK","EN","ENERGY"}
        addIndex=EksProf;
        addLabel="E_k [MeV/u]";
    case {"ID","IDS"}
        addIndex=repmat((1:(size(profiles,2)-1))',[1 size(profiles,4)]);
        addLabel="ID";
    case {"MM","R","RANGE"}
        addIndex=mmsProf;
        addLabel="Range [mm]";
    otherwise
        error("Cannot recognise what you want as X-axis in summary overviews: %s!",vsX);
end
if (exist("shifts","var"))
    for iDataAcq=1:nDataSets
        addIndex(:,iDataAcq)=addIndex(:,iDataAcq)+shifts(iDataAcq);
    end
end
% - 3D plot of profiles
if (exist("myFigPath","var")), myFigSave=strcat(myFigPath,"\3Dprofiles_",myFigName,".fig"); else myFigSave=missing(); end
ShowSpectra(profiles,sprintf("%s - 3D profiles",myTit),addIndex,addLabel,myLabels,myFigSave,1,iNotShow); % use 3D sinogram style
% - show statistics on profiles
if (exist("myFigPath","var")), myFigSave=strcat(myFigPath,"\Stats_",myFigName,".fig"); else myFigSave=missing(); end
ShowBeamProfilesSummaryData(BARsProf,FWHMsProf,INTsProf,missing(),addIndex,addLabel,myLabels,missing(),myTit,myFigSave);
% - show statistics on profiles vs summary files
iDataSumm=0;
for iDataAcq=1:nDataSets
    switch upper(monTypes(iDataAcq))
        case {"CAM","DDS","GIM"}
            iDataSumm=iDataSumm+1;
            % - compare summary data and statistics on profiles
            CompBars=BARsSumm(:,:,iDataSumm); CompBars(:,:,2)=BARsProf(:,:,iDataAcq);
            CompFwhms=FWHMsSumm(:,:,iDataSumm); CompFwhms(:,:,2)=FWHMsProf(:,:,iDataAcq);
            CompInts=INTsSumm(:,:,iDataSumm); CompInts(:,:,2)=INTsProf(:,:,iDataAcq);
            switch upper(vsX)
                case {"EK","EN","ENERGY"}
                    CompXs=EksSumm(:,iDataAcq); CompXs(:,2)=EksProf(:,iDataAcq);
                case {"ID","IDS"}
                    CompXs=(1:size(BARsSumm,1))'; CompXs(:,2)=addIndex(:,iDataAcq);
                case {"MM","R","RANGE"}
                    CompXs=mmsSumm(:,iDataAcq); CompXs(:,2)=mmsProf(:,iDataAcq);
                otherwise
                    error("Cannot recognise what you want as X-axis in summary overviews: %s!",vsX);
            end
            ShowBeamProfilesSummaryData(CompBars,CompFwhms,CompInts,missing(),CompXs,addLabel,...
                ["summary data" "stat on profiles"],missing(),sprintf("%s - %s - summary vs profile stats",myTit,myLabels(iDataAcq)));
    end
end

%% show figures of merit
% - references
[refFWHM,refXVals]=Spots_LoadEffectiveSpecs("CARBON",vsX,"TM"); refLeg=["reference" "ref+" "ref-"];

% - FWHM
showYlabels=strings(nDataSets,1); showYlabels(:)="FWHM [mm]";
showXlabels=strings(nDataSets,1); showXlabels(:)=addLabel;
myTitles=strings(nDataSets+1,1); myTitles(1:end-1)=myLabels; myTitles(end)="FWHM";
xVals=NaN(size(addIndex,1),2,size(addIndex,2));
xVals(:,1,:)=addIndex; xVals(:,2,:)=addIndex;
myLeg=["HOR" "VER"];
ShowSeries(xVals,FWHMsProf,showXlabels,showYlabels,myLeg,myTitles,refFWHM,refXVals,refLeg);

% - xy-asymmetry
[FWHMprofGeoMean,profASYM]=Spots_MeritFWHM(FWHMsProf);
showYlabels=["[mm]" "[%]"];
showXlabels=strings(2,1); showXlabels(:)=addLabel;
myLeg=myLabels; myTitles=["FWHM_y-FWHM_x" "normalised: (FWHM_y-FWHM_x)/geoAve" "yx-asymmetry"];
xVals=NaN(size(addIndex,1),size(addIndex,2),2);
xVals(:,:,1)=addIndex; xVals(:,:,2)=addIndex;
yVals=NaN(size(addIndex,1),size(addIndex,2),2);
yVals(:,:,1)=profASYM; yVals(:,:,2)=profASYM./FWHMprofGeoMean*100;
ShowSeries(xVals,yVals,showXlabels,showYlabels,myLeg,myTitles);

% - BARicenters
showYlabels=strings(nDataSets,1); showYlabels(:)="BAR [mm]";
showXlabels=strings(nDataSets,1); showXlabels(:)=addLabel;
myTitles=strings(nDataSets+1,1); myTitles(1:end-1)=myLabels; myTitles(end)="BAR";
xVals=NaN(size(addIndex,1),2,size(addIndex,2));
xVals(:,1,:)=addIndex; xVals(:,2,:)=addIndex;
myLeg=["HOR" "VER"];
ShowSeries(xVals,BARsProf,showXlabels,showYlabels,myLeg,myTitles);

%% save summary data
% oFileName=strcat(kPath,"\scambio\Alessio\Carbonio_preSteering_summary-from-profiles.csv");
% SaveBeamProfileSummaryFile(oFileName,tmpBARsProf,tmpFWHMsProf,tmpINTsProf,tmpCyCodesProf,tmpCyProgsProf,"DDS");
