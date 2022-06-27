function ShowBeamProfilesSummaryData(BARs,SIGs,INTs,ASYMs,indices,labels,whatNames,myTitle)
% ShowBeamProfilesSummaryData      to create a figure where Baricentres, SIGmas/FWHMs,
%                                   INTegrals and ASYMmetries of beam
%                                   profiles are shown;
% 
% in case of multiple data sets, they are compared.
% 
% the function creates a stand-alone figure with 2x3(4) plots (hor/ver x
% SIG/BAR/INT(/ASYM)), comparing the various quantities;
% 
% input:
% - BARs (float(nScanPoints,nPlanes,nSets)): baricentres of distributions [mm];
% - SIGs (float(nScanPoints,nPlanes,nSets)): sigmas of distributions [mm];
% - INTs (float(nScanPoints,nPlanes,nSets)): integrals of distributions [mm];
% - ASYMs (float(nScanPoints,nPlanes,nSets), can be missing): asymmetry [mm];
% - indices ([IDmin IDmax], optional): IDs of the scan points to be taken;
% - labels (strings(nSets)): a label for each scan;
% - whatNames (strings(nCols)): a label for each quantity;
% - myTitle (string): figure title;
% 

    if ( ~exist('indices','var') ), indices=missing(); end
    if ( ~exist('labels','var') ), labels=missing(); end
    if ( ~exist('whatNames','var') ), whatNames=missing(); end
    
    nCols=3; % SIGs, BARs, INTs
    if ( ~ismissing(ASYMs) ), nCols=4; end
    planes=["Hor" "Ver"];
    nRows=length(planes); % Hor, Ver
    nSets=size(INTs,3);

    if ( ismissing(indices) )
        iis=1:size(INTs,1)';
    else
        iis=(indices(1):indices(2))';
    end
    if ( ismissing(labels) )
        labels=compose("Series %02i",(1:nSets)');
    end
    if ( ismissing(whatNames) )
        whatNames=["FWHM" "BAR" "INT" "ASYM"];
    end
    
    % actually generate figure
    if (exist("myTitle","var"))
        figure("Name",LabelMe(myTitle));
    else
        figure();
    end
    iPlot=0;
    if ( nSets==2 )
        markers=[ "o" "*" ];
    else
        markers=strings(nSets,1);
        markers="*";
    end
    for iRow=1:nRows
        for iCol=1:nCols
            iPlot=iPlot+1;
            subplot(nRows,nCols,iPlot);
            switch iCol
                case 1
                    what=SIGs; myYLab="[mm]";
                case 2
                    what=BARs; myYLab="[mm]";
                case 3
                    what=INTs; myYLab="[]";
                case 4
                    what=ASYMs; myYLab="[mm]";
            end
            for iSet=1:nSets
                if ( iSet>1 ), hold on; end
                plot(iis,what(iis,iRow,iSet),"-","Marker",markers(iSet));
            end
            xlabel("ID []"); ylabel(myYLab); grid on; title(sprintf("%s - %s",planes(iRow),whatNames(iCol)));
            legend(labels,"location","best");
        end
    end
    
    if (exist("myTitle","var"))
        sgtitle(LabelMe(myTitle));
    end
    
end