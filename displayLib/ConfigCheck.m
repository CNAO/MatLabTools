function OutVar=ConfigCheck(InVar,nSets,myName)
% ConfigCheck(InVar,nSets,myName)   consistency check of user input data;
%                                   the function simply checks that the
%                                     array InVar has nSets non-missing
%                                     values;
%                                   in case nSets>1 and length(InVar)==1,
%                                     the function replicates the single
%                                     value of InVar nSets times;
%
% input
% - InVar (1D strings): a list of strings (eg beam particles,
%                       configurations, etc...);
% - nSets (scalar): expected length(InVar);
% - myName (string): a string used just for printout on terminal in case of
%                    error;
%
% output:
% - OutVar (1D strings): a list of strings such that length(OutVar)=nSets;
% 
    OutVar=InVar;
    nIn=length(OutVar);
    if (nIn<nSets)
        if (nIn==1)
            OutVar=strings(nSets,1);
            OutVar(:)=InVar;
        else
            error("multiple values of %s!",myName);
        end
    end
end
