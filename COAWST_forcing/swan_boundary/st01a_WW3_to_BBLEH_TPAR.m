%
% READ THE INSTRUCTIONS IN THE COAWST MANUAL
% FOR SWAN BC's SECTION 10.
%
% First, acquire the necessary grib files from
% ftp://polar.ncep.noaa.gov/pub/history/waves/
%
% ************* BEGIN USER INPUT   ****************************


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

total_number_months=7; % total number of months
% (not the length of the run, but rather the number
% of grib files)

for im=0:total_number_months-1
    mmww3=sprintf('%02d',3+im)
    yymm=[yearww3 mmww3]
%     yymm=datestr(datenum(str2double(yearww3),str2double(mmww3)+im,1),'yyyymm');
    eval(['!mkdir ',yymm])
    
    % Call routine to compute TPAR files.
    
    %this assumes data is historical data and is already downloaded to working
    %directory
    eval(['dpname=''',ww3_area,'.dp.',yearww3,mmww3,'.grb2'';']);
    eval(['hsname=''',ww3_area,'.hs.',yearww3,mmww3,'.grb2'';']);
    eval(['tpname=''',ww3_area,'.tp.',yearww3,mmww3,'.grb2'';']);
    
    dpnc=ncgeodataset(dpname);
    xg=dpnc{'lon'}(:);%lat of ww3 data
    xg(xg>0)=xg(xg>0)-360;
    yg=dpnc{'lat'}(:);%lon of ww3 data
    [xg,yg]=meshgrid(xg,yg);
    time=dpnc{'time'}(:);%time interval 3 hours
    time2=datenum(str2num(yearww3),str2num(mmww3),str2num(ddww3)+1):3/24:datenum(str2num(yearww3),str2num(mmww3),str2num(ddww3)+((length(time)-1)/(24/3))+1);
    time=time2;
    %  limit the length of time.  Could use better logic here
    %  for user to set this in ww3_swan_input file.
    tstart=1; tend=length(time);
    time=time(tstart:tend);
    close(dpnc)
    TPAR=nan(length(time),5);
    
    %determine spec pts from grid
    % specpoints assumes a masking of 0 for land and NaN for water
    
    % [specpts]=ww3_specpoints(modelgrid,specres);
    load speclocIJ ind1 ind2
    
    for i=1:length(ind1)
        %Interpolate the data to each point and create/write TPAR file
        hsnc=ncgeodataset(hsname);
        for wavet=1:length(time)
            TPAR(wavet,2)=squeeze(hsnc{'Significant_height_of_combined_wind_waves_and_swell'}(wavet,ind1(i),ind2(i)));
            %         eval(['hst=squeeze(hsnc{''Significant_height_of_combined_wind_waves_and_swell''}(wavet,',irg,',',jrg,'));']);
            %         zz=hst>1000;
            %         hst(zz)=0; %make bad data 0, swan not like NaNs
            %         Z1=interp2(daplon,daplat,hst,gx,gy);
            %         Z1(isnan(Z1))=0;
            %         TPAR(wavet,2)=Z1;
        end
        close(hsnc);
        %
        tpnc=ncgeodataset(tpname);
        for wavet=1:length(time)
            TPAR(wavet,3)=squeeze(tpnc{'Primary_wave_mean_period'}(wavet,ind1(i),ind2(i)));
%             eval(['tpt=squeeze(tpnc{''Primary_wave_mean_period''}(wavet,',irg,',',jrg,'));']);
%             zz=tpt>1000;
%             tpt(zz)=0; %make bad data 0, swan not like NaNs
%             Z1=interp2(daplon,daplat,tpt,gx,gy);
%             Z1(isnan(Z1))=0;
%             TPAR(wavet,3)=Z1;
        end
        close(tpnc);
        %
        dpnc=ncgeodataset(dpname);
        for wavet=1:length(time)
            TPAR(wavet,4)=squeeze(dpnc{'Primary_wave_direction'}(wavet,ind1(i),ind2(i)));
%             eval(['dpt=squeeze(dpnc{''Primary_wave_direction''}(wavet,',irg,',',jrg,'));']);
%             zz=dpt>1000;
%             dpt(zz)=0; %make bad data 0, swan not like NaNs
%             Z1=interp2(daplon,daplat,dpt,gx,gy);
%             Z1(isnan(Z1))=0;
%             TPAR(wavet,4)=Z1;
        end
        close(dpnc);
        %
        TPAR(1:length(time),5)=20;
        TPAR_time(1:length(time),1)=str2num(datestr(time,'yyyymmdd.HHMM'));
        l=sprintf('%02d',i);
        ofile=['TPAR',l,'.txt'];
        fid=fopen(ofile,'w');
        fprintf(fid,'TPAR \n');
        %   fprintf(fid,'%8.4f         %3.2f        %3.2f     %3.f.       %2.f\n',TPAR');
        for wavet=1:length(time)
            fprintf(fid,'%8.4f',TPAR_time(wavet));
            fprintf(fid,'         %3.2f        %3.2f     %3.1f       %2.f\n',TPAR(wavet,2:5)');
        end
        fclose(fid);
    end
    
    
    %         bdry_com %script writes out file Bound_spec_command to working directory
    %         display('BOUNDSPEC command lines can be found in the file Bound_spec_command');
    %         display('You must copy the lines from that file into your SWAN INPUT file');
    
    eval(['!mv TPAR*.txt ',yymm,'/.'])
end




