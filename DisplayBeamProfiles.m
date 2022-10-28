% {}~

%% description
% this is a script which parses beam profiles files and plots them
% - the script crunches as many files as desired, provided the fullpaths;
% - for the time being, only CAMeretta/DDS/GIM/SFH/SFM/SFP monitors;
%   QBM/PMM/PIB are NOT supported but the implementation should be
%   straightforward;
% - for CAMeretta/DDS/GIM: both summary files and actual profiles in the same
%   path are aquired;
% - for GIM/SFH/SFM/SFP: profiles are acquired, but only the integral ones are
%   shown;
% - the script visualises in 3D the spill-per-spill profiles, horizontal and
%   vertical planes separately;
% - the script shows summary data; for CAMeretta/DDS/GIM only, the script also
%   compares summary data against statistics data computed on profiles;

%% include libraries
% % - include Matlab libraries
% pathToLibrary=".\";
% addpath(genpath(pathToLibrary));

%% settings
clear kPath myTit monTypes MonPaths myLabels

% -------------------------------------------------------------------------
% USER's input data
kPath="P:\Accelerating-System\Accelerator-data";
% kPath="K:";
% MonPathMain="\Area dati MD\00XPR\XPR3\Protoni\MachinePhoto\23-08-2022";
% MonPathMain="\Area dati MD\00XPR\XPR3\Protoni\MachinePhoto\13-09-2022";
% MonPathMain="\Area dati MD\00XPR\XPR3\Protoni\MachinePhoto\13-09-2022\post-steering";
% MonPathMain="\Area dati MD\00XPR\XPR3\Protoni\MachinePhoto\2022-10-08\pre-steering";
% MonPathMain="\scambio\Alessio\2022-10-09\BD_Scans\HE-030B-SFP\P_030mm";
% GIM in and He-025B-SFM
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMIN\Hor\2022-08-22";
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMIN\Ver\2022-08-22";
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMIN\Hor\2022-07-19";
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMIN\Ver\2022-07-19";
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMOUT\Hor\2022-09-12_varieEnergie";
% MonPathMain="\Area dati MD\00sfh\Recal_H2025SFM\GIMOUT\Hor\2022-10-02_270mm";
% - GIM profiles
% MonPathMain="\Area dati MD\00Summary\Carbonio\2022\09-Settembre\30-09-2022\GIM";
% MonPathMain="\Area dati MD\00Summary\Protoni\2022\09-Settembre\30-09-2022\GIM";
% myTit=sprintf("%s profiles in %s",monType,MonPathMain);

% % manual input
% myTit="Steering ISO2 - Carbonio - DDS";
% monTypes="DDS"; % CAM, DDS, GIM, SFH/SFM - QBM/PMM/PIB/SFP to come
% MonPaths=[...
%     strcat(kPath,"\Area dati MD\00Steering\SteeringPazienti\carbonio\XPR2\2022.10.26\PRC-544-*-DDSF\") 
%     ];
% myLabels=[...
%     "2022-10-26 - pre-steering"
%     ];
% lSkip=false;

% load pre-defined settings/paths
run("../../chooseSettings.m");
% -------------------------------------------------------------------------

% check of user input data
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
    if ( strcmpi(monTypes(iDataAcq),"CAM") | strcmpi(monTypes(iDataAcq),"DDS") )
        [tmpProfiles,tmpCyCodesProf,tmpCyProgsProf]=ParseBeamProfiles(MonPaths(iDataAcq),monTypes(iDataAcq));
        if (length(tmpCyProgsProf)<=1), error("...no profiles aquired!"); end
    else % GIM,SFH,SFM,SFP
        [tmpDiffProfiles,tmpCyCodesProf,tmpCyProgsProf]=ParseBeamProfiles(MonPaths(iDataAcq),monTypes(iDataAcq));
        if (length(tmpCyProgsProf)<=1), error("...no profiles aquired!"); end
        % - get integral profiles
        tmpProfiles=SumSpectra(tmpDiffProfiles); 
    end
    % - get statistics out of profiles
    switch upper(monTypes(iDataAcq))
        case "CAM"
            [tmpBARsProf,tmpFWHMsProf,tmpINTsProf]=StatDistributionsCAMProcedure(tmpProfiles);
        case "SFP"
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
    if ( strcmpi(monTypes(iDataAcq),"CAM") | strcmpi(monTypes(iDataAcq),"DDS") | strcmpi(monTypes(iDataAcq),"GIM") )
        clear tmpCyProgsSumm tmpCyCodesSumm tmpBARsSumm tmpFWHMsSumm tmpASYMsSumm tmpINTsSumm tmpEksSumm tmpMmsSumm;
        [tmpCyProgsSumm,tmpCyCodesSumm,tmpBARsSumm,tmpFWHMsSumm,tmpASYMsSumm,tmpINTsSumm]=ParseBeamProfileSummaryFiles(MonPaths(iDataAcq),monTypes(iDataAcq),lSkip);
        if (length(tmpCyProgsSumm)<=1), error("...no summary data aquired!"); end
        % - quick check of consistency of parsed data
        if (length(tmpCyProgsSumm)~=length(tmpCyProgsProf)), error("...inconsistent data set between summary data and actual profiles"); end
        % - Eks,mms
        tmpEksSumm=ConvertCyCodes(tmpCyCodesSumm,"Ek","MeVvsCyCo_P.xlsx");
        tmpMmsSumm=ConvertCyCodes(tmpCyCodesSumm,"mm","MeVvsCyCo_P.xlsx");
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
% - 3D plot of profiles
ShowSpectra(profiles,sprintf("%s - 3D profiles",myTit),mmsProf,"Range [mm]",myLabels);
% - statistics on profiles
ShowBeamProfilesSummaryData(BARsProf,FWHMsProf,INTsProf,missing(),mmsProf,"Range [mm]",myLabels,missing(),myTit);
% - statistics on profiles vs summary files
for iDataAcq=1:nDataSets
    switch upper(monTypes(iDataAcq))
        case {"CAM","DDS","GIM"}
            % - compare summary data and statistics on profiles
            CompBars=BARsSumm(:,:,iDataAcq); CompBars(:,:,2)=BARsProf(:,:,iDataAcq);
            CompFwhms=FWHMsSumm(:,:,iDataAcq); CompFwhms(:,:,2)=FWHMsProf(:,:,iDataAcq);
            CompInts=INTsSumm(:,:,iDataAcq); CompInts(:,:,2)=INTsProf(:,:,iDataAcq);
            CompXs=mmsSumm(:,iDataAcq); CompXs(:,2)=mmsProf(:,iDataAcq);
            ShowBeamProfilesSummaryData(CompBars,CompFwhms,CompInts,missing(),CompXs,"Range [mm]",...
                ["summary data" "stat on profiles"],missing(),sprintf("%s - %s - summary vs profile stats",myTit,myLabels(iDataAcq)));
    end
end

%% save summary data
% oFileName=strcat(kPath,"\scambio\Alessio\Carbonio_preSteering_summary-from-profiles.csv");
% SaveBeamProfileSummaryFile(oFileName,tmpBARsProf,tmpFWHMsProf,tmpINTsProf,tmpCyCodesProf,tmpCyProgsProf,"DDS");
