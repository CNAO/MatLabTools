% {}~

%% description
% this is a script which shows:
% * the Bethe-Bloch for the accelerated particles. Refs:
%   - main formula: PDG, 2018, Chap. 33, pag. 447 (eq. 33.5)
%   - material parameters:
%     . https://pdg.lbl.gov/2022/AtomicNuclearProperties/index.html
%   - density effect: Sternheimer, Berger and Seltzer, ATOMIC DATA AND NUCLEAR DATA TABLES 30,26 l-27 1 (1984)
% * the Landau-Vavilov for the accelerated particles. Refs:
%   - main formula: PDG, 2018, Chap. 33, pag. 450 (eq. 33.11)
%   - material parameters:
%     . https://pdg.lbl.gov/2022/AtomicNuclearProperties/index.html

%% include libraries
% - include Matlab libraries
pathToLibrary="..\";
addpath(genpath(pathToLibrary));

%% clean/close
clear all;
close all;

%% settings

% - particle
myPart="PROTON"; % available: "PROTON", "CARBON", "HELIUM"

% NOTA BENE: please choose either an array of values of Ek and a single value
%            for the range traversed or the other way around;
% - kinetic energies
% Ek=1:1:1000; % [MeV] % proton energies
% Ek=1:1:400; % [MeV/A] % carbon energies
Ek=228.57; % single energy

% - range traversed
% mmEquiv=100.0; % [mm]
mmEquiv=0.1:0.1:10.1; % [mm]

% - water material parameters
ZoA_H2O=0.555087; % []
I_H2O=79.7; % [eV]
rho_H2O=1.0; % [g/cm3]
densEff_plasmaFreq_H20=21.469; % [eV]
densEff_C_H2O=3.5017; % actually, -C []
densEff_x0_H2O=0.2400; % []
densEff_x1_H2O=2.8004; % []
densEff_a_H2O=0.09116; % []
densEff_m_H2O=3.4773; % []
densEff_d0_H2O=0.0; % []

%% complement user's input
if (length(Ek)>1 && length(mmEquiv)>1), error("Please choose to scan either energy or range!"); end
if (length(Ek)==1), Ek=1:1:Ek; end

%% Load particle data
% returns: myM [MeV/c2], myEk [MeV], myZ [], unitEk ("MeV" for protons, "MeV/u" for others);
run(".\setParticle.m");

%% Bethe-Bloch

% - relativistic quantities
[myBeta,myGamma,myBetaGamma]=ComputeRelativisticQuantities(myEk,myM);    % [], [], []

% - Wmax
Wmax=ComputeWmax(myBetaGamma,myGamma,myM); % [MeV]
% % - show Wmax
% ShowMe(Wmax,myEk,"W_{max} [MeV]","E_k [MeV]",sprintf("W_{max} of %s",myPart));

% - density correction
densCorr_H2O=ComputeDensityCorrection(myBetaGamma,densEff_x0_H2O,densEff_x1_H2O,densEff_a_H2O,densEff_m_H2O,densEff_C_H2O,densEff_d0_H2O); % []

% - actual calculation
dEodx=ComputeBetheBloch(myZ,myBeta,myBetaGamma,Wmax,ZoA_H2O,I_H2O,densCorr_H2O); % [MeV/g cm2]
% - show Bethe-Bloch
ShowMe(dEodx,myBetaGamma,"<dE/dx> [MeV/g cm^2]","\beta\gamma []",sprintf("Mean stopping power of %s in WATER",myPart)); set(gca, 'YScale', 'log'); set(gca, 'XScale', 'log');
ShowMe(dEodx,Ek,"<dE/dx> [MeV/g cm^2]",sprintf("E_k [%s]",unitEk),sprintf("Mean stopping power of %s in WATER",myPart)); set(gca, 'YScale', 'log'); set(gca, 'XScale', 'log');

%% compute range (based on Bethe-Bloch)
range=ComputeRange(myEk,dEodx*rho_H2O)*10; % [mm]
% - show range
ShowMe(range,Ek,"R [mm]",sprintf("E_k [%s]",unitEk),sprintf("Range of %s in WATER",myPart));

%% compute delta_p/p for n-mm of water-equivalent material (based on Bethe-Bloch)
if (length(mmEquiv)==1)
    % - actual calculation
    dPoP=interp1(range,myBetaGamma,range-mmEquiv)./myBetaGamma-1;
    % - show dPoP vs beam energy for a specific thickness
    ShowMe(dPoP,Ek,"\delta []",sprintf("E_k [%s]",unitEk),sprintf("%s momentum variation after traversing %g mm of water equivalent",myPart,mmEquiv));
else
    % - actual calculation
    dPoP=interp1(range,myBetaGamma,range(end)-mmEquiv)./myBetaGamma(end)-1;
    % - show dPoP vs thickness for a specific beam energy
    ShowMe(dPoP,mmEquiv,"\delta []","z_{H_2O} [mm]",sprintf("Momentum variation vs water equivalent thickness for %g %s %s",Ek(end),unitEk,myPart));
end

%% Landau-Vavilov for n-mm of water-equivalent material
if (length(mmEquiv)==1)
    % - actual calculation
    mpEnLoss=ComputeLandauVavilov(myZ,myBeta,myBetaGamma,mmEquiv/10*rho_H2O,ZoA_H2O,I_H2O,densCorr_H2O); % [MeV]
    % - show Landau-Vavilov vs beam energy for a specific thickness
    ShowMe(mpEnLoss/(mmEquiv/10*rho_H2O),myBetaGamma,"\DeltaE [MeV/g cm^2]","\beta\gamma []",sprintf("Most probable energy loss of %s after traversing %g mm of water equivalent",myPart,mmEquiv)); set(gca, 'YScale', 'log'); set(gca, 'XScale', 'log');
