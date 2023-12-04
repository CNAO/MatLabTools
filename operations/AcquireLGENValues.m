%% main function

function [cyCodes,ranges,Eks,Brhos,currents,fields,kicks,psNames,FileNameCurrents]=AcquireLGENValues(myConfig,path2Files,filters,LGENsCheck)

    fprintf("Getting current values...\n");
    
    %% input arguments
    [machine,beamPart,focus,config]=DecodeConfig(myConfig);
    fprintf("...for: machine=%s; beamPart=%s; config=%s;\n",machine,beamPart,config);
    if (~exist("path2Files","var")), path2Files=missing(); end
    if (ismissing(path2Files))
        path2Files=ReturnDefFile("LGEN",myConfig);
    end
    if (length(path2Files)==1)
        path2Files(2)=ReturnDefFile("BRHO",myConfig);
    end
    if ( ~exist('filters','var') ), filters=["NaN" "0"]; end
    if ( exist('LGENsCheck','var') )
        doVisualCheck=true;
    else
        doVisualCheck=false;
        LGENsCheck=missing;
    end

    %% do the job
    currentData = GetOPDataFromTables(path2Files(1)); FileNameCurrents=path2Files(1);
    CyCoData = GetOPDataFromTables(path2Files(2));
    % - make a unique table: 1=CyCo[], 2=range[mm], 3=Energy[MeV/n], 4=Brho[Tm] - columns in final cell array
    CyCoData=CyCoData(2:end,1:4);

    % get currents and PSs to be crunched
    % - nRows: number of power supplies + a header
    % - nColumns: number of cycle codes + 2 (PS name + property)
    [currents,psNames]=tableCurrents(currentData(2:end,3:end),currentData(2:end,1)); % remove useless data from PS file and convert to matrix of floats
    nPSs=length(psNames);

    % - get cycle codes to be crunched
    buffer = vertcat( currentData{1,3:end} ) ; % extract only first four digits of cyco
    currCycodes=cellstr(buffer(:,1:4)) ;       %
    nCyCodes=length(currCycodes);

    for iFilter=1:length(filters)
        switch upper(filters(iFilter))
            case "NAN"
                % - keep only PSs with no NANs (full set of cycodes should be NaN)
                fprintf("...filtering NaNs from PSs...\n");
                % PS deleted)
                iRows=zeros(size(currents,1),1,'logical');
                for ii=1:length(iRows)
                    iRows(ii)=length(currents(ii,~isnan(currents(ii,:))))==nCyCodes;
                end
                nDelete=nPSs-sum(iRows);
                if ( nDelete>0 )
                    warning("found %d PSs with rows/columns full of NaNs! removing them...",nDelete);
                    currents=currents(iRows,:);
                    psNames=psNames(iRows);
                    nPSs=length(psNames);
                end
            case {"ZERO","0","0.0","0."}
                % - keep only PSs with no 0.0s (full set of cycodes should be 0)
                fprintf("...filtering 0.0s from PSs...\n");
                % PS deleted)
                iRows=zeros(size(currents,1),1,'logical');
                for ii=1:length(iRows)
                    iRows(ii)=length(currents(ii,currents(ii,:)~=0.0))==nCyCodes;
                end
                nDelete=nPSs-sum(iRows);
                if ( nDelete>0 )
                    warning("found %d PSs with rows/columns full of 0s! removing them...",nDelete);
                    currents=currents(iRows,:);
                    psNames=psNames(iRows);
                    nPSs=length(psNames);
                end
            otherwise
                warning("...un-identified filtering criterion: %s",filters(iFilter));
        end
    end

    % map the CyCo in both current data and CyCo data
    [commonCyCodes,iCCa,iCCb]=intersect(currCycodes,CyCoData(:,1));
    if ( iCCa~=nCyCodes )
        warning("not all cycle codes in PS file will be dumped!");
    end
    % - general data:
    cyCodes=commonCyCodes;
    CyCoData=CyCoData(iCCb,:);
    ranges=cell2mat(CyCoData(:,2));
    Eks=cell2mat(CyCoData(:,3));
    Brhos=cell2mat(CyCoData(:,4));
    % - currents, fields, kicks
    currents=currents(:,iCCa)';
    fields=Currents2Fields(psNames,currents');
    kicks=Fields2Kicks(fields,Brhos);

    if ( length(cyCodes)==0 )
        warning("no data loaded!");
        if ( doVisualCheck )
            warning("skipping visual checks!");
        end
    else
        if ( doVisualCheck )
            fprintf("...preparing checking plots...\n");
            if ( isempty(LGENsCheck) )
                LGENsCheck=string(psNames)';
            end
            xVals=ranges;
            xLab="BP [mm]"; % "BP [mm]", "Ek [MeV/n]", "Brho [Tm]"
            fprintf("   ...bare currents...\n");
            visualCheck(LGENsCheck,psNames,xVals,xLab,currents);
            fprintf("   ...fields...\n");
            visualCheck(LGENsCheck,psNames,xVals,xLab,currents,fields);
            fprintf("   ...normalised kicks...\n");
            visualCheck(LGENsCheck,psNames,xVals,xLab,currents,fields,kicks);
        end
    end

    fprintf("...done.\n");
end

%% ancillary functions

function [currents,psNames]=tableCurrents(currentData,psNameData)
    nRows=size(currentData,1);
    nCols=size(currentData,2);
    whichRows=false(nRows,1);
    for iRow=1:nRows
        if ( ischar(currentData{iRow,1}) || isstring(currentData{iRow,1}) )
            whichRows(iRow)=1;
        else
            whichRows(iRow)=~ismissing(currentData{iRow,1});
        end
    end
    nEmpty=nRows-sum(whichRows);
    if ( nEmpty>0 )
        warning("found %d PSs with empty rows! removing them...",nEmpty);
    end
    currents=currentData(whichRows,:);
    psNames=upper(psNameData(whichRows,:));
    if ( ischar(currents{1,1}) || isstring(currents{1,1}) )
        currents=str2double(currents);
    else
        currents=cell2mat(currents);
    end
end

function visualCheck(LGENs,psNames,xVals,xLab,currents,fields,kicks)
    % visual check
    figure('Name','visual check','NumberTitle','off');
    nSets=length(LGENs);
    % automatically set grid of subplots
    [nRows,nCols]=GetNrowsNcols(nSets);
    for iSet=1:nSets
        currLGEN=LGENs(iSet);
        subplot(nRows,nCols,iSet);
        jj=find(strcmp(psNames,currLGEN));
        if ( exist('fields','var') )
            [pQ,unit,name]=LGENname2pQ(currLGEN);
            if ( exist('kicks','var') )
                plot(currents(:,jj),fields(:,jj),'s-');
                ylabel(sprintf("%s [%s]",name,unit));
                yyaxis right;
                plot(currents(:,jj),kicks(:,jj),'.-');
                [kickName,kickUnit]=DecodeKickName(name);
                ylabel(sprintf("%s [%s]",kickName,kickUnit));
                yyaxis left;
                xlabel("I [A]");
                legend('field','kick','Location','best');
            else        
                minField=min(fields(:,jj));
                maxField=max(fields(:,jj));
                tmpFields=minField:(maxField-minField)/200:maxField;
                tmpCurrents=polyval(pQ,tmpFields);
                plot(fields(:,jj),currents(:,jj),'*',tmpFields,tmpCurrents,'-');
                xlabel(sprintf("%s [%s]",name,unit));
                ylabel("I [A]");
                legend('data','curve','Location','best');
            end
        else
            plot(xVals,currents(:,jj),'*');
            xlabel(xLab);
            ylabel("I [A]");
            legend('data','Location','best');
        end
        grid on;
        title(currLGEN);
    end
end
