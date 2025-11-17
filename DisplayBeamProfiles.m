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
    end
    % - clear settings
    clear kPath myTit monTypes MonPaths myLabels

    % -------------------------------------------------------------------------
    % USER's input data
    % -------------------------------------------------------------------------
    kPath="P:\Accelerating-System\Accelerator-data";
    monTypes="CAM"; % CAM/CAMdumps, DDS, GIM, QBM/QPP/PIB/PMM/SFH/SFM/SFP
    myLabels=[...
        "RP data taking - 2022-03-29 - C400MeV - Tuning"
        ];
    % myLabels=monTypes;
    lSkip=false; % DDS summary file: skip first 2 lines (in addition to header line)
    myFigPath=".";
    % part-dependent stuff
%     % - protoni
%     myFigName="Tests with DDS";
%     myTit="Tests with DDS";
%     MonPaths=[...
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2213\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2219\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2222\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2225\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2227\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2229\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2231\"
%         "P:\Accelerating-System\Accelerator-data\scambio\Alessio\2023-08-21_testsOcchiConiglio\DumpProtSO1_LineT_Size10_22-08-2023_2233\"
%         ];

%     % - carbonio ISO1
%     myFigName="ISO1_C400_tuning_2022-03-29";
%     myTit="ISO1 - C400MeV - tuning - 2022-03-29 (RP data taking)";
%     MonPaths=[...
%         strcat(kPath,"\Area dati MD\00XPR\Recommissioning_with_beam_for_RP\2022-03-29\Water\Stability_carbonio_350MeV\CarbSO2_LineX1_Size6_30-03-2022_0248\") 
%         ];
%     selIDsLow=1:10;
%     selIDsHigh=401:410;
%     selIDs=[selIDsLow selIDsHigh];
%     % - carbonio ISO2
%     myFigName="ISO2_C400_tuning_2022-04-06";
%     myTit="ISO2 - C400MeV - tuning - 2022-04-06 (RP data taking)";
%     MonPaths=[...
%         strcat(kPath,"\Area dati MD\00XPR\Recommissioning_with_beam_for_RP\2022-04-06\Water\Stability_carbonio_400MeV\CarbSO2_LineX2_Size6_07-04-2022_0039\") 
%         ];
%     selIDsLow=1:10;
%     selIDsHigh=401:410;
%     selIDs=[selIDsLow selIDsHigh];
%     % - carbonio ISO3
%     myFigName="ISO3_C400_tuning_2022-04-10";
%     myTit="ISO3 - C400MeV - tuning - 2022-04-10 (RP data taking)";
%     MonPaths=[...
%         strcat(kPath,"\Area dati MD\00XPR\Recommissioning_with_beam_for_RP\2022-04-10\Water\Stability_carbonio_400MeV\CarbSO2_LineX3_Size6_10-04-2022_1559\") 
%         ];
%     selIDsLow=1:10;
%     selIDsHigh=401:410;
%     selIDs=[selIDsLow selIDsHigh];
    % - carbonio ISO4
    myFigName="ISO4_C400_tuning_2022-04-20";
    myTit="ISO4 - C400MeV - tuning - 2022-04-20 (RP data taking)";
    MonPaths=[...
        strcat(kPath,"\Area dati MD\00XPR\Recommissioning_with_beam_for_RP\2022-04-20\Water\Stability_carbonio_400MeV\Run1\CarbSO2_LineX4_Size6_21-04-2022_0107\") 
        ];
    selIDsLow=1:10;
    selIDsHigh=401:410;
    selIDs=[selIDsLow selIDsHigh];

    vsX="ID"; % ["Ek"/"En"/"Energy","mm"/"r"/"range","ID"/"IDs"]
    iNotShow=false(127,2); 
    % iNotShow(1:2,1)=true;  % do not show left-most fibers on hor plane (broken)
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
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsCAMProcedure(tmpProfiles);
%             FWHMval=0.5;
%             noiseLevelBAR=0.0; noiseLevelFWHM=0.0;
%             INTlevel=0.0;
%             lDebug=true;
%             [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsCAMProcedure(tmpProfiles,FWHMval,noiseLevelBAR,noiseLevelFWHM,INTlevel,lDebug);
%             noiseLevel=0.0;
%             INTlevel=0;
%             lDebug=true;
%             [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles,noiseLevel,INTlevel,lDebug);
        case {"QPP","SFP"}
            noiseLevel=0.025;
            INTlevel=5;
            lDebug=true;
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles,noiseLevel,INTlevel,lDebug);
        otherwise % BD: DDS,GIM,SFH,SFM
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsBDProcedure(tmpProfiles);
    end
    % - Eks,mms
    tmpEksProf=ConvertCyCodes(tmpCyCodesProf,"Ek","MeVvsCyCo_P.xlsx");
    tmpMmsProf=ConvertCyCodes(tmpCyCodesProf,"mm","MeVvsCyCo_P.xlsx");
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
    if ( strcmpi(monTypes(iDataAcq),"CAM") | strcmpi(monTypes(iDataAcq),"GIM") | strcmpi(monTypes(iDataAcq),"DDS") )
        clear tmpCyProgsSumm tmpCyCodesSumm tmpBARsSumm tmpFWHMsSumm tmpASYMsSumm tmpINTsSumm tmpEksSumm tmpMmsSumm;
        [tmpCyProgsSumm,tmpCyCodesSumm,tmpBARsSumm,tmpFWHMsSumm,tmpASYMsSumm,tmpINTsSumm]=ParseBeamProfileSummaryFiles(MonPaths(iDataAcq),monTypes(iDataAcq),lSkip);
        if (length(tmpCyProgsSumm)<=1)
            warning("...no summary data aquired!");
            tmpEksSumm=NaN();
            tmpMmsSumm=NaN();
        else
            % - quick check of consistency of parsed data
            if (length(tmpCyProgsSumm)~=length(tmpCyProgsProf))
                error("...inconsistent data set between summary data (%d) and actual profiles (%d)!",...
                    length(tmpCyProgsSumm),length(tmpCyProgsProf));
            end
            % - Eks,mms
            tmpEksSumm=ConvertCyCodes(tmpCyCodesSumm,"Ek","MeVvsCyCo_P.xlsx");
            tmpMmsSumm=ConvertCyCodes(tmpCyCodesSumm,"mm","MeVvsCyCo_P.xlsx");
        end
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
            % - get unique data sets
            [~,jDataAcq,~]=unique(mmsProf(:,iDataAcq),"last"); jDataAcq=jDataAcq(~isnan(mmsProf(jDataAcq,iDataAcq)));
            [~,jDataSum,~]=unique(mmsSumm(:,iDataSumm),"last"); jDataSum=jDataSum(~isnan(mmsSumm(jDataSum,iDataSumm)));
            % - compare summary data and statistics on profiles
            CompBars=BARsSumm(jDataSum,:,iDataSumm); CompBars(:,:,2)=BARsProf(jDataAcq,:,iDataAcq);
            CompFwhms=FWHMsSumm(jDataSum,:,iDataSumm); CompFwhms(:,:,2)=FWHMsProf(jDataAcq,:,iDataAcq);
            CompInts=INTsSumm(jDataSum,:,iDataSumm); CompInts(:,:,2)=INTsProf(jDataAcq,:,iDataAcq);
            switch upper(vsX)
                case {"EK","EN","ENERGY"}
                    CompXs=EksSumm(jDataSum,iDataAcq); CompXs(:,2)=EksProf(jDataAcq,iDataAcq);
                case {"ID","IDS"}
                    CompXs=(1:size(BARsSumm(jDataSum,:,iDataSumm),1))'; CompXs(:,2)=addIndex(jDataAcq,iDataAcq);
                case {"MM","R","RANGE"}
                    CompXs=mmsSumm(jDataSum,iDataAcq); CompXs(:,2)=mmsProf(jDataAcq,iDataAcq);
                otherwise
                    error("Cannot recognise what you want as X-axis in summary overviews: %s!",vsX);
            end
            ShowBeamProfilesSummaryData(CompBars,CompFwhms,CompInts,missing(),CompXs,addLabel,...
                ["summary data" "stat on profiles"],missing(),sprintf("%s - %s - summary vs profile stats",myTit,myLabels(iDataAcq)));
    end
end

%% save summary data
% oFileName=strcat(kPath,"\scambio\Alessio\Carbonio_preSteering_summary-from-profiles.csv");
% SaveBeamProfileSummaryFile(oFileName,tmpBARsProf,tmpFWHMsProf,tmpINTsProf,tmpCyCodesProf,tmpCyProgsProf,"DDS");

%% further plots
% ShowSpectra(profiles(:,[1 1+selIDs],:),sprintf("%s - 3D profiles",myTit));
% normProfiles=profiles(:,[1 1+selIDs],:);
% for ii=1:length(selIDs)
%     for iPlane=1:size(normProfiles,3)
%         normProfiles(:,1+ii,iPlane)=normProfiles(:,1+ii,iPlane)./INTsProf(selIDs(ii),iPlane);
%     end
% end
% if (exist("myFigPath","var")), myFigSave=strcat(myFigPath,"\3DnormProfiles_",myFigName,".fig"); else myFigSave=missing(); end
% ShowSpectra(normProfiles,sprintf("%s - 3D NORMALISED profiles",myTit),missing(),missing(),missing(),myFigSave);
% 
% ff=figure(); ff.Position(3)=1.5*ff.Position(3);
% cm=[colormap(winter(length(selIDsLow)));colormap(copper(length(selIDsHigh)))]; planeLab=["HOR plane" "VER plane"];
% for iPlane=1:length(planeLab)
%     subplot(1,3,iPlane);
%     for ii=1:length(selIDs)
%         if (ii>1), hold on; end
%         stairs(normProfiles(:,1,iPlane),normProfiles(:,1+ii,iPlane),"Color",cm(ii,:));
%     end
%     grid on; xlabel("[mm]"); ylabel("[]"); title(planeLab(iPlane));
% end
% % legend plot
% subplot(1,3,3);
% for ii=1:length(selIDs)
%     if (ii>1), hold on; end
%     stairs(NaN(),NaN(),"Color",cm(ii,:));
% end
% grid on; xlabel("[mm]"); ylabel("[]"); title(planeLab(iPlane));
% legend(compose("ID=%d",selIDs),"Location","best");
% % general stuff
% sgtitle(sprintf("%s - 3D NORMALISED profiles",myTit));
% if (exist("myFigPath","var")), savefig(strcat(myFigPath,"\2DnormProfiles_",myFigName,".fig")); end


