function LGENvisualCheck(psNames,xVals,xLab,yVals,yLab,magNames,myTitle,myLegend,magNames2show)
    if (~exist("myTitle","var") || strlength(myTitle)==0 ), myTitle=missing(); end
    if (~exist("myLegend","var")), myLegend=missing(); end
    if (exist("magNames2show","var"))
        switch upper(magNames2show)
            case {"QUE","QUES","QUADRUPOLES"}
                magNames2show=unique(magNames(contains(magNames,"QUE")));
                if (~ismissing(myTitle)), myTitle=strcat(myTitle," - only QUEs"); end
            case {"CEB","CEBS","CORRECTORS"}
                magNames2show=unique(magNames(contains(magNames,"CEB")));
                if (~ismissing(myTitle)), myTitle=strcat(myTitle," - only CEBs"); end
            case {"DIP","DIPS","DIPOLES"}
                magNames2show=unique(magNames(contains(magNames,"SWH")|contains(magNames,"MBS")|contains(magNames,"SW2")));
                if (~ismissing(myTitle)), myTitle=strcat(myTitle," - only MAIN DIPOLEs"); end
        end
    else
        magNames2show=unique(magNames(~ismissing(magNames))); % default: do not filter
    end
    nMagnets=size(magNames2show,1);
    nSets=size(magNames,2);

    figure();
    cm=colormap(turbo(nSets));
    % - set grid of plots
    nPlots=nMagnets;
    if (~ismissing(myLegend)), nPlots=nPlots+1; end
    [nRows,nCols]=GetNrowsNcols(nPlots);
    % - set markers
    if ( nSets==2 )
        markers=[ "o" "*" ];
    else
        markers=strings(nSets,1);
        markers(:)=".";
    end
    % - actually plot
    for iMagnet=1:nMagnets
        subplot(nRows,nCols,iMagnet);
        lFirst=true;
        for iSet=1:nSets
            jj=find(strcmp(magNames(:,iSet),magNames2show(iMagnet)));
            if ( isempty(jj) )
                warning("...unable to find LGEN %s in list of PS names!",magNames2show(iMagnet));
                continue
            end
            if (lFirst), lFirst=false; else, hold on; end
            [~,IDs]=sort(xVals(:,iSet));
            plot(xVals(IDs,iSet),yVals(IDs,jj,iSet),"-","Marker",markers(iSet),"Color",cm(iSet,:));
        end
        xlabel(xLab); ylabel(yLab); grid on;
        title(sprintf("%s (aka %s)",magNames2show(iMagnet),psNames(jj,iSet)));
    end
    % - legend plot
    if (~ismissing(myLegend))
        subplot(nRows,nCols,nPlots);
        lFirst=true;
        for iSet=1:nSets
            if (lFirst), lFirst=false; else, hold on; end
            plot(NaN(),NaN(),"-","Marker",markers(iSet),"Color",cm(iSet,:));
        end
        legend(myLegend);
    end
    % - general stuff
    if (~ismissing(myTitle)), sgtitle(myTitle); end
    
end
