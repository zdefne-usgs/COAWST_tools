ncclear
% % spring 2012
% load bbleh_NAM_data
% t_start=datenum(2012,3,1); % time is with respect to ROMS dstart
% t_end=datenum(2012,6,1); 

% Sandy
% load bbleh_nam_data_sandy
% t_start=datenum(2012,10,1); % time is with respect to ROMS dstart
% t_end=datenum(2012,12,1); 

% Sandy run
% load bbleh_nam_data_2012
load bbleh_narr_NENA_data_2012

t_start=datenum(2012,9,17); % time is with respect to ROMS dstart
t_end=datenum(2012,12,10); 
nx=size(lwrad,3);
ny=size(lwrad,2);
display(['Model reference time: ' datestr(t_start)])
istart= find(time==t_start);
iend= find(time==t_end);
time=time(istart:iend);
time = time - t_start ; % model time starts from zero
 
fname='bbleh_bulk_NARR_072.nc'
create_roms_native_netcdf_blk(nx,ny,(iend-istart)+1, fname, ...
   'swrad', 'lwrad', 'time', 'Qair', 'Pair', 'Tair', 'Uwind', 'Vwind','rain', 'lat', 'lon')

 
swrad=swrad(istart:iend,:,:);
lwrad=lwrad(istart:iend,:,:);
% lwrad_down=lwrad_down(istart:iend,:,:);
Qair=Qair(istart:iend,:,:);
Pair=Pair(istart:iend,:,:);
Tair=Tair(istart:iend,:,:);
Uwind=Uwind(istart:iend,:,:);
Vwind=Vwind(istart:iend,:,:);
rain=rain(istart:iend,:,:);

swrad(swrad<0)=0;
rain(rain<0)=0;



% nc=netcdf.open('frc_bulk.nc','NC_WRITE');
% 
% netcdf.reDef(nc)
% varID = netcdf.inqVarID(nc, 'time');
% netcdf.putAtt(nc,varID,'units',['days since ' datestr(t_start)])
% netcdf.close(nc)

nc=netcdf(fname,'write');
nc{'swrad'}(:)=swrad;
nc{'lwrad'}(:)=lwrad;
% nc{'lwrad_down'}(:)=lwrad_down;
nc{'time'}(:)=time;
nc{'Qair'}(:)=Qair;
nc{'Pair'}(:)=Pair;
nc{'Tair'}(:)=Tair;
nc{'Uwind'}(:)=Uwind;
nc{'Vwind'}(:)=Vwind;
nc{'rain'}(:)=rain;
nc{'lat'}(:)=lats;
nc{'lon'}(:)=lons;
close(nc)