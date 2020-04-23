function create_roms_native_netcdf_blk(nx,ny,ti,fn,varargin)
% 
% Create NetCDF file using native netcdf builtins for bulk fluxes from NAM 3-hourly output  
% 
% Usage:
% create_roms_native_netcdf_blk(nx,ny,ti,fn,varargin)
% 
% Accepts number of indices and number of time steps and the desired parameter(s) as input 
% Select any combination of the following parameters
% Uwind: surface u-wind component (m/s)
% Vwind: surface v-wind component (m/s)
% Pair: surface air pressure (mbar)
% Tair: surface air temperature (Celsius)
% Qair: surface air relative humidity (%)
% rain: rain fall rate (kg/m2/s)
% swrad: solar shortwave radiation (W/m2)
% lwrad: solar longwave radiation (W/m2)
% 
% e.g. 
% create_roms_native_netcdf_blk(6,9,1757, 'frc_bulk.nc', 'Uwind', 'Vwind')
% 
% create_roms_native_netcdf_blk(6,9,737, 'frc_bulk.nc','Uwind','Vwind','Tair','Qair','rain','swrad','lwrad','Pair')

% Zafer Defne   04/30/2012

nc=netcdf.create(fn,'clobber');
if isempty(nc), return, end

disp(' ## Defining Global Attributes...')
netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'history', ['Created by ' mfilename ' on ' datestr(now)]);
netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'type', 'bulk fluxes forcing file from http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/met/ncdc-nam-3hour/');

% Dimensions:
disp(' ## Defining Dimensions...')
%dimid = netcdf.defDim(ncid,dimname,dimlen)

lon_dimID = netcdf.defDim(nc,'lon',nx);
lat_dimID = netcdf.defDim(nc,'lat',ny);
t_dimID = netcdf.defDim(nc,'time',ti);
% onedimID = netcdf.defDim(nc,'one',1);

% Variables and attributes:
disp(' ## Defining Variables, and Attributes...')
%varid = netcdf.defVar(ncid,varname,xtype,dimids)
%netcdf.putAtt(ncid,varid,attrname,attrvalue)

tID = netcdf.defVar(nc,'time','double',t_dimID);
netcdf.putAtt(nc,tID,'long_name','atmospheric forcing time');
netcdf.putAtt(nc,tID,'units','days');
% netcdf.putAtt(nc,tID,'field','time, scalar, series');

lonID = netcdf.defVar(nc,'lon','double',lon_dimID);
netcdf.putAtt(nc,lonID,'long_name','longitude');
netcdf.putAtt(nc,lonID,'units','degrees_east');
netcdf.putAtt(nc,lonID,'field','xp, scalar, series');

latID = netcdf.defVar(nc,'lat','double',lat_dimID);
netcdf.putAtt(nc,latID,'long_name','latitude');
netcdf.putAtt(nc,latID,'units','degrees_north');
netcdf.putAtt(nc,latID,'field','yp, scalar, series');

if sum(strcmpi(varargin,'Uwind'))>0
% Uwt_dimID = netcdf.defDim(nc,'Uwind_time',ti);
% UwtID = netcdf.defVar(nc,'Uwind_time','double',Uwt_dimID);
% netcdf.putAtt(nc,UwtID,'long_name','Uwind_time');
% netcdf.putAtt(nc,UwtID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,UwtID,'field','Uwind_time, scalar, series');

