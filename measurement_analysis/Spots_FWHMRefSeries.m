function FWHMout=Spots_FWHMRefSeries(FWHMin,relLev,absLev)
% Spots_FWHMRefSeries          to build numerical series representing
%                                reference values of FWHM, including
%                                tolerances (most stringent among relative
%                                and absolute ones);
% 
% input vars:
% - FWHMin (float([nPoints,nSeries,nCases])): FWHM values [mm] (geo mean);
% - relLev (float): relative tolerance on reference values [0:1];
% - absLev (float): absolute tolerance on reference values [mm;
%
% output vars:
% - FWHMout (float([nPoints,3,nCases])): ref FWHM values with tolerances [mm]:
%   . FWHMout(:,1,:): actual reference values;
%   . FWHMout(:,2,:): reference values + tolerance;
%   . FWHMout(:,3,:): reference values - tolerance;
%
% 
    if (~exist("relLev","var")), relLev=0.1; end % default: 10%
    if (~exist("absLev","var")), absLev=1.0; end % default: 1 mm
    % - reference FWHM
    if (size(FWHMin,2)==1)
        FWHMout=FWHMin;
    else
        FWHMout=mean(FWHMin,2);
    end
    % - tolerance around reference
    FWHMout(:,2,:)=min(FWHMout(:,1,:)*(1+relLev),FWHMout(:,1,:)+absLev);
    FWHMout(:,3,:)=max(FWHMout(:,1,:)*(1-relLev),FWHMout(:,1,:)-absLev);
end
