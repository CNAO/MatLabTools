function [ losses, nTotLosses ] = ReadLosses(path2Files,nInitial,delays,nExpected)
% READLOSSES  Read losses from MAD-X/PTC tracking.
%
% example format of line of parsed files:
%                 NUMBER, TURN, X, PX, Y, PY, T, PT, S, E, ELEMENT
%
% input arguments:
%   path2Files: path to files to parse;
%               example: "delay_%02u\\beam2track*\\losses.tfs"
%
% optional input arguments:
%   nInitial: number of starting conditions of the tracking giving rise to
%        the losses parsed in a specific file, to be added to particle IDs;
%   delays: turn delays to be added to turn number;
%   nExpected: expected number of initial conditions;
%              if given, a check on the number of conditions parsed is
%              performed;
%
% output arguments:
%   losses: cell array of particle coordinates;
%   nTotLosses: total number of particles read

    if (~exist('nInitial','var')), nInitial=missing(); end
    if (~exist('delays','var')), delays=missing(); end
    if (~exist('nExpected','var')), nExpected=missing(); end
    
    if (ismissing(nInitial)), cumInitial=0; else cumInitial=cumsum(nInitial); end
    if (ismissing(delays))
        kMax=length(path2Files);
    else
        kMax=length(delays);
        if (length(path2Files)~=kMax)
            error("Inconsistent number of delays (%d) and paths where to find files (%d)!", ...
                kMax,length(path2Files));
        end
    end
    
    [ colNames, colUnits, colFacts, mapping, readFormat ] = ...
        GetColumnsAndMappingTFS("losses");
    
    losses=[];
    nTotLosses=0;
    for kk=1:kMax
        files=dir(path2Files(kk));
        for ii=1:length(files)
            lossesFileName=sprintf("%s\\%s",files(ii).folder,files(ii).name);
            fprintf("reading file %s ...\n",lossesFileName);
            fileID = fopen(lossesFileName,'r');
            tmpLosses = textscan(fileID,readFormat,'HeaderLines',8);
            fclose(fileID);
            if (~ismissing(delays))
                iCol=mapping(strcmpi(colNames,"TURN"));
                tmpLosses{iCol}=tmpLosses{iCol}+delays(kk);
            end
            if (cumInitial~=0 && ii>1)
                iCol=mapping(strcmpi(colNames,"NUMBER"));
                tmpLosses{iCol}=tmpLosses{iCol}+cumInitial(ii-1);
            end
            nLosses=length(tmpLosses{1});
            if (length(losses)==0)
                losses=tmpLosses;
            else
                for jj=1:size(losses,2)
                    losses{jj}(nTotLosses+1:nTotLosses+nLosses)=tmpLosses{jj};
                end
            end
            nTotLosses=nTotLosses+nLosses;
        end
    end
    fprintf("...acquired %u particle losses; \n",nTotLosses);
    
    if ( ~ismissing(nExpected) && nTotLosses>nExpected )
        warning('...something wrong: I was expecting at most %u points whereas I have parsed %u',nExpected,nTotLosses);
    end
end