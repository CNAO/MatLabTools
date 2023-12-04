function MRpath=PathToMachineRefs()
% PathToMachineRefs         returns the path to the MachineRefs clone.
%                           This is searched for in the same path where
%                              MatLabTools is located.
%                           If the path is not found in the path env var,
%                              then it is automatically added.
    MRrepoName="MachineRefs";
    MLTrepoName="MatLabTools";
    if (contains(path,MRrepoName))
        allPaths=string(split(path,";"));
        MRpaths=allPaths(contains(allPaths,MRrepoName));
        if (isempty(MRpaths))
            error("Something wrong with getting path to %s",MRrepoName);
        end
        MRpath=extractBetween(MRpaths(1),1,MRrepoName,"Boundaries","inclusive");
        if (~isfolder(MRpath))
            error("Cannot access path to %s: %s",MRrepoName,MRpath);
        end
    else
        warning("path to %s not loaded. Building it...",MRrepoName);
        if (~contains(path,MLTrepoName))
            error("Path to %s NOT loaded",MLTrepoName);
        else
            allPaths=string(split(path,";"));
            MLTpaths=allPaths(contains(allPaths,MLTrepoName));
            if (isempty(MLTpaths))
                error("Something wrong with getting path to %s",MLTrepoName);
            end
            MLTpath=extractBetween(MLTpaths(1),1,MLTrepoName,"Boundaries","inclusive");
            if (~isfolder(MLTpath))
                error("Cannot access path to %s: %s",MLTrepoName,MLTpath);
            end
            MRpath=strcat(extractBetween(MLTpaths(1),1,MLTrepoName),"/",MRrepoName);
            addpath(genpath(MRpath)); 
        end
    end
end
