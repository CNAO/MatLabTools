function [BARs,FWHMs,INTs]=StatDistributionsCAMProcedure(profiles,FWHMval,noiseLevelBAR,noiseLevelFWHM,INTlevel,lDebug)
% StatDistributionsCAMProcedure      to compute basic statistical infos of
%                                       distributions recorded by the
%                                       CAMeretta;
% 
% input:
% - profiles (2D float array): signals to process:
%   . rows: index of independent coordinate (e.g. time/position);
%   . columns: index of the signal to process;
%   NB: column 1 is the list of values of the independent variable;
% - FWHMval (scalar): value (ratio to max) at which the FW should be computed
%     (either as percentage or as ratio to 1); default: 50% (FWHM);
% - noiseLevelBAR (scalar): cut threshold for computing BARicentre
%     (either as percentage or as ratio to 1); default: 5%;
% - noiseLevelFWHM (scalar): cut threshold for computing FWHM
%     (either as percentage or as ratio to 1); default: 20%;
% - INTlevel (scalar): min value of integral above which a profile should be
%     considered for analisis; default: 20k;
% - lDebug (boolean): activate debug mode (for the time being, plots);
%
% output:
% - BARs (2D float array): BARicenters of distributions;
% - FWHMs (2D float array): FWxMs of distributions;
% - INTs (2D float array): integrals of distributions (no filters!);
% NB: rows/columns of the the output arrays have the following meaning:
%   . row: index of data set;
%   . columns: plane (1:HOR; 2:VER);
%

    % default values
    if ( ~exist('FWHMval','var') ), FWHMval=0.50; end
    if ( ~exist('noiseLevelBAR','var') ), noiseLevelBAR=0.05; end
    if ( ~exist('noiseLevelFWHM','var') ), noiseLevelFWHM=0.20; end
    if ( ~exist('INTlevel','var') ), INTlevel=20000; end
    if ( ~exist('lDebug','var') ), lDebug=true; end
    
    fprintf("computing BARs and FWHMs as done for CAMeretta...\n");
    % if >1, levels are assumed in percentage
    if ( noiseLevelBAR>1 ), noiseLevelBAR=noiseLevelBAR*1.0E-2; end 
    if ( noiseLevelFWHM>1 ), noiseLevelFWHM=noiseLevelFWHM*1.0E-2; end
    if ( FWHMval>1 ), FWHMval=FWHMval*1.0E-2; end
    if ( FWHMval<noiseLevelFWHM ), FWHMval=noiseLevelFWHM; end
    
    % initialise vars
    nDataSets=size(profiles,2)-1; % let's crunch only sum profiles;
    BARs=NaN(nDataSets,2);  % hor,ver BARs
    FWHMs=NaN(nDataSets,2); % hor,ver FWHMs
    INTs=NaN(nDataSets,2); % hor,ver INTs
    
    % loop over profiles
    planes=[ "hor" "ver" ];
    if ( lDebug ), ff=figure(); end
    for iSet=1:nDataSets
        tmpXs(:,1:2)=profiles(:,1,:);      % (nFibers,2)
        tmpYs(:,1:2)=profiles(:,1+iSet,:); % (nFibers,2)
        tmpINTs=sum(tmpYs,"omitnan");
        if ( sum(tmpINTs,"omitnan")<= 1000 ), continue; end
        if ( lDebug ), sgtitle(sprintf("CAMeretta profiles id #%d",iSet)); end
        % INTs
        INTs(iSet,1:2)=tmpINTs; % take as integral the counts on the entire profile
        % BARs
        indices=CleanProfiles(tmpYs,noiseLevelBAR);
        for iPlane=1:2
            myXs=tmpXs(indices(:,iPlane),iPlane);
            myYs=tmpYs(indices(:,iPlane),iPlane);
            norm=sum(myYs);
            if ( norm>0 )
                BARs(iSet,iPlane)=sum(myXs.*myYs)/norm;
            end
        end
        % FWHMs
        indices=CleanProfiles(tmpYs,noiseLevelFWHM);
        for iPlane=1:2
            if ( lDebug ), subplot(1,2,iPlane); end
            nPoints=sum(indices(:,iPlane));
            % default values, in case fitting does not proceed
            tmpIndices=tmpYs(:,iPlane)>0;
            FWHMleft=min(tmpXs(tmpIndices,iPlane));
            FWHMright=max(tmpXs(tmpIndices,iPlane));
            FWHMs(iSet,iPlane)=0.0;
            myXs=tmpXs(:,iPlane); myYs=0.0*myXs; repYs=0.0*myXs; 
            FWHMvalAbs=0.0; tmpMax=0.0;
            if ( nPoints==sum(tmpYs(:,iPlane)>0) & INTs(iSet,iPlane)<INTlevel)
                warning("...cannot actually identify a bell-shaped profile!");
                [tmpMax,idMax]=max(tmpYs(:,iPlane));
                FWHMvalAbs=FWHMval*tmpMax;
            else
                if ( nPoints<3 )
                    warning("...not enough points for fitting data for computing FWHM on %s plane for data set %d! skipping...",planes(iPlane),iSet);
                else
                    nOrder=6; % max order of polynom
                    if ( nPoints<7 ), nOrder=nPoints-1; end % reduce polynom order if there are not enough points...
                    myXs=tmpXs(indices(:,iPlane),iPlane);
                    myYs=tmpYs(indices(:,iPlane),iPlane);
                    pp=polyfit(myXs,myYs,nOrder);
                    repYs=polyval(pp,myXs);
                    [tmpMax,idMax]=max(repYs);
                    FWHMvalAbs=FWHMval*tmpMax;
                    if ( idMax==1 | idMax==length(repYs) )
                        warning("...not enough points for finding width on one of the two sides of profile on %s plane for data set %d! skipping...",planes(iPlane),iSet);
                    elseif ( all(abs(pp(1:end-1))<2E-14) )
                        warning("...flat profile!");
                    else
                        FWHMleft=interp1(repYs(1:idMax),myXs(1:idMax),FWHMvalAbs);
                        FWHMright=interp1(repYs(idMax:end),myXs(idMax:end),FWHMvalAbs);
                        FWHMs(iSet,iPlane)=FWHMright-FWHMleft;
                    end
                end
            end
            if ( lDebug )
                plot(tmpXs(:,iPlane),tmpYs(:,iPlane),"o", ...                       % original signal
                     myXs,myYs,"*",myXs,repYs,".-", ...                             % filtered signal and interpolated signal
                     [FWHMleft FWHMright],[FWHMvalAbs FWHMvalAbs],"k-",...          % FWxM
                     [BARs(iSet,iPlane) BARs(iSet,iPlane)], [0.0 1.1*tmpMax],"k-"); % BAR
                title(sprintf("%s plane",planes(iPlane))); grid on; xlabel("fiber position [mm]"); ylabel("counts []");
            end
        end
        if ( lDebug ), pause(0.1); end
    end
    fprintf("...done.\n");
end
