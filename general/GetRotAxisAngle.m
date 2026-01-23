function [eigVec,angle]=GetRotAxisAngle(Rm)
    % references:
    % - math: https://en.wikipedia.org/wiki/Rotation_matrix
    %         (Conversion from rotation matrix to axis–angle)
    % - matlab: https://it.mathworks.com/help/matlab/ref/double.trace.html
    %           https://it.mathworks.com/help/matlab/ref/eig.html
    %           https://it.mathworks.com/help/matlab/ref/atan2.html
    % input:
    % - Rm: 3x3 rotation matrix
    %
    % output:
    % - eigVec: 1x3 rotation axis (norm=1);
    % - angle: [rad];
    
    fprintf("finding rotation axis and angle of rotation matrix...\n");

    % V: matrix of eigenvectors; D: eigenvalues on the diagonal
    [V,D] = eig(Rm);
    
    % rotation axis is the only eigenvector with a purely real eigenvalue
    %   (the other two eigenvalues are complex conjugate)
    ii=find(imag(diag(D))==0);
    if (length(ii)>1), error("More than a real eigenvalue for rotation matrix!"); end
    eigVal=D(ii,ii);
    eigVec=V(:,ii)';
    fprintf("...real eigenvalue # %d: %g; it corresponds to eigenvector:\n",ii,eigVal);
    eigVec
    if (abs(norm(eigVec)-1)>1E-15), error("Norm of eigenvector of rotation matrix different from 1!"); end
    
    % rotation angle:
    CC=(trace(Rm)-1)/2.;
    Kn=zeros(3);
    Kn(1,2)=-eigVec(3); Kn(2,1)= eigVec(3);
    Kn(1,3)= eigVec(2); Kn(3,1)=-eigVec(2);
    Kn(2,3)=-eigVec(1); Kn(3,2)= eigVec(1);
    SS=-trace(Kn*Rm)/2.;
    angle=atan2(SS,CC);
    fprintf("...rotation angle: %g rad, %g deg\n",angle,rad2deg(angle));
    fprintf("...done.\n");
end
