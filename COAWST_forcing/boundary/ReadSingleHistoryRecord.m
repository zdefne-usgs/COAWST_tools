function TheState=ReadSingleHistoryRecord(HistoryFile, GrdArr, iRecord,nc,thredds)
%
% TheState=ReadSingleHistoryRecord(HistoryFile, GrdArr, iRecord)
% return the state of the ROMS history file HistoryFile
% computed with the ROMS grid array GrdArr
% at iRecord
%
if thredds==0
nc=netcdf(HistoryFile, 'nowrite');
end
%     Day2sec=24*3600;
%     seconds_since=datenum(2012,6,25)*Day2sec;
% 
% t=nc{'time'}(:)*3600 + seconds_since;  

sprintf('Start reading. Elapsed time is %.3f hours', toc/3600)
eTime=nc{'time'}(iRecord);
try 
    xy_rho=length(nc{'xy_rho'});
catch
    xy_rho=-1;
end
if (xy_rho > 0)
  % we have a write water file
  xy_rho=length(nc('xy_rho'));
  xyz_rho=length(nc{'xyz_rho'});
  s_rho=xyz_rho/xy_rho;
  ZETAwp=nc{'zeta'}(iRecord, :);
  TEMPwp=nc{'temp'}(iRecord, :);
  SALTwp=nc{'salt'}(iRecord, :);
  UBARwp=nc{'ubar'}(iRecord, :);
  VBARwp=nc{'vbar'}(iRecord, :);
  Uwp=nc{'u'}(iRecord, :);
  Vwp=nc{'v'}(iRecord, :);
  ZETA=Field2D_wp2usual(GrdArr.MSK_rho, ZETAwp);
  UBAR=Field2D_wp2usual(GrdArr.MSK_u, UBARwp);
  VBAR=Field2D_wp2usual(GrdArr.MSK_v, VBARwp);
  TEMP=Field3D_wp2usual(GrdArr.MSK_rho, s_rho, TEMPwp);
  SALT=Field3D_wp2usual(GrdArr.MSK_rho, s_rho, SALTwp);
  U=Field3D_wp2usual(GrdArr.MSK_u, s_rho, Uwp);
  V=Field3D_wp2usual(GrdArr.MSK_v, s_rho, Vwp);
else
  ZETA=nc{'zeta'}(iRecord, :, :);
  TEMP=nc{'temp'}(iRecord, :, :, :);
  SALT=nc{'salt'}(iRecord, :, :, :);
  UBAR=nc{'ubar'}(iRecord, :, :);
  VBAR=nc{'vbar'}(iRecord, :, :);
  U=nc{'u'}(iRecord, :, :, :);
  V=nc{'v'}(iRecord, :, :, :);
%  s_rho=length(nc('s_rho')(:));
  ZETA(GrdArr.KlandRho)=0;
  UBAR(GrdArr.KlandU)=0;
  VBAR(GrdArr.KlandV)=0;
  TEMP=Field3D_PutToFillVal(GrdArr.MSK_rho, TEMP, 0);
  SALT=Field3D_PutToFillVal(GrdArr.MSK_rho, SALT, 0);
  U=Field3D_PutToFillVal(GrdArr.MSK_u, U, 0);
  V=Field3D_PutToFillVal(GrdArr.MSK_v, V, 0);
end;
%close(nc);
TheState.ZETA=double(ZETA);
TheState.TEMP=double(TEMP);
TheState.SALT=double(SALT);
TheState.UBAR=double(UBAR);
TheState.VBAR=double(VBAR);
TheState.U=double(U);
TheState.V=double(V);
TheState.eTime=double(eTime);
sprintf('Elapsed time is %.3f hours', toc/3600)
