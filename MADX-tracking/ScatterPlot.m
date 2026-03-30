function ScatterPlot(data,indices,xNAMEs,yNAMEs,whichData,currTitle,InitialCoords,recogParamName,rPrec)
% ScatterPlot  Prepare scatter plots
%
% The user decides what to show
%
% ScatterPlot(data,indices,xNAMEs,yNAMEs,whichData,currTitle)
%
% input arguments:
%   data: table with particle coordinates;
%   indices: index of particles to be plotted (eg to apply some filtering);
%   xNAMEs, yNAMEs: names of the quantity to be plotted:
%   whichData: format of the table;
%   currTitle: title of the plot;
%   InitialCoords (optional): initial coordinates of particles;
%   recogParamName (optional): name of parameter which should be used to
%         recognise/label initial conditions;
%   rPrec: precision in recognising a given value of recogParamName;
% 
% The presence of the InitialCoords, recogParamName and rPrec (~missing())
%   triggers the recognition mode, i.e. points in the scatter plot are
%   correlated to unique values of recogParamName;
%
% See also GetVariablesAndMapping.

    if ( length(xNAMEs)~=length(yNAMEs) )
        error('...number of x-axes different from number of y-axes!');
    end
    if (~exist("InitialCoords","var")), InitialCoords=missing(); end
    if (~exist("recogParamName","var")), recogParamName=missing(); end
    if (~exist("rPrec","var")), rPrec=missing(); end
    if (all(ismissing(InitialCoords),"all") & all(ismissing(recogParamName),"all") & all(ismissing(rPrec),"all") )
        lRecog=false;
    else
        lRecog=true;
    end
    if (lRecog && ismissing(recogParamName))
        recogParamName="S";
    end
    if (lRecog && ismissing(rPrec))
        rPrec=1E-3;
    end
    [nRows,nCols]=GetNrowsNcols(length(xNAMEs));
    
    [ colNames, colUnits, colFacts, mapping ] = GetColumnsAndMappingTFS(whichData);
    if (lRecog)
        [ colNamesStart, colUnitsStart, colFactsStart, mappingStart ] = GetColumnsAndMappingTFS("starting");
        [uVals,ia,~]=unique(data{mapping(strcmpi(colNames,recogParamName))}); % unique loss locations
        uNames=strrep(string(data{mapping(strcmpi(colNames,"ELEMENT"))}(ia)),'"',""); % corresponding names
        nUniques=length(uVals);
    end

    actualTitle=sprintf('%s - Scatter plot - %s',whichData,currTitle);
    ff=figure('Name',actualTitle,'NumberTitle','off');
    if (lRecog), cm=colormap(parula(nUniques)); end
    for ii=1:length(xNAMEs)
        axt=subplot(nRows,nCols,ii);
        if (lRecog)
            iColX=mappingStart(strcmpi(colNamesStart,xNAMEs(ii)));
            iColY=mappingStart(strcmpi(colNamesStart,yNAMEs(ii)));
            % - starting conditions
            if (iscell(InitialCoords))
                plot(InitialCoords{iColX}*colFactsStart(iColX),InitialCoords{iColY}*colFactsStart(iColY),'k.');
            else
                plot(InitialCoords(:,iColX)*colFactsStart(iColX),InitialCoords(:,iColY)*colFactsStart(iColY),'k.');
            end
            % - labelling
            for jj=1:nUniques
                uMin=uVals(jj)-rPrec; uMax=uVals(jj)+rPrec;
                indeces=(uMin<=data{mapping(strcmpi(colNames,recogParamName))} & data{mapping(strcmpi(colNames,recogParamName))}<=uMax);
                IDs=data{mapping(strcmpi(colNames,"NUMBER"))}(indeces);
                hold on;
                if (iscell(InitialCoords))
                    plot(InitialCoords{iColX}(IDs)*colFactsStart(iColX),InitialCoords{iColY}(IDs)*colFactsStart(iColY),'.',"Color",cm(jj,:));
                else
                    plot(InitialCoords(IDs,iColX)*colFactsStart(iColX),InitialCoords(IDs,iColY)*colFactsStart(iColY),'.',"Color",cm(jj,:));
                end
            end
            xlabel(sprintf('%s [%s]',colNamesStart(iColX),colUnitsStart(iColX)));
            ylabel(sprintf('%s [%s]',colNamesStart(iColY),colUnitsStart(iColY)));
        else
            iColX=mapping(strcmpi(colNames,xNAMEs(ii)));
            iColY=mapping(strcmpi(colNames,yNAMEs(ii)));
            if (ismissing(indices))
                if (iscell(data))
                    plot(data{iColX}*colFacts(iColX),data{iColY}*colFacts(iColY),'r.');
                else
                    plot(data(:,iColX)*colFacts(iColX),data(:,iColY)*colFacts(iColY),'r.');
                end
            else
                if (iscell(data))
                    plot(data{iColX}(indices)*colFacts(iColX),data{iColY}(indices)*colFacts(iColY),'r.');
                else
                    plot(data(indices,iColX)*colFacts(iColX),data(indices,iColY)*colFacts(iColY),'r.');
                end
            end
            xlabel(sprintf('%s [%s]',colNames(iColX),colUnits(iColX)));
            ylabel(sprintf('%s [%s]',colNames(iColY),colUnits(iColY)));
        end
        grid on;
    end
    sgtitle(actualTitle);
end