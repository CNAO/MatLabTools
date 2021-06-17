function [measData,cyCodes,cyProgs]=ParseSFMData(path2Files,fFormat)
% ParseSFMData     parses distributions recorded by SFM, QBM and GIM;
%                  for the time being, the function does not parse QIM data
%
% input:
% - path2Files [string]: path were files to be parsed are stored; it can be
%   a regexp, e.g. "PRC-544-210509-1437-Z2-021B-SFM\Data-*-*-Z2-021B-SFM.csv"
% - fFormat [string, optional]: detector that generated the data; this
%   parameter sets formats for reading data; default: SFM
%
% output:
% - measData [float(max(Nx,Ny),maxColumns,2,nDataSets)]: array of data;
%   . Nx,Ny: number of hor/ver fibers;
%   . maxColumns: number of time acquisitions + values of X (first column);
%   . 2: planes: 1: hor; 2: ver;
%   . nDataSets: number of files;
% - cyCodes [string(nDataSets,1)]: array of cycle codes;
% - cyProgs [float(nDataSets,1)]: array of cycle progs;
%
% see also SumSpectra, IntegrateSpectra and ShowSpectra.

    % default format: SFM data structure
    myFormat="SFM";
    Nx=64;         % number of horizontal fibers
    Ny=64;         % number of vertical fibers
    maxColumns=59; % number of time acquisitions + values of X (first column)
    
    if ( exist('fFormat','var') )
        % change data structure
        if ( strcmpi(fFormat,"QBM") )
            myFormat="QBM";
            Nx=34;
            Ny=45;
            maxColumns=59;
        elseif ( strcmpi(fFormat,"GIM") )
            myFormat="GIM";
            Nx=127;
            Ny=127;
            maxColumns=119;
        elseif ( ~strcmpi(fFormat,"SFM") )
            error("wrong indication of format of file: %s. Can only be SFM or QBM or GIM",fFormat);
        end
    end
    
    files=dir(path2Files);
    nDataSets=length(files);
    measData=zeros(max(Nx,Ny),maxColumns,2,nDataSets);
    cyProgs=zeros(nDataSets,1);
    cyCodes=strings(nDataSets,1);
    fprintf("acquring %i data sets...\n",nDataSets);
    if ( strcmp(myFormat,"SFM") )
        fprintf("...SFM format...\n");
    elseif ( strcmp(myFormat,"QBM") )
        fprintf("...QBM format...\n");
    elseif ( strcmp(myFormat,"GIM") )
        fprintf("...GIM format...\n");
    end
    
    for iSet=1:nDataSets
        if ( strcmpi(myFormat,"GIM") )
            if (strcmp(files(iSet).name,"Dati_SummaryGIM.txt"))
                % matlab does not support single char wildcard...
                continue
            end
            fprintf("...parsing folder %d/%d: %s ...\n",iSet,nDataSets,files(iSet).name);
            % x-axis values
            tmp=table2array(readtable(sprintf("%s\\%s\\%s",files(iSet).folder,files(iSet).name,"XProfiles.txt"),'HeaderLines',1,'MultipleDelimsAsOne',true));
            % actual number of columns in file (ie frames+1)
            nColumns=size(tmp,2);
            measData(1:Nx,1:nColumns,1,iSet)=tmp(1:Nx,1:nColumns); % values
            % y-axis values
            tmp=table2array(readtable(sprintf("%s\\%s\\%s",files(iSet).folder,files(iSet).name,"YProfiles.txt"),'HeaderLines',1,'MultipleDelimsAsOne',true));
            % actual number of columns in file (ie frames+1)
            nColumns=size(tmp,2);
            measData(1:Ny,1:nColumns,2,iSet)=tmp(1:Ny,1:nColumns); % values
            % store cycle code and cycle prog
            tmp=split(files(iSet).name,"_");
            cyProgs(iSet)=str2num(tmp{1});
            cyCodes(iSet)=tmp{2};
        else
            fprintf("...parsing file %d/%d: %s ...\n",iSet,nDataSets,files(iSet).name);
            tmp=table2array(readtable(sprintf("%s\\%s",files(iSet).folder,files(iSet).name),'HeaderLines',10,'MultipleDelimsAsOne',true));
            % actual number of columns in file (ie frames+1)
            nColumns=size(tmp,2);
            % x-axis values
            measData(1:Nx,1:nColumns,1,iSet)=tmp(1:Nx,1:nColumns); % values
            % y-axis values
            measData(1:Ny,1:nColumns,2,iSet)=tmp(Nx+2:end,1:nColumns); % values
            % store cycle code and cycle prog
            tmp=split(files(iSet).name,"-");
            cyProgs(iSet)=str2num(tmp{3});
            cyCodes(iSet)=tmp{2};
        end
    end
    fprintf("...acqured %i files;\n",size(measData,4));
end


