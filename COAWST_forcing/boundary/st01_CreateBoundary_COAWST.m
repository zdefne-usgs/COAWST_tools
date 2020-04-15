%enter parent domain grid file
BigGridFile='USeast_grd19.nc';
BigGridFile='USEast_grd31.nc';
%enter child domain grid file
SmallGridFile='GSB_55.nc';
% do you want 3D u,v,t,s fields for forcing?
Do3D=1;
%are you using thredds or his files?
thredds=1;

AddiRecordInfo.BigThetaS=5.0; % COAWST
AddiRecordInfo.BigThetaB=0.4;
AddiRecordInfo.Nbig=16;
AddiRecordInfo.Bighc=5;
%
AddiRecordInfo.SmaThetaS=0.0;
AddiRecordInfo.SmaThetaB=0.0;
AddiRecordInfo.Nsma=7;
AddiRecordInfo.Smahc=0;
%
%which boundaries do you need forcing for?
AddiRecordInfo.DoEast=1;
AddiRecordInfo.DoWest=0;
AddiRecordInfo.DoNorth=1;
AddiRecordInfo.DoSouth=1;

%forcing times
Day2sec=24*3600;
BeginTimeDay=datenum(2012, 9, 30, 0 , 0, 0);
EndTimeDay=datenum(2012, 10, 1,  0, 0, 0);

seconds_since=datenum(2012,6,25)*Day2sec; 

fprintf('Begin time: %s\nEnd time: %s\nSeconds since: %s\n',...
    datestr(datenum(BeginTimeDay)),datestr(datenum(EndTimeDay)),datestr(datenum(seconds_since/Day2sec)));
	
% BeginTimeDay=DATE_ConvertVect2mjd(BeginTime);
% EndTimeDay=DATE_ConvertVect2mjd(EndTime);
BeginTimeSec=BeginTimeDay*Day2sec;
EndTimeSec=EndTimeDay*Day2sec;


% PrefixHis????.nc (history file of the roms model)
% StationFileName (station file output of the roms model)
UseSta=0;
UseHis=1;

%only if not using thredds
PrefixHis='his_';
%%
if (UseHis == 1)
    %new forcing file name 
    TheBoundaryFile='GSB_55_boundary_COAWST.nc';
  UseSpMat=1;
  if thredds==1
    %catalog url for parent model output
    url='http://geoport.whoi.edu/thredds/dodsC/coawst_4/use/fmrc/coawst_4_use_best.ncd';

    nc=ncgeodataset(url); 
  else
      nc=1;
  end
  NestingTotalArray=NEST_CreateNestingTotalArray(...
      BigGridFile, SmallGridFile, AddiRecordInfo, UseSpMat);

save part1
tic
load part1
      url='http://geoport.whoi.edu/thredds/dodsC/coawst_4/use/fmrc/coawst_4_use_best.ncd';

nc=ncgeodataset(url); 
  NEST_CreateBoundaryFromHistory(... % make sure the time stamp is right
      PrefixHis, NestingTotalArray, ...
      BeginTimeDay, EndTimeDay, TheBoundaryFile,nc,Do3D,thredds);
  toc/3600
end;
