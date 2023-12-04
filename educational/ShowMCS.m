% {}~

%% description
% this is a script which shows the Bethe-Bloch for the accelerated particles
% Refs:
% - main formula: PDG, 2018, Chap. 33, pag. 451 (eq. 33.15)
% - material parameters:
%   . https://pdg.lbl.gov/2022/AtomicNuclearProperties/index.html

%% include libraries
% - include Matlab libraries
pathToLibrary="..\";
addpath(genpath(pathToLibrary));

%% settings

% - particle
myPart="PROTON"; % available: "PROTON", "CARBON", "HELIUM"

% NOTA BENE: please choose either an array of values of Ek and a single value
%            for the range traversed or the other way around;
% - kinetic energies
Ek=1:1:250; % [MeV] % proton energies
% Ek=1:1:400; % [MeV/A] % carbon energies
% Ek=228.57; % single energy
% - range traversed
mmEquiv=100.0; % [mm]
% mmEquiv=0.1:0.1:10.1; % [mm]

% - water material parameters
X0_H2O=36.08; % [cm]

%% Load particle data
% returns: myM [MeV/c2], myEk [MeV], myZ [], unitEk ("MeV" for protons, "MeV/u" for others);
run(".\setParticle.m");

%% compute MCS scattering tables
% - relativistic quantities
[myBeta,myGamma,myBetaGamma]=ComputeRelativisticQuantities(myEk,myM);    % [], [], []
% - MCS theta0 (Moliere's theory)
theta0=ComputeTheta0(myBeta,myBetaGamma*myM,myZ,mmEquiv,X0_H2O);
% - show theta0
if (length(mmEquiv)==1 && length(Ek)>1)
    % as a function of energy
    ShowMe(theta0*1000,Ek,"\theta [mrad]",sprintf("E_k [%s]",unitEk),sprintf("MCS for %s after traversing %g mm of water equivalent",myPart,mmEquiv)); set(gca, 'YScale', 'log');
else
    % as a function of material thickness
    ShowMe(theta0*1000,mmEquiv,"\theta [mrad]","H_2O Range [mm]",sprintf("MCS for %s of %g %s",myPart,myEk,unitEk)); set(gca, 'YScale', 'log');
end

%% show effect of scattering
L=0.15; % distance in vacuum travelled by scattered beam [m]
if (length(mmEquiv)==1 && length(Ek)>1)
    % as a function of energy
    ShowMe(theta0*L*1000,Ek,"\theta\timesL [mm]",sprintf("E_k [%s]",unitEk),sprintf("MCS for %s after traversing %g mm of water equivalent",myPart,mmEquiv)); set(gca, 'YScale', 'log');
else
    % as a function of material thickness
    ShowMe(theta0*1000,mmEquiv,"\theta\timesL [mm]","H_2O Range [mm]",sprintf("MCS for %s of %g %s",myPart,Ek,unitEk)); set(gca, 'YScale', 'log');
end


%% local functions

function theta0=ComputeTheta0(beta,pp,z,x,X0)
    % theta0 in [rad];
    % pp in [MeV/c];
    % x in [mm];
    % X0 in [cm];
    theta0=13.6./(beta.*pp)*z*sqrt(x*0.1./X0).*(1+0.038*log((x*0.1./X0)*(z./beta).^2));
end

function ShowMe(yData,xData,yLab,xLab,myTitle)
    figure();
    plot(xData,yData,".-");
    xlabel(xLab); ylabel(yLab);
    grid(); title(myTitle);
end
