function [hh,cc]=ShowLossMap(losses,indices,dS,geometry,allAperH,allAperV,lSupImp,lHist)
% ShowLossMap     embed the longitudinal distribution of losses (histogram)
%                   into a nice plot, possibly with lattice structure and
%                   aperture model
%
% [hh,cc] = ShowLossMap(losses,indices,dS,geometry,allAperH,allAperV)
%
% input arguments:
%   losses: table of losses.  For the format of the table, please see
%                 GetVariablesAndMappingParticleData
%   indices: index of particles to be plotted (eg to apply some filtering);
%
% optional input arguments:
%   dS:   bin width [m];
%   geometry: (thick) lens lattice;
%   allAperH: horizontal aperture model;
%   allAperV: vertical aperture model;
%   lSupImp: superimpose loss coordinates to aperture plot (boolean);
%   lHist: compute longitudinal histogram of losses (boolean);
%          otherwise, simply return loss counts;
%
% output arguments:
%   hh:  histogram counts;
%   cc:  histogram edges;
%
% See also ReadLosses, GetVariablesAndMappingParticleData, PlotLossMap,
%                       GetColumnsAndMappingTFS, PlotLattice, PlotAperture.

    if (~exist("lSupImp","var")), lSupImp=true; end
    if (~exist("lHist","var")), lHist=true; end

    nPlots=1;
    if ( exist('geometry','var') )
        nPlots=nPlots+1;
        % column mapping
        [ colNames, colUnits, colFacts, mapping, readFormat ] = ...
            GetColumnsAndMappingTFS('geometry');
        colS=mapping(find(strcmp(colNames,'S')));
        colL=mapping(find(strcmp(colNames,'L')));
        maxS=max(geometry{colS})+geometry{colL}(end);
        minS=min(geometry{colS});
    else
        maxS=max(losses{9});
        minS=min(losses{9});
    end
    % column mapping of particle losses
    [ colNames, colUnits, colFacts, mapping ] = ...
                             GetVariablesAndMappingParticleData('losses');
    colS=mapping(find(strcmp(colNames,'s')));
    colX=mapping(find(strcmp(colNames,'x')));
    colY=mapping(find(strcmp(colNames,'y')));
    if ( exist('allAperH','var') )
        nPlots=nPlots+1;
    end
    if ( exist('allAperV','var') )
        nPlots=nPlots+1;
    end
    dsUsr=0.1; % [m]
    if ( exist('dS','var') )
        dsUsr=dS;
    end

    axs=[];
    iPlot=0;
    
    % lattice plot
    if ( exist('geometry','var') )
        iPlot=iPlot+1;
        tmpAx=subplot(nPlots,1,iPlot);
        axs=[ axs tmpAx ];
        PlotLattice(geometry);
    end

    % losses on horizontal plane
    if ( exist('allAperH','var') )
        iPlot=iPlot+1;
        tmpAx=subplot(nPlots,1,iPlot);
        axs=[ axs tmpAx ];
        PlotAperture(allAperH{1},allAperH{2},allAperH{3},allAperH{4},allAperH{5});
        if (lSupImp)
            hold on;
            % losses
            if (ismissing(indices))
                plot(losses{colS},losses{colX},'r.');
            else
                plot(losses{colS}(indices),losses{colX}(indices),'r.');
            end
        end
        title(sprintf('H plane')); grid on;
        xlim([minS maxS]);
    end
    
    % losses on vertical plane
    if ( exist('allAperV','var') )
        iPlot=iPlot+1;
        tmpAx=subplot(nPlots,1,iPlot);
        axs=[ axs tmpAx ];
        PlotAperture(allAperV{1},allAperV{2},allAperV{3},allAperV{4},allAperV{5});
        if (lSupImp)
            hold on;
            % losses
            if (ismissing(indices))
                plot(losses{colS},losses{colY},'r.');
            else
                plot(losses{colS}(indices),losses{colY}(indices),'r.');
            end
        end
        title(sprintf('V plane')); grid on;
        xlim([minS maxS]);
    end
    
    % histogram of losses
    iPlot=iPlot+1;
    tmpAx=subplot(nPlots,1,iPlot);
    axs=[ axs tmpAx ];
    [hh,cc] = PlotLossMap(losses,indices,dsUsr,maxS,minS,lHist);
    set(tmpAx, 'YScale', 'log');
    % manual treatment of yticklabels...
    % set(tmpAx, 'YTick', [min(ylim):10:max(ylim)]);
    tmpAx.YGrid = 'on';
    % tmpAx.YMinorGrid = 'on';
    yMin=floor(min(log10(ylim)));
    yMax=ceil(max(log10(ylim)));
    ylim([10^yMin 10^yMax]);
    yticks(10.^[yMin:1:yMax]);
    yticklabels(cellstr(num2str([yMin:1:yMax], '10^{%d}\n')));
    
    % additionals
    if ( nPlots>1 )
        linkaxes(axs,'x');
    end
    title(sprintf('Losses'));

end