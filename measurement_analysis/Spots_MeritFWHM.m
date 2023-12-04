function [FWHMgeoMean,ASYMs]=Spots_MeritFWHM(FWHMin)
% Spots_MeritFWHM       to calculate some figures of merit of spot sizes
%
% input vars:
% - FWHMin (float([nPoints,nPlanes,nSeries])): FWHM values [mm];
%
% output vars:
% - FWHMout (float([nPoints,nSeries])): geo mean FWHM values over planes [mm];
% - ASYMs (float([nPoints,nSeries])): FWHM_y-FWHM_x values [mm];
%
    % - geo mean FWHM
    FWHMgeoMean=sqrt(FWHMin(:,1,:).*FWHMin(:,2,:));
    FWHMgeoMean=reshape(FWHMgeoMean,[size(FWHMgeoMean,1),size(FWHMgeoMean,3)]);
    % - xy-asymmetry
    ASYMs=FWHMin(:,2,:)-FWHMin(:,1,:);
    ASYMs=reshape(ASYMs,[size(ASYMs,1),size(ASYMs,3)]);
end
