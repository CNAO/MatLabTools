
%% description
%  file with standard particle data

fprintf("reading standard particle data...");

% proton data
fprintf("...PROTON data...");
Ap=1;
Zp=1;
mp=938.27208816; % [MeV/c2]

% helium data
fprintf("...HELIUM_4^2+ data...");
AHe=4;
ZHe=2;
mHe=931.2386834*AHe; % [MeV/c2]

% carbon data
fprintf("...CARBON_12^6+ data...");
AC=12;
ZC=6;
mC=931.2386834*AC; % [MeV/c2]

fprintf("...done;");
