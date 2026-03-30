function [hh,cc] = PlotLossMap(losses,indices,dS,maxS,minS,lHist,Nbins)
% PlotLossMap     plot the longitudinal distribution of losses (histogram)
%
% Nota bene: the function does not create a figure or a subplot, they
% should be created beforehand;
%
% [hh,cc] = PlotLossMap(losses,indices,dS,maxS,minS,lHist,Nbins)
%
% input arguments:
%   losses: table of losses. For the format of the table, please see
%                 GetVariablesAndMappingParticleData
%   indices: index of particles to be plotted (eg to apply some filtering);
%
% optional input arguments:
%   dS:   bin width [m];
%   maxS: max value of s-coordinate [m];
%   minS: min value of s-coordinate [m];
%   lHist: compute longitudinal histogram of losses (boolean);
%          otherwise, simply return loss counts;
%   Nbins: number of bins;
%
% output arguments:
%   hh:  histogram counts;
%   cc:  histogram edges;
%
% See also ReadLosses, ShowLossMap, GetVariablesAndMappingParticleData.

    dsUsr=0.1; % [m]
    if ( exist('dS','var') )
        dsUsr=dS;
    end
    maxSUsr=max(losses{9});
    if ( exist('maxS','var') )
        maxSUsr=maxS;
    end
    minSUsr=min(losses{9});
    if ( exist('minS','var') )
        minSUsr=minS;
    end
    if (~exist("lHist","var")), lHist=true; end
    if ( exist('Nbins','var') )
        dsUsr=(maxSUsr-minSUsr)/Nbins;
    end
    
    % column mapping
    [ colNames, colUnits, colFacts, mapping ] = ...
                             GetVariablesAndMappingParticleData('losses');
    colS=mapping(find(strcmp(colNames,'s')));
    
    % compute histogram
    if (lHist)
        % compute longitudinal histogram of losses
        edges=[minSUsr:dsUsr:maxSUsr];
        if (ismissing(indices))
            [hh,cc] = histcounts(losses{colS},edges);
        else
            [hh,cc] = histcounts(losses{colS}(indices),edges);
        end
        edges = cc(2:end) - 0.5*(cc(2)-cc(1));
        % plot histogram
        bar(edges,hh/sum(hh)/dsUsr,1);
        ylabel('pdf [m^{-1}]');
        ylim([0.5/(dsUsr*sum(hh)) 2*max(hh)/(sum(hh)*dsUsr)]);
    else
        % compute loss shares
        if (ismissing(indices))
            [cc,jj,kk]=unique(losses{mapping(strcmpi(colNames,"S"))});
        else
            [cc,jj,kk]=unique(losses{mapping(strcmpi(colNames,"S"))}(indices));
        end
        nUniques=length(cc);
        hh=accumarray(kk,1);
        cm=colormap(parula(nUniques));
        yMin=min(hh)/sum(hh);
        % plot histogram
        for ii=1:nUniques
            if (ii>1), hold on; end
            plot([cc(ii) cc(ii)],[yMin/10 hh(ii)/sum(hh)]*100,"Color",cm(ii,:),"LineWidth",1);
        end
        % bb=bar(cc,hh/sum(hh)*100,1,"EdgeColor","none");
        % bb.CData=cm;
        ylabel('[%]');
        ylim([yMin 1]*100);
    end
    
    % additionals
    xlabel('s [m]');
    xlim([minSUsr maxSUsr]);
    grid on;
    
end