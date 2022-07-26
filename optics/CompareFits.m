function CompareFits(calcY,xVals,measY,measCurr,what,par1Names,par2Names,planeNames,myXlabel,par3Names,myTit)
    if ( ~strcmpi(what,"SIG") && ~strcmpi(what,"BAR") )
        error("you can compare either SIGmas or BARicentres!");
    end
    
    nXs=size(calcY,1);
    nPar1=size(calcY,2); % eg: sigdpp
    nPar2=size(calcY,3); % eg: fracEst
    nPlanes=size(calcY,4);
    nPar3=size(calcY,5); % eg: fit set
    
    %% checks
    if ( size(measY,1)~=nXs )
        error("Measured data must have as many values as the calculated ones!");
    end
    if ( size(measY,2)~=nPar1 )
        error("Measured data must be parametrised as the calculated ones (2nd dim)!");
    end
    if ( size(measY,3)~=nPar2 )
        error("Measured data must be parametrised as the calculated ones (3rd dim)");
    end   
    
    %% actual plotting
    for iPar1=1:nPar1 % eg: sigdpp
        figure();
        cm=colormap(parula(nPar3));
        ii=0;
        for iPlane=1:nPlanes
            yMin=min(measY(:,iPlane,:),[],"all");
            yMax=max(measY(:,iPlane,:),[],"all");
            yDlt=yMax-yMin;
            for iPar2=1:nPar2 % eg: fractEst
                ii=ii+1; axs(iPar2,iPlane)=subplot(nPlanes,nPar2+1,ii);
                % - measurements
                plot(measCurr,measY(:,iPlane,iPar2),"k*"); hold on;
                % - fits
                for iPar3=1:nPar3 % eg: fit set
                    hold on; plot(xVals(:,iPar3),calcY(:,iPar1,iPar2,iPlane,iPar3)*1E3,".-","color",cm(iPar3,:));
                end
                % - general
                grid(); xlabel(myXlabel);
                ylim([yMin-yDlt/10 yMax+yDlt/10]);
                if ( strcmpi(what,"SIG") )
                    ylabel("\sigma [mm]");
                    title(sprintf("%s plane - %s",planeNames(iPlane),par2Names(iPar2)));
                else
                    ylabel("BAR [mm]");
                    title(sprintf("%s plane",planeNames(iPlane)));
                end
            end
            % dedicated plot for the legend
            if ( iPlane==1 )
                ii=ii+1; subplot(nPlanes,nPar2+1,ii);
                plot(NaN(),NaN(),"k*");
                for iPar3=1:nPar3
                    hold on; plot(NaN(),NaN(),".-","Color",cm(iPar3,:));
                end
                legends=strings(nPar3+1,1);
                legends(1)="measurements";
                legends(2:end)=par3Names;
                legend(legends,"Location","best");
            end
        end
        if ( nPar2>1 )
            linkaxes(axs(:,1),"xy"); % all HOR quantities
            linkaxes(axs(:,2),"xy"); % all VER quantities
        end
        sgtitle(sprintf("%s - %s",par1Names(iPar1),myTit));
    end
end
