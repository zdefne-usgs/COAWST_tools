ncclear
url='http://geoport.whoi.edu/thredds/dodsC/coawst_4/use/fmrc/coawst_4_use_best.ncd';
% url='C:\Users\zdefne\Documents\MATLAB\BB_matlab\RUNS2\bb6\bb7_005\his_bb6.nc';
nc=ncgeodataset(url);
lon=nc{'lon_rho'}(:);
m=nc{'mask_rho'}(:);
lat=nc{'lat_rho'}(:);
lat(m==0)=nan;
lon(m==0)=nan;
dstart=datenum(2012,6,25);
t=nc{'time'}(:)/24 +dstart;

t1=datenum(2012,9,17);
t2=datenum(2012,12,10);
ti1=near(t,t1);
ti2=near(t,t2);
time=t(ti1:ti2);



%% part1
% %5) Enter the spacings of TPAR file locations around the perimeter
% % of the grid. One TPAR file every 'specres' point.
% % ww3_specpoints assumes masking of 0 for land and NaN for water
% specres=10; % spec point resolution
% url1='http://geoport.whoi.edu/thredds/dodsC/clay/usgs/users/zdefne/run072/NOROT/his/roms_his.ncml';
% url1='http://geoport.whoi.edu/thredds/dodsC/clay/usgs/users/zdefne/run072/nest1/roms_his.ncml';
% nc1=ncgeodataset(url1);
% lon1=nc1{'lon_rho'}(:);
% m1=nc1{'mask_rho'}(:);
% lat1=nc1{'lat_rho'}(:);
% lat1(m1==0)=nan;
% lon1(m1==0)=nan;
% dstart1=datenum(2012,9,17);
% t1=nc1{'ocean_time'}(:)/3600/24 +dstart1;
% 
% for i=1:800
%     [ixcn(i), iycn(i)]=find_nearest_point(lon1(i,160),lat1(i,160), lon, lat, m, 'auto');
% end
% for i=1:80
%     etac(i)=mode(iycn(i*10-9:i*10));
%     xic(i)=mode(ixcn(i*10-9:i*10));
% end
% save ij ixcn iycn etac xic

load ij

for i=1:length(etac)
    i
    TPAR(1:length(time),2)=squeeze(nc{'Hwave'}(ti1:ti2,etac(i),xic(i)));
    %         eval(['hst=squeeze(hsnc{''Significant_height_of_combined_wind_waves_and_swell''}(wavet,',irg,',',jrg,'));']);
    %         zz=hst>1000;
    %         hst(zz)=0; %make bad data 0, swan not like NaNs
    %         Z1=interp2(daplon,daplat,hst,gx,gy);
    %         Z1(isnan(Z1))=0;
    %         TPAR(wavet,2)=Z1;
    TPAR(1:length(time),3)=squeeze(nc{'Pwave_top'}(ti1:ti2,etac(i),xic(i)));
    %             eval(['tpt=squeeze(tpnc{''Primary_wave_mean_period''}(wavet,',irg,',',jrg,'));']);
    %             zz=tpt>1000;
    %             tpt(zz)=0; %make bad data 0, swan not like NaNs
    %             Z1=interp2(daplon,daplat,tpt,gx,gy);
    %             Z1(isnan(Z1))=0;
    %             TPAR(wavet,3)=Z1;
    TPAR(1:length(time),4)=squeeze(nc{'Dwave'}(ti1:ti2,etac(i),xic(i)));
    %             eval(['dpt=squeeze(dpnc{''Primary_wave_direction''}(wavet,',irg,',',jrg,'));']);
    %             zz=dpt>1000;
    %             dpt(zz)=0; %make bad data 0, swan not like NaNs
    %             Z1=interp2(daplon,daplat,dpt,gx,gy);
    %             Z1(isnan(Z1))=0;
    %             TPAR(wavet,4)=Z1;
    TPAR(1:length(time),5)=20;
    TPAR_time(1:length(time),1)=str2num(datestr(time,'yyyymmdd.HHMM'));
%     l=sprintf('%02d',i);
    l=sprintf('%d',i);
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






