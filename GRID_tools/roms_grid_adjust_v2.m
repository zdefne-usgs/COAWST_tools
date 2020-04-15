function roms_grid_adjust_v2(ncfile, theCommand)
%
% example usage: roms_grid_adjust_v2('spbay_carq_grd.nc')
%
% use this to adjust bathymetry and mask values
%
% Usage:
% Depth toggle button on - shows bathymetry.
% Mask toggle button on - shows mask at rho points.
% Depth and mask button on - is to adjust bathy but bathy is shown
%       only at points where mask = 1 (water).
% Lines on = adjusts grid lines.  -  diabled
% Need to have zoom off to change any values.
%
% Zoom in to area of interest, turn zoom off.
% Click on cell - acitve cell is outlined in magenta.
% Value of bathy or mask is shown in lower left corner.
% To change value - type new value in the edit box and hit the "Lock value" button.
% Dispaly will update new values.
% To save the data - you need to select "save data" button.
% There is no undo !!
%
%jcwarner 4/27/03
%
% Updates and changes
%
% Updated the cell selecting algorithm. It is easier to select cells now.
% Changed the outline of the buttons. Added Undo and Lock value buttons.
% Output_box shows the cell value
% To change a value: set the value in the input_box and click Lock value button. Select or double click the cell/cells to overwrite their values.
% The axes are plotted equally. No distortion while zooming in and out.
% There is one step undo
%
% Zafer Defne 07/31/09




global grid_plot outline thePointIndex ud overwrite_tool h_full_grid mask_rho_full_grid ncfile_name varr input_value output_value 
global adjust_depth_tool adjust_mask_tool adjust_lines_tool undo_tool collect_tool
global varr_depth varr_mask varr_lines mask_rho_full_grid_nan mouse_down xy enable_write enable_collect
global h_temp mask_temp
global xC yC  x_full_grid  y_full_grid
global output_ind row col collect_data

if nargin==1  %then we are just starting
    ncfile_name=ncfile;
    ncload(ncfile);
