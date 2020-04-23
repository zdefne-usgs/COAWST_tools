ncclear
time=[];

load NAM_bbleh
%% For earlier years
folder_adress='http://tds.marine.rutgers.edu:8080/thredds/dodsC/met/ncdc-nam-3hour/';
yearstamp='_2012';
model='_nam_';
url=[folder_adress 'lwrad_down' model '3hourly_MAB_and_GoM' yearstamp '.nc']


% %% For most recent data in this year
% NAM (3 hourly forecast) UPDATED DAILY: NCEP North American Mesoscale model/
% folder_adress='http://tds.marine.rutgers.edu:8080/thredds/dodsC/met/ncep-nam-3hour/';
% yearstamp=[];
% url=[folder_adress 'swrad_ncepnam_3hourly_MAB_and_GoM' yearstamp '.nc']
% model='_ncepnam_';

nc=ncgeodataset(url);
time=nc{'time'}(:)+datenum(2006,1,1,0,0,0);%data are referenced to 1/1/2006

for i=1:length(ix)
    for j=1:length(iy)
        [i,j]

        url=[folder_adress 'swrad' model '3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        swrad(:,j,i)=nc{'swrad'}(:,iy(j),ix(i)); % (time, lat, lon)
        
        url=[folder_adress 'lwrad' model '3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        lwrad(:,j,i)=nc{'lwrad'}(:,iy(j),ix(i));
        
        url=[folder_adress 'lwrad_down' model '3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        lwrad_down(:,j,i)=nc{'lwrad_down'}(:,iy(j),ix(i));
        
        url=[folder_adress 'Uwind' model '3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        Uwind(:,j,i)=nc{'Uwind'}(:,iy(j),ix(i));
        
        url=[folder_adress 'Vwind' model '3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        Vwind(:,j,i)=nc{'Vwind'}(:,iy(j),ix(i));
        
        url=[folder_adress 'Tair' model '3hourly_MAB_and_GoM' yearstamp '.nc']
%         url=[folder_adress 'Tair_3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        Tair(:,j,i)=nc{'Tair'}(:,iy(j),ix(i));
        
        url=[folder_adress 'Pair' model '3hourly_MAB_and_GoM' yearstamp '.nc']
%         url=[folder_adress 'Pair_3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        Pair(:,j,i)=nc{'Pair'}(:,iy(j),ix(i));
        
        url=[folder_adress 'Qair' model '3hourly_MAB_and_GoM' yearstamp '.nc']
%         url=[folder_adress 'Qair_3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        Qair(:,j,i)=nc{'Qair'}(:,iy(j),ix(i));
        
        url=[folder_adress 'rain' model '3hourly_MAB_and_GoM' yearstamp '.nc']
%         url=[folder_adress 'rain_3hourly_MAB_and_GoM' yearstamp '.nc']
        nc=ncgeodataset(url);
        rain(:,j,i)=nc{'rain'}(:,iy(j),ix(i));
    end
end

save(['bbleh' model 'data' num2str(now) '.mat'])
% write_nam_bbleh


% nc{'time'}(1:length(time))=time-733956;
% nc{'swrad'}(256:end,:,:)=500;
% nc{'lwrad'}(256:end,:,:)=500;
% nc{'Pair'}(256:end,:,:)=1000;
% nc{'Tair'}(256:end,:,:)=20;
% nc{'Qair'}(256:end,:,:)=80;
% nc{'Uwind'}(256:end,:,:)=0;
% nc{'Vwind'}(256:end,:,:)=0;
%
% ncclose
