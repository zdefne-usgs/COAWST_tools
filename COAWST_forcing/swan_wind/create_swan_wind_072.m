%% This script takes the output nc file from NAM and writes to SWAN file
ncclear
ncg=netcdf('../grid/bbleh_grid_071_pm08o.nc'); %roms grid name
% r=9;
% c=6;
% ncload('../forcing_bulk_Sandy/bbleh_frc_bulk_Sandy_NAM.nc')
% datname='wind_SandyNAM.dat';
r=6;
c=4;
ncload('../forcing_bulk/bbleh_bulk_NARR_072.nc')
datname='wind_NARR_072.dat';

%roms_angle=ncg{'angle'}(1:15,1:36); %fix for latte, size also
%roms_angle=zeros(15,36);

%[r c]=size(roms_angle); %fix for latte
%This part from BNA
%[windu_rot, windv_rot]=rotation(uwind, vwind, roms_angle); %get you rotation
%% write data to ascii file 
% write windu_rot, windv_rot 
% datname='wind_bulk_050f.dat';
fid = fopen(datname,'w');
for ti=1:length(time)
    for index = 1:r; %changed increment from -1 to 1
        for index2 = 1:c;
            fprintf(fid,'%8.2f',Uwind(ti,index,index2));
        end
        fprintf(fid,'\n');
    end
    for index = 1:r; %changed increment from -1 to 1
        for index2 = 1:c;
            fprintf(fid,'%8.2f',Vwind(ti,index,index2));
        end
        fprintf(fid,'\n');
    end
end