%     nc=netcdf(ncfile);
    enable_write=0;
    enable_collect=0;
    collect_data=[];
    %create a "full grid" arrays
    % x/y _full_grid are bounding psi points, extra rows and columns all around
    zsize=size(h);
    x_full_grid=ones(zsize+1);
    x_full_grid(2:end-1,2:end-1)=lon_psi;
    x_full_grid(2:end-1,1)=lon_psi(:,1)-(lon_psi(:,2)-lon_psi(:,1));
    x_full_grid(2:end-1,end)=lon_psi(:,end)+(lon_psi(:,end)-lon_psi(:,end-1));
    x_full_grid(1,2:end-1)=lon_psi(1,:)-(lon_psi(2,:)-lon_psi(1,:));
    x_full_grid(end,2:end-1)=lon_psi(end,:)+(lon_psi(end,:)-lon_psi(end-1,:));
    x_full_grid(1,1)=x_full_grid(1,2)-(x_full_grid(1,3)-x_full_grid(1,2));
    x_full_grid(1,end)=x_full_grid(1,end-1)+(x_full_grid(1,end-1)-x_full_grid(1,end-2));
    x_full_grid(end,1)=x_full_grid(end,2)-(x_full_grid(end,3)-x_full_grid(end,2));
    x_full_grid(end,end)=x_full_grid(end,end-1)+(x_full_grid(end,end-1)-x_full_grid(end,end-2));
    %
    y_full_grid=ones(zsize+1);
    y_full_grid(2:end-1,2:end-1)=lat_psi;
    y_full_grid(2:end-1,1)=lat_psi(:,1)-(lat_psi(:,2)-lat_psi(:,1));
    y_full_grid(2:end-1,end)=lat_psi(:,end)+(lat_psi(:,end)-lat_psi(:,end-1));
    y_full_grid(1,2:end-1)=lat_psi(1,:)-(lat_psi(2,:)-lat_psi(1,:));
    y_full_grid(end,2:end-1)=lat_psi(end,:)+(lat_psi(end,:)-lat_psi(end-1,:));
    y_full_grid(1,1)=y_full_grid(1,2)-(y_full_grid(1,3)-y_full_grid(1,2));
    y_full_grid(1,end)=y_full_grid(1,end-1)+(y_full_grid(1,end-1)-y_full_grid(1,end-2));
    y_full_grid(end,1)=y_full_grid(end,2)-(y_full_grid(end,3)-y_full_grid(end,2));
    y_full_grid(end,end)=y_full_grid(end,end-1)+(y_full_grid(end,end-1)-y_full_grid(end,end-2));
    xC=(x_full_grid(2:end,2:end)+x_full_grid(1:end-1,2:end)+x_full_grid(1:end-1,1:end-1)+x_full_grid(2:end,1:end-1))/4;
    yC=(y_full_grid(2:end,2:end)+y_full_grid(1:end-1,2:end)+y_full_grid(1:end-1,1:end-1)+y_full_grid(2:end,1:end-1))/4;
    %
    % h_full_grid is one more row and column than roms grid, to account for pcolor
    h_full_grid=zeros(zsize+1);
    h_full_grid(1:end-1,1:end-1)=h;  %pcolor does not use the right and top rows of h
    % mask_rho_full_grid - same idea as h_full_grid
    mask_rho_full_grid=zeros(zsize+1);
    mask_rho_full_grid(1:end-1,1:end-1)=mask_rho;
    % create array mask_rho_full_grid_nan which is mask_rho with nan's at all land points
    z_size=size(mask_rho_full_grid);
    mask_rho_full_grid_nan=mask_rho_full_grid(:);
    zz=find(mask_rho_full_grid_nan==0);
    mask_rho_full_grid_nan(zz)=nan;
    mask_rho_full_grid_nan=reshape(mask_rho_full_grid_nan,z_size);
    % varr is the variable that we are plotting, default strtup is to adjust depth
    varr=h_full_grid;
    %
    varr_depth=1;
    varr_mask=0;
    varr_lines=0;
    %
    mouse_down=0;
    %
    figure
    grid_plot=pcolor(x_full_grid,y_full_grid,varr);colorbar  %this shows the entire grid
    axis equal
    hold on
    ud=size(lon_psi,1)+2;  %number of vertical rows
    thePointIndex=10;    %just picked 10 to start with
    %plot the magenta box to show which cell has been selected
    outline=plot([x_full_grid(thePointIndex) x_full_grid(thePointIndex+1) x_full_grid(thePointIndex+1+ud) x_full_grid(thePointIndex+ud) x_full_grid(thePointIndex)], ...
        [y_full_grid(thePointIndex) y_full_grid(thePointIndex+1) y_full_grid(thePointIndex+1+ud) y_full_grid(thePointIndex+ud) y_full_grid(thePointIndex)],'m');
    set(outline,'linewidth',2)
    set(grid_plot,'Buttondownfcn','roms_grid_adjust2(1,''mouse_down'')');
    set(gcf,'toolbar','figure')
    set(gcf,'WindowButtonUpfcn','roms_grid_adjust2(1, ''mouse_up'')');
    set(gcf,'WindowButtonMotionfcn','roms_grid_adjust2(1, ''motion'')');


    %select to adjust depth (startup default)
    adjust_depth_tool=uicontrol('style','toggle','string','DEPTH','tag','adjust_depth_tool', 'units','normal', ...
        'position',[0.01 0.8 0.10 0.05], 'value',[1], ...
        'callback','roms_grid_adjust2(1,''adjust_tool'')');
    %select to adjust mask
    adjust_mask_tool=uicontrol('style','toggle','string','MASK','tag','adjust_mask_tool', 'units','normal', ...
        'position',[0.01 0.75 0.10 0.05], 'value', [0], ...
        'callback','roms_grid_adjust2(1,''adjust_tool'')');
    %select to adjust lines
    adjust_lines_tool=uicontrol('style','toggle','string','LINES','tag','adjust_lines_tool', 'units','normal', ...
        'position',[0.01 0.7 0.10 0.05], 'value', [0], ...
        'callback','roms_grid_adjust2(1,''adjust_tool'')');
    %window to input data
    output_ind=uicontrol('style','edit','string','','tag','output_ind', 'units','normal', ...
        'position',[0.01 0.50 0.10 0.05], 'enable', 'inactive'); %, 'callback','roms_grid_adjust2(1,'''')');
    output_value=uicontrol('style','edit','string',num2str(varr(thePointIndex)),'tag','output_value', 'units','normal', ...
        'position',[0.01 0.45 0.10 0.05], 'enable', 'inactive'); %, 'callback','roms_grid_adjust2(1,'''')');
    input_value=uicontrol('style','edit','string',0,'tag','input_value', 'units','normal', ...
        'position',[0.01 0.4 0.10 0.05]); %, 'callback','roms_grid_adjust2(1,'''')');
    overwrite_tool=uicontrol('style','toggle','string','Lock value','tag','overwrite_tool', 'units','normal', ...
        'position',[0.01 0.35 0.10 0.05], 'callback','roms_grid_adjust2(1,''overwrite_tool'')');
    undo_tool=uicontrol('style','pushbutton','string','Undo','tag','undo_tool', 'units','normal', ...
        'position',[0.01 0.3 0.10 0.05], 'value', [0], 'callback','roms_grid_adjust2(1,''undo_tool'')');
    collect_tool=uicontrol('style','toggle','string','Get values','tag','collect_tool', 'units','normal', ...
        'position',[0.01 0.20 0.10 0.05], 'value', [0], 'callback','roms_grid_adjust2(1,''collect_tool'')');
    %setup save data tool
    save_tool=uicontrol('style','pushbutton','string','Save data','tag','save_tool', 'units','normal', ...
        'position',[0.01 0.1 0.10 0.05], 'callback','roms_grid_adjust2(1,''save_data'')');
    zoom on

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % now for all the callback routines
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else

    switch theCommand

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'mouse_down'
            %get index of the point that is moving
            xy = get(gca, 'CurrentPoint');
            xlim = get(gca, 'XLim');
            ylim = get(gca, 'YLim');
            xdata=get(grid_plot,'xdata');
            xdata=xdata(:);
            ydata=get(grid_plot,'ydata');
            ydata=ydata(:);

            if (xy(1, 1) > xlim(1))
                mouse_down=1;
            end

            % Use pixel coordinates to detect point.
            if mouse_down
                [X Y]=ginput(1);
                xdist=xC-X;
                ydist=yC-Y;

                dist = abs(xdist + sqrt(-1) * ydist);
                [row,col] = find(dist == min(min(dist)));
                thePointIndex = sub2ind(size(varr), row, col);

                set(outline,'xdata',[xdata(thePointIndex) xdata(thePointIndex+1) xdata(thePointIndex+1+ud) xdata(thePointIndex+ud) xdata(thePointIndex)], ...
                    'ydata',[ydata(thePointIndex) ydata(thePointIndex+1) ydata(thePointIndex+1+ud) ydata(thePointIndex+ud) ydata(thePointIndex)]);

                if (enable_write)
                    varr(thePointIndex)=str2num(get(input_value,'string'));
                    set(grid_plot,'cdata',varr)
                    colorbar

                    if varr_depth
                        h_temp=h_full_grid(thePointIndex);
                        h_full_grid(thePointIndex)=varr(thePointIndex);
                    elseif varr_mask
                        mask_temp=mask_rho_full_grid(thePointIndex);
                        mask_rho_full_grid(thePointIndex)=varr(thePointIndex);
                        % create array mask_rho_full_grid_nan which is mask_rho with nan's at all land points
                        z_size=size(mask_rho_full_grid);
                        mask_rho_full_grid_nan=mask_rho_full_grid(:);
                        zz=find(mask_rho_full_grid_nan==0);
                        mask_rho_full_grid_nan(zz)=nan;
                        mask_rho_full_grid_nan=reshape(mask_rho_full_grid_nan,z_size);
                    end

%                     save roms_grid_adjust2.mat
                elseif (enable_collect)
                    len=length(collect_data);
                    collect_data(len+1)=varr(thePointIndex);
                end

                set(output_value, 'string',num2str(varr(thePointIndex)))
                set(output_ind, 'string',sprintf('%d , %d',row, col))
            end
            set(grid_plot,'cdata',varr)
            colorbar

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'mouse_up'
            mouse_down=0;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'motion'
            if (varr_lines + mouse_down == 2)
                %        if ~exist('mouse_down'); mouse_down='n'; end
                xy = get(gca, 'CurrentPoint');
                xdata=get(grid_plot,'xdata');
                xdata_old=xdata;
                x_size=size(xdata);
                xdata=xdata(:);
                ydata=get(grid_plot,'ydata');
                ydata_old=ydata;
                y_size=size(ydata);
                ydata=ydata(:);
                % update perimeter data with the new location
                xdata(thePointIndex)=xy(1,1);
                ydata(thePointIndex)=xy(1,2);
                xdata=reshape(xdata,[x_size]);
                ydata=reshape(ydata,[y_size]);
                set(grid_plot,'xdata',xdata,'ydata',ydata)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'overwrite_tool'
            if enable_collect==0 && enable_write ==0
                enable_write=1;
                set(collect_tool, 'Enable', 'off')
            elseif enable_collect==0 && enable_write ==1
                set(collect_tool, 'Enable', 'on')
                enable_write=0;
            end
            
        case 'collect_tool'
            if enable_collect==0 && enable_write ==0
                enable_collect=1;
                set(overwrite_tool, 'Enable', 'off')
                set(collect_tool, 'string','Export values')
            elseif enable_collect==1 && enable_write ==0
                set(overwrite_tool, 'Enable', 'on')
                assignin('caller', 'zdata', collect_data)
                set(collect_tool, 'string','Get values')
                collect_data=[];
                enable_collect=0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'save_data'

            %  roms_grid_adjust_write_grid(ncfile)   %  this alos adjusts grid dimensions, may not be correct

            if (1)
                nc=netcdf(ncfile_name,'write');
                nc{'h'}(:)=h_full_grid(1:end-1,1:end-1);
                LP=size(h_full_grid,2)-1;
                MP=size(h_full_grid,1)-1;
                rmask=mask_rho_full_grid(1:end-1,1:end-1);
                umask = zeros(size(rmask));
                vmask = zeros(size(rmask));
                pmask = zeros(size(rmask));

                for i = 2:LP
                    for j = 1:MP
                        umask(j, i-1) = rmask(j, i) * rmask(j, i-1);
                    end
                end
                for i = 1:LP
                    for j = 2:MP
                        vmask(j-1, i) = rmask(j, i) * rmask(j-1, i);
                    end
                end
                for i = 2:LP
                    for j = 2:MP
                        pmask(j-1, i-1) = rmask(j, i) * rmask(j, i-1) * rmask(j-1, i) * rmask(j-1, i-1);
                    end
                end
                nc{'mask_rho'}(:) = rmask;
                nc{'mask_psi'}(:) = pmask(1:end-1, 1:end-1);
                nc{'mask_u'}(:) = umask(1:end, 1:end-1);
                nc{'mask_v'}(:) = vmask(1:end-1, 1:end);

                ncclose(ncfile)
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'undo_tool'
            if varr_depth
                h_temp2=h_full_grid(thePointIndex);
                h_full_grid(thePointIndex)=h_temp;
                varr(thePointIndex)=h_temp;
                h_temp=h_temp2;
            elseif varr_mask
                mask_temp2=mask_rho_full_grid(thePointIndex);
                mask_rho_full_grid(thePointIndex)=mask_temp;
                varr(thePointIndex)=mask_temp;
                mask_temp=mask_temp2;
            end
            set(grid_plot,'cdata',varr)
            colorbar
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'adjust_tool'
            zdepth=get(adjust_depth_tool,'value');
            zmask=get(adjust_mask_tool,'value');
            zlines=get(adjust_lines_tool,'value');
            if zmask & ~zdepth   %only mask tool is active
                varr=mask_rho_full_grid;
                %    set(adjust_depth_tool, 'value',[0]);
                varr_depth=0;
                varr_mask=1;
                %    varr_lines=0;
            end
            if ~zmask & zdepth  %only depth tool is active
                varr=h_full_grid;
                varr_depth=1;
                varr_mask=0;
                %   varr_lines=0;
            end
            if zmask & zdepth  %both depth and mask active
                varr=h_full_grid.*mask_rho_full_grid_nan;
                varr_depth=1;
                varr_mask=0;
                %   varr_lines=0;
            end
            if ~zmask & ~zdepth  %neither depth nor mask active
                varr=h_full_grid.*nan;
                varr_depth=0;
                varr_mask=0;
                %   varr_lines=0;
            end
            if zlines            %lines tool active
                varr=h_full_grid.*nan;
                varr_depth=0;
                varr_mask=0;
                varr_lines=1;
                set(outline,'visible','off')
            end
            if ~zlines            %lines tool active
                %    varr=h_full_grid.*nan;
                %    varr_depth=0;
                %    varr_mask=0;
                varr_lines=0;
                set(outline,'visible','on')
            end
            roms_grid_adjust2(1,'mouse_down');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end %switch
end %nargin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%not used stuff down here
if (0)
    ncload('mass_bay_ecom_grid_7.nc');
    nc=netcdf('mass_bay_ecom_grid_7.nc','write');
    dx_new=zeros(size(pm));
    dy_new=dx_new;
    dmde_new=dx_new;
    dndx_new=dx_new;

    dx_new(:,2:67)=sqrt(((x_rho(:,3:end)-x_rho(:,1:end-2))/2).^2 + ...
        ((y_rho(:,3:end)-y_rho(:,1:end-2))/2).^2);
    dx_new(:,1)=sqrt(((x_rho(:,2)-x_rho(:,1))).^2 + ...
        ((y_rho(:,2)-y_rho(:,1))).^2);
    dx_new(:,68)=sqrt(((x_rho(:,68)-x_rho(:,67))).^2 + ...
        ((y_rho(:,68)-y_rho(:,67))).^2);

    dy_new(2:67,:)=sqrt(((x_rho(3:end,:)-x_rho(1:end-2,:))/2).^2 + ...
        ((y_rho(3:end,:)-y_rho(1:end-2,:))/2).^2);
    dy_new(1,:)=sqrt(((x_rho(2,:)-x_rho(1,:))).^2 + ...
        ((y_rho(2,:)-y_rho(1,:))).^2);
    dy_new(68,:)=sqrt(((x_rho(68,:)-x_rho(67,:))).^2 + ...
        ((y_rho(68,:)-y_rho(67,:))).^2);
    pm_new=1./dx_new;
    pn_new=1./dy_new;


    dmde_new(2:end-1, :) = 0.5*(1./pm_new(3:end, :) - 1./pm_new(1:end-2, :));
    dmde_new(1, :) = dmde_new(2,:);
    dmde_new(end, :) = dmde_new(end-1,:);
    dndx_new(:, 2:end-1) = 0.5*(1./pn_new(:, 3:end) - 1./pn_new(:, 1:end-2));
    dndx_new(:,1) = dndx_new(:,2);
    dndx_new(:,end) = dndx_new(:,end-1);

    nc{'pm'}(:)=1./dx_new(:);
    nc{'pn'}(:)=1./dy_new(:);
    nc{'dmde'}(:)=dmde_new(:);
    nc{'dndx'}(:)=dndx_new(:);
    close(nc)

end
