% script ww3_swan_input.m
%
% This script is the main driver to
% download, convert and interpolate WW3 data to TPAR input for SWAN.
%
% Written 4/23/09 by Brandy Armstrong
% some mods, jcwarner Arpil 27, 2009
%
% READ THE INSTRUCTIONS IN THE COAWST MANUAL
% FOR SWAN BC's SECTION 10.
%
% First, acquire the necessary grib files from
% ftp://polar.ncep.noaa.gov/pub/history/waves/
%

% ************* BEGIN USER INPUT   ****************************

%1) Enter WORKING DIRECTORY.
% This is the location of ww3 grb files downloaded and the
% location of output for the TPAR files to be created.
% ***WARNING***
% The TPAR files created are saved in the working directory and are named
% generically (numbered). Any existing TPAR files will be overwritten !!!!
%
% mkdir('TPAR');
% cd(pwd)
%2) Enter dates of data requested.
yearww3='2012';    %input year of data yyyy
mmww3='03';       %input month of data mm
ddww3='00';        %keep this as '00'

%3) Enter the ww3 grid area
ww3_area='multi_1.at_4m';    %western north atlantic

%4) Enter path\name of SWAN netcdf grid. This is typically the same
% as the roms grid.
modelgrid='../grid/bbleh_grid_071tR.nc';

%5) Enter the spacings of TPAR file locations around the perimeter
% of the grid. One TPAR file every 'specres' point.
% ww3_specpoints assumes masking of 0 for land and NaN for water
specres=10; % spec point resolution

% flag for simulations that change month (e.g., goes from October 10 to
% November 20)
% long_run=0;  % DEFAULT

total_number_months=7; % total number of months
% (not the length of the run, but rather the number
% of grib files)


% *************END OF USER INPUT****************************

% for kk=3:9
%     mmww3=sprintf('%02d',kk)
    drname=[yearww3,mmww3,'/TPAR*.txt']
    D=dir(drname);
    dn={D.name}';
    [y,i]=sort(dn);
    D=D(i);
    specdr=sprintf('spec%d', specres);
    mkdir(specdr)
    
    for itp=1:length(D)
        data=[];
        tparname=[yearww3,mmww3,'/',D(itp).name]
        [pfid,message]=fopen(tparname);
        tline = fgetl(pfid);
        while 1
            tline = fgetl(pfid);
            if ~ischar(tline), break, end
            data=[data;str2num(tline)];
        end
        %         dum=fgets(pfid);
        %         data=fscanf(pfid,'%f %f %f %f %f',[5 inf])';
        %         C=textscan(pfid,'','headerlines',1);
        %         if ~isempty(find(isnan(C{3}),1))
        %             C=textscan(pfid,'%f%f%f%f.%f','headerlines',1);
        %         end
        %         data=cell2mat(C);
        fclose(pfid);
        for im=1:total_number_months-1
            yymm=datestr(datenum(str2double(yearww3),str2double(mmww3)+im,1),'yyyymm')
            [pfid,message]=fopen([yymm,'/',D(itp).name]);
            tline = fgetl(pfid);
            while 1
                tline = fgetl(pfid);
                if ~ischar(tline), break, end
                data=[data;str2num(tline)];
            end
            fclose(pfid);
        end
        [CA,IA,IC] = unique(data(:,1));
        data=data(IA,:);
        
        [pfid,message]=fopen(fullfile(specdr, D(itp).name),'w');
        fprintf(pfid,'TPAR \n');
        fprintf(pfid,'%8.4f %3.2f %3.2f %3.1f %2.0f\n',data');
        fclose(pfid);
        
    end
    
% end