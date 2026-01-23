function [Pout]=Transform2D(Pin,C,angles,lInv)
    % C, Pin, Pout: 2xN
    if (~exist("lInv","var")), lInv=false; end % by default, direct transformation
    nPoints=size(Pin,2);
    nAngles=length(angles);
    nCentres=size(C,2);
    if (nAngles~=nPoints & nAngles>1 )
        error("incosistent number of angles (%d) and points (%d)!",nAngles,nPoints);
    end
    if (nAngles~=nCentres)
        error("incosistent number of angles (%d) and centres (%d)!",nAngles,nCentres);
    end
    Pout=NaN(nPoints,2);
    if (lInv)
        TRs=Rot2D(-angles); % 2D rotation matrices
        if (nAngles==nPoints)
            % each point has a dedicated rotation matrix/centre
            for ii=1:nPoints
                Pout(ii,:)=TRs(:,:,ii)*(Pin(:,ii)-C(:,ii));
            end
        else
            % one rotation matrix/centre for all points
            for ii=1:nPoints
                Pout(ii,:)=TRs*(Pin(:,ii)-C);
            end
        end
    else
        TRs=Rot2D(angles); % 2D rotation matrices
        if (nAngles==nPoints)
            % each point has a dedicated rotation matrix/centre
            for ii=1:nPoints
                Pout(ii,:)=TRs(:,:,ii)*Pin(:,ii)+C(:,ii);
            end
        else
            % one rotation matrix/centre for all points
            for ii=1:nPoints
                Pout(ii,:)=TRs*Pin(:,ii)+C;
            end
        end
    end
    Pout=Pout';
end
