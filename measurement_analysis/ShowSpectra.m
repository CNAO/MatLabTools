function ShowSpectra(dataSets,tmpTitleFig,addIndex,addLabel)
% ShowSpectra     shows distributions recorded by SFM, QBM and GIM;
%                 it shows a 2x1 3D figure, with the distributions on the
%                   horizontal plane on the left and those on the vertical
%                   plane on the right;
%                 both raw data from monitors and total distributions can
%                   be plotted.
%                 NB: if you need to plot a subset... please give a proper
%                   subset of data as input!
%
% eg:
%      ShowSpectra(sumSFMData,"Run2-Carbonio",cyProgs,"cyProgs");
%
% input:
% - dataSets [float(Nfibers,nColumns,2)]: array of data. See also
%   ParseSFMData and SumSpectra for more info;
% - tmpTitleFig [string]: title of plot. It will be used for both the
%   window and the plot title;
% - addIndex [float(nColumns-1), optional]: list of IDs to be shown;
%   it can be used to separate distribution by cyProg or cyCode;
% - addLabel [string, optional]: name of the y-axis;
%
% see also ParseSFMData, PlotSpectra and SumSpectra.

    fprintf("plotting data...\n");
    ff=figure('Name',LabelMe(tmpTitleFig),'NumberTitle','off');
    BaW=false;
    
    % hor distribution
    subplot(1,2,1);
    if ( ~exist('addIndex','var') & ~exist('addLabel','var') )
        PlotSpectra(dataSets(:,:,1));
    else
        PlotSpectra(dataSets(:,:,1),BaW,addIndex,addLabel);
    end
    title("horizontal plane");
    xlabel("position [mm]");
    zlabel("Counts []");

    % ver distribution
    subplot(1,2,2);
    tmpTitle="vertical plane";
    if ( ~exist('addIndex','var') & ~exist('addLabel','var') )
        PlotSpectra(dataSets(:,:,2));
    else
        PlotSpectra(dataSets(:,:,2),BaW,addIndex,addLabel);
    end
    title("vertical plane");
    xlabel("position [mm]");
    zlabel("Counts []");
    
    % global
    sgtitle(LabelMe(tmpTitleFig));
end


