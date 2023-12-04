function ShowSeries(xVals,yVals,showXlabel,showYlabel,myLeg,myTitles,refY,refX,refLeg,pixY,pixX,pixLeg,nCoupled)
% ShowStuff      to display data series (xVals,yVals) as several plots in a single figure
%
% NOTA BENE:
% - size(xVals)=size(yVals) (NOT CHECKED YET!)
% - number of points in each plotted series: size(xVals,1)=size(yVals,1);
% - number of series per plot: size(xVals,2)=size(yVals,2);
% - number of plots per figure: size(xVals,3)=size(yVals,3);
% - ref data can be:
%   . unique for all plots or a dedicated one for each plot -- size(refY,3);
%   . for each plot, a unique series (black) or a few (the first one black, the others grey) -- size(refY,2);
% - pix data can be:
%   . unique for all plots or a dedicated one for each plot -- size(pixY,3);
%   . for each plot, up to three series (squared magenta, pentagrammed cyan and hexagram green) -- size(pixY,2);

    if (~exist("myTitles","var")), myTitles=missing(); end
    if (~exist("refY","var")), refY=missing(); end
    if (~exist("refX","var")), refX=missing(); end
    if (~exist("refLeg","var")), refLeg=missing(); end
    if (~exist("pixY","var")), pixY=missing(); end
    if (~exist("pixX","var")), pixX=missing(); end
    if (~exist("pixLeg","var")), pixLeg=missing(); end
    if (~exist("nCoupled","var")), nCoupled=1; end
    nSets=size(yVals,2);
    nShows=size(yVals,3);
    nPlotsLegendThresh=10; % max number of subplots before having a dedicated one for the legend
    nSeriesLegendThresh=10; % max number of series before having a dedicated one for the legend

    figure();
    % - set markers
    if ( nSets==2 )
        markers=[ "o" "*" ];
        cm=[1 0 0 ; 0 0 1]; % red and blue
    else
        markers=strings(nSets,1);  markers(:)=".";
        cm=colormap(parula(nSets));
    end
    if (~ismissing(refY))
        refMarkers=strings(size(refY,2),1); refMarkers(:)="-";
        refColors=NaN(size(refY,2),3); refColors(1,:)=[0 0 0];
        if (size(refY,2)>1), refColors(2:end,:)=repmat([0.7 0.7 0.7],[size(refColors,1)-1 1]); end
    end
    if (~ismissing(pixY))
        if ( size(pixY,2)<=3 )
            pixMarkers=[ "square" "pentagram" "hexagram" ];
            pixCm=[1 0 1 ; 0 1 1 ; 0 1 0]; % magenta, cyan and green
        else
            pixMarkers=strings(size(pixY,2),1);  pixMarkers(:)="*";
            pixCm=colormap(jet(size(pixY,2)));
        end
    end
    % - legend
    tmpLeg=[];
    if (all(~ismissing(refLeg)))
        tmpLeg=refLeg;
    end
    if (all(~ismissing(myLeg)))
        tmpLeg=[tmpLeg myLeg];
    end
    if (all(~ismissing(pixLeg)))
        tmpLeg=[tmpLeg pixLeg];
    end
    nLeg=length(tmpLeg);
    % - set grid of plots
    nPlots=nShows;
    if (~isempty(tmpLeg) && ( nShows>nPlotsLegendThresh || nLeg>nSeriesLegendThresh ) ), nPlots=nPlots+1; end
    [nRows,nCols]=GetNrowsNcols(nPlots,nCoupled);
    % - actually plot
    for iPlot=1:nShows
        axs(iPlot)=subplot(nRows,nCols,iPlot);
        lFirst=true;
        if (~ismissing(refY))
            for jRef=1:size(refY,2)
                if (lFirst), lFirst=false; else, hold on; end
                if (size(refX,2)==1), jX=1; else, jX=jRef; end
                if (size(refX,3)==1), kX=1; else, kX=iPlot; end
                if (size(refY,2)==1), jY=1; else, jY=jRef; end
                if (size(refY,3)==1), kY=1; else, kY=iPlot; end
                plot(refX(:,jX,kX),refY(:,jY,kY),refMarkers(jRef),"Color",refColors(jRef,:));
            end
            lFirst=false;
        end
        for iSet=1:nSets
            if (lFirst), lFirst=false; else, hold on; end
            if (size(xVals,2)==1), jX=1; else, jX=iSet; end
            if (size(xVals,3)==1), kX=1; else, kX=iPlot; end
            plot(xVals(:,jX,kX),yVals(:,iSet,iPlot),"-","Marker",markers(iSet),"Color",cm(iSet,:));
        end
        if (~ismissing(pixY))
            for jPix=1:size(pixY,2)
                if (lFirst), lFirst=false; else, hold on; end
                if (size(pixX,2)==1), jX=1; else, jX=jPix; end
                if (size(pixX,3)==1), kX=1; else, kX=iPlot; end
                if (size(pixY,2)==1), jY=1; else, jY=jPix; end
                if (size(pixY,3)==1), kY=1; else, kY=iPlot; end
                plot(pixX(:,jX,kX),pixY(:,jY,kY),"LineStyle","--","Marker",pixMarkers(jPix),"Color",pixCm(jPix,:));
            end
            lFirst=false;
        end
        if (length(showXlabel)==nShows), iX=iPlot; else, iX=1; end; xlabel(showXlabel(iX));
        if (length(showYlabel)==nShows), iY=iPlot; else, iY=1; end; ylabel(showYlabel(iY));
        grid on;
        if (all(~ismissing(myTitles))), title(myTitles(iPlot)); end
        if (~isempty(tmpLeg) && ( nPlots<=nPlotsLegendThresh && nLeg<=nSeriesLegendThresh ) ), legend(tmpLeg); end
    end
    % - legend plot
    if (~isempty(tmpLeg) && ( nPlots>nPlotsLegendThresh || nLeg>nSeriesLegendThresh ) )
        subplot(nRows,nCols,nPlots);
        lFirst=true;
        if (all(~ismissing(refLeg)))
            for jRef=1:size(refY,2)
                if (lFirst), lFirst=false; else, hold on; end
                plot(NaN(),NaN(),refMarkers(jRef),"Color",refColors(jRef,:));
            end
            lFirst=false;
        end
        for iSet=1:nSets
            if (lFirst), lFirst=false; else, hold on; end
            plot(NaN(),NaN(),"-","Marker",markers(iSet),"Color",cm(iSet,:));
        end
        if (all(~ismissing(pixLeg)))
            for jPix=1:size(pixY,2)
                if (lFirst), lFirst=false; else, hold on; end
                plot(NaN(),NaN(),"LineStyle","--","Marker",pixMarkers(jPix),"Color",pixCm(jPix,:));
            end
            lFirst=false;
        end
        legend(tmpLeg,"Location","best"); title("legend");
    end
    % - general stuff
    if (all(~ismissing(myTitles)))
        if (length(myTitles)>nShows), sgtitle(myTitles(end)); end
    end
    % linkaxes(axs,"xy");
end
