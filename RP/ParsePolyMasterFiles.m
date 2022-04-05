function [tStamps,doses]=ParsePolyMasterFiles(path2Files)
% ParsePolyMasterFiles         acquire data in log files of polymaster (gamma monitors)
%
% input:
% - path2Files: path where the file(s) is located (a dir command is anyway performed);
% output:
% - tStamps (array of time stamps): time stamps of counts;
% - doses (array of floats): dose values at each time stamp;
%
% file of counts must have the following format:
% - a 1-line header;
% - a line with the integrated dose over 10 minutes; the format of the line is eg: "2021/07/23;23:04:26;PM1610 #218161;Dose Rate;0.0900 uSv/h;0.0000 uSv;0.0000 uSv;Gamma"
% - the reported dose is NOT cumulative!
%
% See also ParseDiodeFiles and ParseStationaryFiles.

    files=dir(path2Files);
    nDataSets=length(files);
    fprintf("acquring %i data sets in %s ...\n",nDataSets,path2Files);
    nReadFiles=0;
    nCountsTot=0;
    for iSet=1:nDataSets
        fileName=strcat(files(iSet).folder,"\",files(iSet).name);
        fileID = fopen(fileName,"r");
        C = textscan(fileID,'%s %s %s %s %s %s %s %s','HeaderLines',1,'Delimiter',';');
        fclose(fileID);
        nCounts=length(C{:,1});
        temp=split(C{:,6});
        ttStamps=datetime(join(string([C{:,1},C{:,2}])),"InputFormat","yyyy/MM/dd HH:mm:ss");
        tDoses=str2double(temp(:,1));
        if ( nCountsTot==0 )
            % first data set: simply acquire data
            tStamps=ttStamps;
            doses=tDoses;
        else
            % insert new data in proper position
            [indCopy,iStart,iStop]=GetInsIndicesTimes(ttStamps,tStamps);
            % - shift existing data
            if ( iStart<nCountsTot )
                tStamps(indCopy)=tStamps;
                doses(indCopy)=doses;
            end
            % - insert new data
            tStamps(iStart:iStop)=ttStamps;
            doses(iStart:iStop)=tDoses;
        end
        nCountsTot=nCountsTot+nCounts;
        fprintf("...acquired %d entries in file %s...\n",nCounts,files(iSet).name);
        nReadFiles=nReadFiles+1;
    end
    if ( nDataSets>0 )
        % try to return a vector array, not a row
        if ( size(tStamps,2)>size(tStamps,1) )
            tStamps=tStamps';
            doses=doses';
        end
        if ( nDataSets>1 )
            [tStamps,doses]=SortByTime(tStamps,doses); % sort by timestamps
        end
    else
        tStamps=missing;
        doses=missing;
    end
    fprintf("...acqured %i files, for a total of %d entries;\n",nReadFiles,nCountsTot);
end
