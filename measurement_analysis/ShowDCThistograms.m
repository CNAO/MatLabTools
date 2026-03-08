function ShowDCThistograms(DCTcurrs,DCTcyCodes,xVals,whatYlabs,whatXlab)
    fprintf("plotting histograms of DCT data...\n");
    [rangeCodes,partCodes]=DecodeCyCodes(DCTcyCodes);
    indicesP=FlagPart(partCodes,"p");
    indicesC=FlagPart(partCodes,"C");
    indicesHe=FlagPart(partCodes,"He");
    nPlots=size(DCTcurrs,2);
    figure();
    
    % proton data
    for ii=1:nPlots
        fprintf("...computing histograms for protons...\n");
        [myXs,myYs,aves,maxs,uEks,Ibs,myHist]=GetHistograms(DCTcurrs(indicesP,ii),xVals(indicesP));
        fprintf("...showing proton data...\n");
        axP(ii)=subplot(nPlots,3,(ii-1)*3+1);
        ShowHistograms(myXs,myYs,aves,maxs,uEks,Ibs,myHist,"proton",whatYlabs(ii),whatXlab);
    end

    % carbon data
    for ii=1:nPlots
        fprintf("...computing histograms for carbon ions...\n");
        [myXs,myYs,aves,maxs,uEks,Ibs,myHist]=GetHistograms(DCTcurrs(indicesC,ii),xVals(indicesC));
        fprintf("...showing carbon ion data...\n");
        axC(ii)=subplot(nPlots,3,(ii-1)*3+2);
        ShowHistograms(myXs,myYs,aves,maxs,uEks,Ibs,myHist,"carbon",whatYlabs(ii),whatXlab);
    end
    
    % helium data
    for ii=1:nPlots
        fprintf("...computing histograms for helium ions...\n");
        [myXs,myYs,aves,maxs,uEks,Ibs,myHist]=GetHistograms(DCTcurrs(indicesHe,ii),xVals(indicesHe));
        fprintf("...showing helium ion data...\n");
        axHe(ii)=subplot(nPlots,3,ii*3);
        ShowHistograms(myXs,myYs,aves,maxs,uEks,Ibs,myHist,"helium",whatYlabs(ii),whatXlab);
    end
    
    % global
    linkaxes(axP,"x");
    linkaxes(axC,"x");
    linkaxes(axHe,"x");
    
    % bye bye
    fprintf("...done.\n");
end

function [myXs,myYs,aves,maxs,uEks,Ibs,myHist]=GetHistograms(DCTcurrs,Eks)
    % unique Eks
    uEks=unique(Eks);
    % intensity bins
    Imin=min(DCTcurrs); Imax=max(DCTcurrs); NI=100; Ibs=Imin:(Imax-Imin)/NI:Imax;
    showIs=Ibs(1:end-1)+0.5*(Imax-Imin)/NI;
    myHist=zeros(NI*length(uEks),1);
    myXs=zeros(NI*length(uEks),1);
    myYs=zeros(NI*length(uEks),1);
    aves=zeros(length(uEks),1);
    maxs=zeros(length(uEks),1);
    for ii=1:length(uEks)
        jj=(ii-1)*NI;
        myHist(jj+1:jj+NI)=histcounts(DCTcurrs(Eks==uEks(ii),1),Ibs)';
        aves(ii)=mean(DCTcurrs(Eks==uEks(ii),1));
        [myMax,IDmax]=max(myHist(jj+1:jj+NI));
        maxs(ii)=showIs(IDmax);
        myXs(jj+1:jj+NI)=uEks(ii);
        myYs(jj+1:jj+NI)=showIs;
    end
end

function ShowHistograms(myXs,myYs,aves,maxs,uEks,Ibs,myHist,myTitle,whatYlab,whatXlab)
    scatter(myXs,myYs,32,myHist,'filled','s');
    hold on; plot(uEks,aves,"r*");
    hold on; plot(uEks,maxs,"mo");
    ylim([Ibs(1) Ibs(end)]);
    colorbar();
    legend("hist","mean int","most freq int","Location","best");
    xlabel(whatXlab); ylabel(whatYlab);
    title(sprintf("Spill histogram - %s",myTitle));
end
