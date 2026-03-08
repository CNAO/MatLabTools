function ShowDCTtime(DCTtStamps,DCTcurrs,DCTcyCodes,xVals,whatYlabs,whatXlab)

    fprintf("plotting %s data vs time...\n",whatYlabs);
    [rangeCodes,partCodes]=DecodeCyCodes(DCTcyCodes);
    indicesP=FlagPart(partCodes,"p");
    indicesC=FlagPart(partCodes,"C");
    indicesHe=FlagPart(partCodes,"He");
    nPlots=size(DCTcurrs,2);
    figure();

    % DCT data
    for ii=1:nPlots
        axs(ii)=subplot(nPlots+1,1,ii);
        plot(datenum(DCTtStamps(indicesP)),DCTcurrs(indicesP,ii),"r.",...
             datenum(DCTtStamps(indicesC)),DCTcurrs(indicesC,ii),"b.",...
             datenum(DCTtStamps(indicesHe)),DCTcurrs(indicesHe,ii),"g.");
        ylabel(whatYlabs(ii)); set(gca, 'YScale', 'log');
        datetick('x','dd-mm HH:MM:ss'); set(gca,'XTickLabelRotation',45);
        legend("proton","carbon","helium",'location','best'); grid();
    end

    % beam energies/ranges
    axs(nPlots+1)=subplot(nPlots+1,1,nPlots+1);
    plot(datenum(DCTtStamps(indicesP)),xVals(indicesP),"r.",...
         datenum(DCTtStamps(indicesC)),xVals(indicesC),"b.",...
         datenum(DCTtStamps(indicesHe)),xVals(indicesHe),"g.");
    ylabel(whatXlab);
    datetick('x','dd-mm HH:MM:ss'); set(gca,'XTickLabelRotation',45);
    legend("proton","carbon","helium",'location','best'); grid();

    % global
    dynamicDateTicks(axs, 'linked');
    linkaxes(axs,"x");
        
    fprintf("...done;\n");
end

