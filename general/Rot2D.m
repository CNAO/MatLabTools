function TR=Rot2D(angle,lDegs)
% Rot2D(angle)     generates a 2D rotation matrix of angle expressed in degrees
%
% Angle [deg] is expressed following the right-hand rule.
% If angle is an array, then as many rotation matrices as length(angle) are
%    generated.

    if (~exist("lDegs","var")), lDegs=true; end
    nAngles=length(angle);
    TR=NaN(2,2,nAngles);
    for ii=1:nAngles
        if (lDegs)
            TR(:,:,ii)=[cosd(angle(ii)) -sind(angle(ii)); sind(angle(ii)) cosd(angle(ii))];
        else
            TR(:,:,ii)=[cos (angle(ii)) -sin (angle(ii)); sin (angle(ii)) cos (angle(ii))];
        end
    end
end
