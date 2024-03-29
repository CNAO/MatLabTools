function [tStarts,tEnds,nAves]=ExtractNaturalTimesStationary(tStamps,counts)
% ExtractNaturalTimesStationary    search for "natural acquisition times", i.e.
%                                  times where most probably the acquisition was
%                                  stopped and re-started. The function crunches
%                                  log files by monitors of stationary stations
%                                  (both neutrons and photons).
% A single data-set is parsed.
%
% natural times of Stationary Monitors logging, i.e. between first and last count>0 between 0s;
%
% input:
% - tStamps (array of datetime): time stamps of events;
% - counts (array of floats): counts;
% output:
% - tStarts (array of datetime): time stamps of guessed start of acquisitions;
% - tEnds (array of datetime): time stamps of guessed end of acquisitions;
% - nAves (scalar, float): time stamps of events;
%
% See also ExtractNaturalTimesDiode and ExtractNaturalTimesPolyMaster.

    fprintf("getting natural times...\n");
    
    % find actual counts
    tCounts=[ 0 ; counts ; 0];
    diffs=diff(tCounts);
    iPosDiffs=find(diffs>0);  % positive counts: actual counts
    iNegDiffs=find(diffs<0);  % negative counts: end of integration
    iNzrDiffs=find(diffs~=0); % all events
    
    % last counts: find last positive counts before end of integration
    [vals,ia,ib]=intersect(iNzrDiffs,iNegDiffs);
    iEnd=iNzrDiffs(ia-1);
    ll=length(iEnd);
    
    % first counts: find first positive counts after end of integration
    % NB: do not forget first count!
    iStart=[ iPosDiffs(1) iNzrDiffs(ia(1:end-1)+1)];
    nAves=length(iStart);
    if ( ll~=nAves ), error("cannot properly identify times of start/end counting."); end
    tStarts(1:nAves)=tStamps(iStart);
    tEnds(1:nAves)=tStamps(iEnd);
    
    fprintf("...done;\n");
end
