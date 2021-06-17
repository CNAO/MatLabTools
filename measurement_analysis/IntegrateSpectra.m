function integrals=IntegrateSpectra(data,fFormat)
% IntegrateSpectra     computes the integral of distributions recorded by SFM, QBM and GIM;
%
% input:
% - data [float(Nn,nDataSets,2(,nDataSets))]: array of data;
%        can be either the raw data or the sum distributions;
% - fFormat [string]: format of input array;
%   . SUM (default): data has the structure of a series of sum distributions;
%   . RAW: data has the structure of the raw data;
% 
% output:
% - integrals [float(nDataSets,2)]: array of integrals;
%   . nDataSets: number of dataSets;
%   . 2: planes: 1: hor; 2: ver;
%
% see also ParseSFMData and SumSpectra.
    fprintf("computing integrals...\n");
    if ( ~exist('fFormat','var') )
        fFormat="SUM";
    end
    if ( strcmpi(fFormat,"SUM") )
        nDataSets=size(data,2)-1;
        integrals=zeros(nDataSets,2);
        for iSet=1:nDataSets
            integrals(iSet,:)=sum(data(:,iSet+1,:),1);
        end
    elseif ( strcmpi(fFormat,"RAW") )
        nDataSets=size(data,4);
        integrals=zeros(nDataSets,2);
        for iSet=1:nDataSets
            integrals(iSet,:)=sum(data(:,2:end,:,iSet),[1 2]);
        end
    else
        error("wrong indication of format of data: %s. Can only be RAW or SUM",fFormat);
    end
end


