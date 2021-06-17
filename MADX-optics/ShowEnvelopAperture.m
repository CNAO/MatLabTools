function ShowEnvelopAperture(optics,geometry,myTitle,Laccel,Qx,Qy,Chrx,Chry,emig,sigdpp)
% ShowEnvelopAperture      displays a quick plot of the beam envelop with the aperture
% 
% When calling this function, please remember to load the path to the whole
%    library, e.g. via:
%         pathToLibrary="D:\VMs\vb_share\repos\MatLabTools";
%         addpath(genpath(pathToLibrary));
%
% The function simply shows a figure with 3 plots (1 column, 3 rows):
% - lattice structure;
% - hor envelop and aperture;
% - ver envelop and aperture;

    [aperH,aperOffH,aperSH]=GetAperture(geometry,0);
    [aperV,aperOffV,aperSV]=GetAperture(geometry,90);

    emigUsr=ones(1,2)*1.0E-06; % [m rad]
    if ( exist('emig','var') )
        emigUsr=emig;
    end
    sigdppUsr=0.0; % []
    if ( exist('sigdpp','var') )
        sigdppUsr=sigdpp;
    end
        
    f1=figure('Name','Beam envelop and aperture','NumberTitle','off');

    % - geometry
    ax1=subplot(3,1,1);
    PlotLattice(geometry);
    if ( exist('Laccel','var') )
        xlim([0 Laccel]);
    end
    % - hor envelop
    ax2=subplot(3,1,2);
    PlotOptics(optics,"ENVX",emigUsr(1),sigdppUsr);
    hold on; 
    PlotOptics(optics,"X");
    hold on;
    PlotAperture(aperH,aperOffH,aperSH);
    ylabel("[m]");
    if ( exist('Laccel','var') )
        xlim([0 Laccel]);
    end
    grid on;
    % - ver envelop
    ax3=subplot(3,1,3);
    PlotOptics(optics,"ENVY",emigUsr(2),sigdppUsr);
    hold on; 
    PlotOptics(optics,"Y");
    hold on;
    PlotAperture(aperV,aperOffV,aperSV);
    ylabel("[m]");
    if ( exist('Laccel','var') )
        xlim([0 Laccel]);
    end
    grid on;
    % - title
    tmpTitle="";
    if ( exist('myTitle','var') )
        tmpTitle=myTitle;
    end
    if ( exist('Qx','var') & exist('Qy','var') & exist('Chrx','var') & exist('Chry','var') )
        if ( strlength(tmpTitle) > 0 )
            tmpTitle=sprintf("%s\nQ_x=%g, Q_y=%g, \\xi_x=%g, \\xi_y=%g;",tmpTitle,Qx,Qy,Chrx,Chry);
        else
            tmpTitle=sprintf("Q_x=%g, Q_y=%g, \\xi_x=%g, \\xi_y=%g;",Qx,Qy,Chrx,Chry);
        end
    end
    if ( strlength(tmpTitle) > 0 )
        sgtitle(tmpTitle);
    end
    linkaxes([ax1 ax2 ax3],'x');
end