else
    % - actual calculation
    mpEnLoss=ComputeLandauVavilov(myZ,myBeta(end),myBetaGamma(end),mmEquiv/10*rho_H2O,ZoA_H2O,I_H2O,densCorr_H2O(end)); % [MeV]
    % - show Landau-Vavilov vs thickness for a specific beam energy
    ShowMe(mpEnLoss,mmEquiv,"\DeltaE [MeV]","z_{H_2O} [mm]",sprintf("Most probable energy loss vs water equivalent thickness for %g %s %s IONs",Ek(end),unitEk,myPart)); set(gca, 'YScale', 'log'); % set(gca, 'XScale', 'log');
end

%% compare Bethe-Bloch and Landau-Vavilov
if (length(mmEquiv)==1)
    ShowMyContent=NaN(2,size(dEodx,2)); ShowMyContent(1,:)=dEodx; ShowMyContent(2,:)=mpEnLoss/(mmEquiv/10*rho_H2O); myLegend=["<dE/dx> (Bethe-Bloch)" "most probable \DeltaE/x (Landau-Vavilov)"];
    ShowMe(ShowMyContent,myBetaGamma,"\DeltaE [MeV/g cm^2]","\beta\gamma []",sprintf("Bethe-Bloch vs Landau-Vavilov for %s in %g mm of WATER",myPart,mmEquiv),myLegend); set(gca, 'YScale', 'log'); set(gca, 'XScale', 'log');
    ShowMe(ShowMyContent,Ek,"\DeltaE [MeV/g cm^2]",sprintf("E_k [%s]",unitEk),sprintf("Bethe-Bloch vs Landau-Vavilov for %s in %g mm of WATER",myPart,mmEquiv),myLegend); set(gca, 'YScale', 'log'); set(gca, 'XScale', 'log');
else
    dE=Ek(end)-interp1(range,Ek,range(end)-mmEquiv);
    ShowMyContent=NaN(2,size(dE,2)); ShowMyContent(1,:)=dE; ShowMyContent(2,:)=mpEnLoss; myLegend=["<dE> (Bethe-Bloch)" "most probable \DeltaE (Landau-Vavilov)"];
    ShowMe(ShowMyContent,mmEquiv,"\DeltaE [MeV]","z_{H_2O} [mm]",sprintf("Bethe-Bloch vs Landau-Vavilov for %g %s %s in WATER",Ek(end),unitEk,myPart),myLegend); set(gca, 'YScale', 'log'); % set(gca, 'XScale', 'log');
end

%% local functions

function Wmax=ComputeWmax(betagamma,gamma,M)
    % Wmax in [MeV]
    elMass=0.5109989461; % [MeV/c2]
    Wmax=(2*elMass*betagamma.^2)./(1+2*gamma*elMass/M+(elMass/M)^2);
end

function meanSpower=ComputeBetheBloch(z,beta,betagamma,Wmax,ZoA,I,densCorr)
    % mean stopping power in MeV/g cm2
    % - Wmax in [MeV];
    % - I in [eV];
    K=0.307075; % [MeV cm2 /mol]
    elMass=0.5109989461; % [MeV/c2]
    if (~exist("densCorr","var")), densCorr=0.0; end
    meanSpower=K*z^2*ZoA./beta.^2.*(0.5*log(2*elMass*betagamma.^2.*Wmax*1E12/I^2)-beta.^2-densCorr/2);
end

function mpEnLoss=ComputeLandauVavilov(z,beta,betagamma,x,ZoA,I,densCorr)
    % most probable energy loss according to Landau-Vavilov theory in MeV
    % - I in [eV];
    % - x in [g cm-2];
    K=0.307075; % [MeV cm2 /mol]
    elMass=0.5109989461; % [MeV/c2]
    csi=(K/2)*ZoA*z^2*(x./beta.^2);
    jj=0.20; % []
    if (~exist("densCorr","var")), densCorr=0.0; end
    mpEnLoss=csi.*(log(2*elMass*betagamma.^2.*1E6/I)+log(csi*1E6/I)+jj-beta.^2-densCorr);
end

function densCorr=ComputeDensityCorrection(betagamma,x0,x1,a,m,C,d0)
    if (~exist("d0","var")), d0=0.0; end
    densCorr=NaN(1,length(betagamma));
    x=log10(betagamma);
    indices=(x1<=x); densCorr(indices)=2*log(10)*x(indices)-C;
    indices=(x0<=x & x<x1); densCorr(indices)=2*log(10)*x(indices)-C+a*(x1-x(indices)).^m;
    indices=(x<x0); densCorr(indices)=d0*10.^(2*(x(indices)-x0)); % non-conductor
end

function range=ComputeRange(Ek,dEodx)
    % dEodx in [MeV/cm]
    % range in [cm]
    range=cumtrapz(Ek,1./(dEodx));
end

function ShowMe(yData,xData,yLab,xLab,myTitle,myLegend)
    figure();
    for ii=1:size(yData,1)
        if (ii>1), hold on; end
        plot(xData,yData(ii,:),".-");
    end
    xlabel(xLab); ylabel(yLab);
    grid(); title(myTitle);
    if (exist("myLegend","var")), legend(myLegend,"Location","best"); end
end
