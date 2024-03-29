function [profilesOUT,timesOUT]=BeamProfilesConcatenateTimes(profilesIN,timesIN)
% BeamProfilesConcatenateTimes      to concatenate beam profiles and time arrays
%                                     of beam frames acquired with BD devices
%                                     and CAMeretta dump as if only one
%                                     LONG extraction took place
%
% input variables:
% - profilesIN (float(nFibers,nTimeFrames+1,nPlanes,nDataSets)): acquired profiles;
% - timesIN (float(nTimeFrames,nDataSets)): time series (as read from files);
%
% output variables:
% - profilesOUT (float(nFibers,Sum_nTimeFrames+1,nPlanes)): acquired profiles;
% - timesOUT (float(Sum_nTimeFrames)): cumulative time series;
%
    fprintf("Concatenating time profiles (as if they all belonged to one extraction)...\n");
    nFibers=size(profilesIN,1);
    nPlanes=size(profilesIN,3);
    nDataSets=size(profilesIN,4);
    nActualFrames=0;
    profilesOUT=NaN(nFibers,1,nPlanes);
    profilesOUT(:,1,:)=profilesIN(:,1,:,1); % copy fiber position
    timesOUT=NaN();
    tLast=0;
    for iDataSet=1:nDataSets
        nLen=find(~isnan(timesIN(:,iDataSet)),1,"last"); % length of time array
        profilesOUT(:,nActualFrames+1+1:nActualFrames+1+nLen,:)=profilesIN(:,2:nLen+1,:,iDataSet);
        if (iDataSet>1 && timesIN(1,iDataSet)==0.0)
            % first time stamp of new acquisition is at 0.0: avoid having 
            %    2 profiles at the same time stamp
            tLast=tLast+diff(timesIN(1:2,iDataSet));
        end
        timesOUT(nActualFrames+1:nActualFrames+nLen)=timesIN(1:nLen,iDataSet)+tLast;
        nActualFrames=nActualFrames+nLen;
        tLast=timesOUT(nActualFrames);
    end
    timesOUT=timesOUT';
    fprintf("...done.\n");
end
