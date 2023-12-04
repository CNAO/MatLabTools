function [DataX,DataY]=ExtractFromTable(myTable,myXs,myYs)
% ExtractFromTable          to get specific columns as X and Y values
    fNames=fieldnames(myTable);
    DataX=missing(); DataY=missing();
    for ii=1:length(myXs)
        iField=strcmpi(myXs(ii),fNames);
        if any(iField)
            DataX=ExpandMat(DataX,myTable.(fNames{iField}));
        else
            error("no field %s in table!",myXs(ii));
        end
    end
    for ii=1:length(myYs)
        iField=strcmpi(myYs(ii),fNames);
        if any(iField)
            DataY=ExpandMat(DataY,myTable.(fNames{iField}));
        else
            error("no field %s in table!",myYs(ii));
        end
    end
end
