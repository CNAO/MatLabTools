function [beta,alpha,emiG,disp,dispP,sigdpp]=DecodeOpticsFit(SS)
% DecodeOpticsFit     converts the value of fitting parameters (e.g. from quad scans)
%                       into starting values of optics functions and beam
%                       statistics data.
%
% Depending on the length of SS, dispersion terms are taken into account or
% not:
% - length(SS)==3: usual betatron scan, with:
%   SS(1) = sigma(1,1)(s=0)
%   SS(2) = sigma(1,2)(s=0)
%   SS(3) = sigma(2,2)(s=0)
% - length(SS)==6: combined betatron and dispersion scan, with:
%   SS(1) = sigma(1,1)(s=0) +D(s=0)^2 *sig_dpp^2
%   SS(2) = sigma(1,2)(s=0) +D(0)Dp(s=0) *sig_dpp^2
%   SS(3) = sigma(2,2)(s=0) +Dp(s=0)^2 *sig_dpp^2
%   SS(4) = D(s=0) *sig_dpp^2
%   SS(5) = Dp(s=0)*sig_dpp^2
%   SS(6) = sig_dpp^2
% 
% more info at:
%      https://accelconf.web.cern.ch/d99/papers/PT10.pdf
%
% see also BuildTransportMatrixForOptics, DecodeOrbitFit,
%       FitOpticsThroughOrbitData, FitOpticsThroughSigmaData, SolveOrbSystem,
%       and SolveSigSystem
    beta=NaN(); alpha=NaN(); emiG=NaN();
    disp=NaN(); dispP=NaN(); sigdpp=NaN();
    if ( length(SS)==6 )
        sigdpp=sqrt(SS(6));
        if ( sigdpp~=0.0 )
            disp=SS(4)/SS(6);
            dispP=SS(5)/SS(6);
        end
        TT=zeros(3,1);
        if ( sigdpp==0.0 )
            TT(1)=SS(1);
            TT(2)=SS(2);
            TT(3)=SS(3);
        else
            TT(1)=SS(1)-(disp^2)*SS(6);
            TT(2)=SS(2)-(disp*dispP)*SS(6);
            TT(3)=SS(3)-(dispP^2)*SS(6);
        end
    elseif ( length(SS)==3 )
        TT=SS;
    else
        error("SS can only be an array of 3 or 6 elements!");
    end
    emiG=sqrt(TT(1)*TT(3)-TT(2)^2);
    beta=TT(1)/emiG;
    alpha=-TT(2)/emiG;
    if ( ~isreal(emiG) || emiG<= 0.0)
        % throw away results: unphysical!
        warning("...emittance with imaginary part!");
        beta=NaN(); alpha=NaN(); emiG=NaN();
    end
    if ( ~isreal(sigdpp) || sigdpp<= 0.0)
        % throw away results: unphysical!
        warning("...sigdpp with imaginary part!");
        disp=NaN(); dispP=NaN(); sigdpp=NaN();
    end
end
