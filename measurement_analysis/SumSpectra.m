function sumData=SumSpectra(data)
% SumSpectra     computes the distribution sum of those recorded by SFM, QBM and GIM;
%
% input:
% - data [float(max(Nx,Ny),maxColumns,2,nDataSets)]: array of data. See ParseSFMData
%   for further info on formats;
% 
% output:
% - sumData [float(Nn,nDataSets+1,2)]: array of data;
%   . Nn: number of fibers;
%   . nDataSets: number of files; the second dimension of the array
%     also contains the values of x/y in the first column;
%   . 2: planes: 1: hor; 2: ver;
%
% see also ParseSFMData and IntegrateSpectra.

    fprintf("computing sums...\n");
    Nn=size(data,1);
    nDataSets=size(data,4);
    sumData=zeros(Nn,nDataSets+1,2);
    
    sumData(:,1,:)=data(:,1,:,1); % copy positions of fibers on both planes from first data set
    for iSet=1:nDataSets
        % get total distribution for each data set
        sumData(:,iSet+1,:)=sum(data(:,2:end,:,iSet),2);
    end
end