% UwindID = netcdf.defVar(nc,'Uwind','double',[lon_dimID lat_dimID Uwt_dimID]);
UwindID = netcdf.defVar(nc,'Uwind','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,UwindID,'long_name','surface u-wind component');
netcdf.putAtt(nc,UwindID,'units','meter second-1');
netcdf.putAtt(nc,UwindID,'field','Uwind, scalar, series');
netcdf.putAtt(nc,UwindID,'time','time');
netcdf.putAtt(nc,UwindID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'Vwind'))>0
% Vwt_dimID = netcdf.defDim(nc,'Vwind_time',ti);
% VwtID = netcdf.defVar(nc,'Vwind_time','double',Vwt_dimID);
% netcdf.putAtt(nc,VwtID,'long_name','Vwind_time');
% netcdf.putAtt(nc,VwtID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,VwtID,'field','Vwind_time, scalar, series');
% 
% VwindID = netcdf.defVar(nc,'Vwind','double',[lon_dimID lat_dimID Vwt_dimID]);
VwindID = netcdf.defVar(nc,'Vwind','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,VwindID,'long_name','surface v-wind component');
netcdf.putAtt(nc,VwindID,'units','meter second-1');
netcdf.putAtt(nc,VwindID,'field','Vwind, scalar, series');
netcdf.putAtt(nc,VwindID,'time','time');
netcdf.putAtt(nc,VwindID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'Pair'))>0
% Pat_dimID = netcdf.defDim(nc,'Pair_time',ti);
% PatID = netcdf.defVar(nc,'Pair_time','double',Pat_dimID);
% netcdf.putAtt(nc,PatID,'long_name','Pair_time');
% netcdf.putAtt(nc,PatID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,PatID,'field','Pair_time, scalar, series');
% 
% PairID = netcdf.defVar(nc,'Pair','double',[lon_dimID lat_dimID Pat_dimID]);
PairID = netcdf.defVar(nc,'Pair','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,PairID,'long_name','surface air pressure');
netcdf.putAtt(nc,PairID,'units','millibar');
netcdf.putAtt(nc,PairID,'field','Pair, scalar, series');
netcdf.putAtt(nc,PairID,'time','time');
netcdf.putAtt(nc,PairID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'Tair'))>0
% Tat_dimID = netcdf.defDim(nc,'Tair_time',ti);
% TatID = netcdf.defVar(nc,'Tair_time','double',Tat_dimID);
% netcdf.putAtt(nc,TatID,'long_name','Tair_time');
% netcdf.putAtt(nc,TatID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,TatID,'field','Tair_time, scalar, series');
% 
% TairID = netcdf.defVar(nc,'Tair','double',[lon_dimID lat_dimID Tat_dimID]);
TairID = netcdf.defVar(nc,'Tair','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,TairID,'long_name','surface air temperature');
netcdf.putAtt(nc,TairID,'units','Celsius');
netcdf.putAtt(nc,TairID,'field','Tair, scalar, series');
netcdf.putAtt(nc,TairID,'time','time');
netcdf.putAtt(nc,TairID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'Qair'))>0
% Qat_dimID = netcdf.defDim(nc,'Qair_time',ti);
% QatID = netcdf.defVar(nc,'Qair_time','double',Qat_dimID);
% netcdf.putAtt(nc,QatID,'long_name','Qair_time');
% netcdf.putAtt(nc,QatID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,QatID,'field','Qair_time, scalar, series');
% 
% QairID = netcdf.defVar(nc,'Qair','double',[lon_dimID lat_dimID Qat_dimID]);
QairID = netcdf.defVar(nc,'Qair','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,QairID,'long_name','surface air relative humidity');
netcdf.putAtt(nc,QairID,'units','percentage');
netcdf.putAtt(nc,QairID,'field','Qair, scalar, series');
netcdf.putAtt(nc,QairID,'time','time');
netcdf.putAtt(nc,QairID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'rain'))>0
% rt_dimID = netcdf.defDim(nc,'rain_time',ti);
% rtID = netcdf.defVar(nc,'rain_time','double',rt_dimID);
% netcdf.putAtt(nc,rtID,'long_name','rain_time');
% netcdf.putAtt(nc,rtID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,rtID,'field','rain_time, scalar, series');
% 
% rainID = netcdf.defVar(nc,'rain','double',[lon_dimID lat_dimID rt_dimID]);
rainID = netcdf.defVar(nc,'rain','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,rainID,'long_name','rain fall rate');
netcdf.putAtt(nc,rainID,'units','kilogram meter-2 second-1');
netcdf.putAtt(nc,rainID,'field','rain, scalar, series');
netcdf.putAtt(nc,rainID,'time','time');
netcdf.putAtt(nc,rainID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'swrad'))>0
% swrt_dimID = netcdf.defDim(nc,'swrad_time',ti);
% swrtID = netcdf.defVar(nc,'swrad_time','double',swrt_dimID);
% netcdf.putAtt(nc,swrtID,'long_name','swrad_time');
% netcdf.putAtt(nc,swrtID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,swrtID,'field','swrad_time, scalar, series');
% 
% swradID = netcdf.defVar(nc,'swrad','double',[lon_dimID lat_dimID swrt_dimID]);
swradID = netcdf.defVar(nc,'swrad','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,swradID,'long_name','solar shortwave radiation');
netcdf.putAtt(nc,swradID,'units','Watts meter-2');
netcdf.putAtt(nc,swradID,'positive_value','downward flux, heating');
netcdf.putAtt(nc,swradID,'negative_value','upward flux, cooling');
netcdf.putAtt(nc,swradID,'field','swrad, scalar, series');
netcdf.putAtt(nc,swradID,'time','time');
netcdf.putAtt(nc,swradID,'coordinates','lon lat');
end

if sum(strcmpi(varargin,'lwrad'))>0
% lwrt_dimID = netcdf.defDim(nc,'lwrad_time',ti);
% lwrtID = netcdf.defVar(nc,'lwrad_time','double',lwrt_dimID);
% netcdf.putAtt(nc,lwrtID,'long_name','lwrad_time');
% netcdf.putAtt(nc,lwrtID,'units','days since 2006-01-01 00:00:0.0');
% netcdf.putAtt(nc,lwrtID,'field','lwrad_time, scalar, series');
% 
% lwradID = netcdf.defVar(nc,'lwrad','double',[lon_dimID lat_dimID lwrt_dimID]);
lwradID = netcdf.defVar(nc,'lwrad','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(nc,lwradID,'long_name','solar longwave radiation');
netcdf.putAtt(nc,lwradID,'units','Watts meter-2');
netcdf.putAtt(nc,lwradID,'positive_value','downward flux, heating');
netcdf.putAtt(nc,lwradID,'negative_value','upward flux, cooling');
netcdf.putAtt(nc,lwradID,'field','lwrad, scalar, series');
netcdf.putAtt(nc,lwradID,'time','time');
netcdf.putAtt(nc,lwradID,'coordinates','lon lat');
end
netcdf.close(nc)