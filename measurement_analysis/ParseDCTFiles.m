function [cyProgs,cyCodes,currs,tStamps]=ParseDCTFiles(paths2Files)
% ParseDCTFiles        parse log files of the synchro DCT/DCX
%
% input:
% - paths2Files (array of strings): path(s) where the file(s) is located (a dir command is anyway performed).
% - lDCX (boolean): flag, true if the DCX files should be parsed;
% output:
% - cyProgs (array of strings): cycle prog associated to each event;
% - cyCodes (array of strings): cycle code associated to each event;
% - currs (2D array of floats): charge [10^9 charges]:
%   . column 1: accelerated;
%   . column 2: injected;
% - tStamps (array of time stamps): time stamps of events (not clear which event of
%   timing, actually...);
%
% file of counts must have the following format:
% - 1 header line;
% - a line for each cycle prog; the format of the line is eg:
%   * "195873069  420036440900  0.433  0.863  50.166  00:02:13"
%   * "243520368	0000100032444900	02:06:22	0.880	0.520	59.1	0	0"

    fprintf("acquring DCT data...\n");
    if (~exist("lDCX","var")), lDCX=false; end
    nReadFiles=0;
    nCountsTot=0;
    for iPath=1:length(paths2Files)
        files=dir(paths2Files(iPath));
        nDataSets=length(files);
        fprintf("...acquring %i data sets in %s...\n",nDataSets,paths2Files(iPath));
        for iSet=1:nDataSets
            fileNameSplit=split(files(iSet).name,"_"); 
            fileName=strcat(files(iSet).folder,"\",files(iSet).name);
            fprintf("   ...acquiring file %s (%d/%d)...\n",files(iSet).name,iSet,nDataSets);
            lDCX=startsWith(files(iSet).name,"dcx",'IgnoreCase',true);
            fileID = fopen(fileName,"r");
            if (lDCX)
                C = textscan(fileID,'%s %s %s %f %f %f %d %d','HeaderLines',1);
                iDate=3;
                dateFmt="yyyy-MM-dd HH:mm:ss";
                iAcc=5;
                iInj=4;
            else
                C = textscan(fileID,'%s %s %f %f %f %s','HeaderLines',1);
                iDate=6;
                dateFmt="dd-MM-yyyy HH:mm:ss";
                iAcc=3;
                iInj=4;
            end
            fclose(fileID);
            nCounts=length(C{:,1});
            tStampAss=fileNameSplit(2); tStampAss(1:nCounts)=tStampAss; % time stamp: day
            tStamps(nCountsTot+1:nCountsTot+nCounts)=datetime(join(string([tStampAss(:),C{:,iDate}])),"InputFormat",dateFmt);
            cyProgs(nCountsTot+1:nCountsTot+nCounts)=string(C{:,1});
            cyCodes(nCountsTot+1:nCountsTot+nCounts)=string(C{:,2});
            if (lDCX)
                cyCodes(nCountsTot+1:nCountsTot+nCounts)=extractBetween(cyCodes(nCountsTot+1:nCountsTot+nCounts),5,strlength(cyCodes(nCountsTot+1:nCountsTot+nCounts)));
            end
            currs(nCountsTot+1:nCountsTot+nCounts,1)=C{:,iAcc};
            currs(nCountsTot+1:nCountsTot+nCounts,2)=C{:,iInj};
            fprintf("...acquired %d entries;\n",nCounts);
            nCountsTot=nCountsTot+nCounts;
            nReadFiles=nReadFiles+1;
        end
    end
    if ( nReadFiles>0 )
        % try to return a vector array, not a row
        if ( size(tStamps,2)>size(tStamps,1) )
            tStamps=tStamps';
            cyProgs=cyProgs';
            cyCodes=cyCodes';
        end
        cyCodes=PadCyCodes(cyCodes);
        cyCodes=UpperCyCodes(cyCodes);
        if ( nReadFiles>1 )
            [tStamps,currs,ids]=SortByTime(tStamps,currs); % sort by timestamps
            cyProgs=cyProgs(ids(:,1));
            cyCodes=cyCodes(ids(:,1));
        end
    else
        tStamps=missing;
        cyProgs=missing;
        cyCodes=missing;
        currs=missing;
    end
    fprintf("...acqured %i files, for a total of %d entries;\n",nReadFiles,nCountsTot);
    
end
