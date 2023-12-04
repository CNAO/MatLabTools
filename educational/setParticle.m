%% description
%  file for loading the correct particle data

run(".\particleData.m");
switch upper(myPart)
    case {"P","PROT","PROTON"}
        fprintf("...using PROTON data...");
        myM=mp; myEk=Ek; myZ=Zp; unitEk="MeV";
    case {"HE","HELIUM","ALPHA","ALFA"}
        fprintf("...using HELIUM_4^2+ data...");
        myM=mHe; myEk=Ek*AHe; myZ=ZHe; unitEk="MeV/u";
    case {"C","CARB","CARBON"}
        fprintf("...using CARBON_12^6+ data...");
        myM=mC; myEk=Ek*AC; myZ=ZC; unitEk="MeV/u";
    otherwise
        error("Unknown particle %s!",myPart);
end
