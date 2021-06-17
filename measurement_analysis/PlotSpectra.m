function PlotSpectra(dataSets,BaW,addIndex,addLabel)
% PlotSpectra     plots distributions/histograms in a 3D space with a free parameter;
%                 this plotting function can be useful to explore eg
%                   spectra taken during scans;
%                 NB: if you need to plot a subset... please give a proper
%                   subset of data as input!
%
% eg:
%      PlotSpectra(sumSFMData,false,cyProgs,"cyProgs");
%
% input:
% - dataSets [float(Nfibers,nColumns)]: array of data. The first column
%   stores the x-values, i.e. the values of the independent variable;
% - BaW [logical, optional]: use black and white color scale instead of the default one.
% - addIndex [float(nColumns-1), optional]: list of IDs to be shown;
%   it can be used to separate distribution by cyProg or cyCode;
% - addLabel [string, optional]: name of the y-axis;
%
% see also ParseSFMData, ShowSpectra and SumSpectra.
%
    nDataSets=size(dataSets,2)-1;
    if ( ~exist('BaW','var') )
        BaW=false;
    end
    if ( BaW )
        cm=gray(nDataSets);
    else
        cm=colormap(parula(nDataSets));
    end
    if ( ~exist('addIndex','var') )
        addIndex=1:nDataSets;
    end
    if ( ~exist('addLabel','var') )
        addLabel="ID";
    end
    for iSet=1:nDataSets
        PlotSpectrum(dataSets(:,1),dataSets(:,1+iSet),addIndex(iSet),cm(iSet,:));
        hold on;
    end
    ylabel(LabelMe(addLabel));
    grid on;
end

function PlotSpectrum(xx,yy,iSet,color)
% PlotSpectrum      function actually plotting a single distribution
%                   the distribution is plotted as a colored histogram in a 3D
%                   space, where the axes are:
%                   - X: independent var (e.g. fiber central positions);
%                   - Y: ID of the current distribution (e.g. cyProg);
%                   - Z: bin values;
% 
% input:
% - xx, yy [float(Nvalues)]: arrays of data (will be shown on the X and Z axis,
%   respectively);
%   NB: xx and yy must be row vectors, not column vectors!
% - iSet [integer]: index of the current data set (will be used as Y-coordinate);
% - color [float(3)]: RGB codification of color;
%
    plotX=xx;
    if ( size(plotX,2)== 1 )
        plotX=plotX';
    end
    plotY=yy;
    if ( size(plotY,2)== 1 )
        plotY=plotY';
    end
    % get non-zero values
    indices=(plotY~=0.0);
    plotX=plotX(indices);
    plotY=plotY(indices);
    nn=size(plotX,2);
    zz=iSet*ones(1,nn);
    fill3([plotX fliplr(plotX)],[zz zz],[plotY zeros(1,nn)],color,'FaceAlpha',0.3,'EdgeColor',color);
end


