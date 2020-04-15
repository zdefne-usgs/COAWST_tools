function [tind]=NEST_CreateBoundaryFromHistory(...
    PrefixHis, NestingTotalArray, ...
    BeginTimeSec, EndTimeSec, BoundaryFileName,nc,Do3D,thredds)
%
% --StationFileName is the output by ROMS of the run
% --TheOffset is the move in index that is needed to be
%   made (station file are for multiple purposes)
%   TheOffSet=0 if only for this purpose or it is at the beginning.

eta_rho_sma=NestingTotalArray.eta_rho_sma;
xi_rho_sma=NestingTotalArray.xi_rho_sma;
eta_u_sma=NestingTotalArray.eta_u_sma;
xi_u_sma=NestingTotalArray.xi_u_sma;
eta_v_sma=NestingTotalArray.eta_v_sma;
xi_v_sma=NestingTotalArray.xi_v_sma;
%
if thredds==0
    [ListTimeHistory, ListIFile, ListIRecord, nbFile, ListAbsoluteIndex]=...
        ROMShistoryGetInfo2(PrefixHis, BeginTimeSec, EndTimeSec);
else
    
    %     Day2sec=24*3600;
    %     seconds_since=datenum(2012,6,25)*Day2sec;
    %
    % t=nc{'time'}(:)*Day2sec + seconds_since;
    t=nc{'time'}(:)/24 +datenum(2012,6,25);
    tind1=find(t==BeginTimeSec);
    tind2=find(t==EndTimeSec);
    ListTimeHistory=nc{'time'}(tind1:tind2);
    ListIFile=ones(size(ListTimeHistory));
    % ListIRecord=1:length(ListTimeHistory);
    ListIRecord=tind1:tind2;
    tind=tind1:tind2;
    ListIRecord=ListIRecord';
end
nbTime=size(ListTimeHistory,1);
%
s_rho=NestingTotalArray.AddiRecordInfo.Nsma;
[test, reason]=IsMakeableFile(BoundaryFileName);
if (test == 0)
    disp(['We cannot create file ' BoundaryFileName]);
    disp(['For reason : ' reason]);
    keyboard;
end;
ncBound=netcdf(BoundaryFileName, 'clobber');
ncBound('eta_rho')=eta_rho_sma;
ncBound('xi_rho')=xi_rho_sma;
ncBound('eta_u')=eta_u_sma;
ncBound('xi_u')=xi_u_sma;
ncBound('eta_v')=eta_v_sma;
ncBound('xi_v')=xi_v_sma;
ncBound('zeta_time')=nbTime;
ncBound('v2d_time')=nbTime;
if Do3D==1
    ncBound('v3d_time')=nbTime;
    ncBound('temp_time')=nbTime;
    ncBound('salt_time')=nbTime;
end
ncBound('s_rho')=s_rho;
%
ncBound{'zeta_time'}=ncdouble('zeta_time');
ncBound{'v2d_time'}=ncdouble('v2d_time');
if Do3D==1
    ncBound{'v3d_time'}=ncdouble('v3d_time');
    ncBound{'temp_time'}=ncdouble('temp_time');
    ncBound{'salt_time'}=ncdouble('salt_time');
end
%
if (NestingTotalArray.AddiRecordInfo.DoEast == 1)
    ncBound{'zeta_east'}=ncfloat('zeta_time', 'eta_rho');
    if Do3D==1
        ncBound{'temp_east'}=ncfloat('temp_time', 's_rho', 'eta_rho');
        ncBound{'salt_east'}=ncfloat('salt_time', 's_rho', 'eta_rho');
        
        ncBound{'u_east'}=ncfloat('v3d_time', 's_rho', 'eta_u');
        ncBound{'v_east'}=ncfloat('v3d_time', 's_rho', 'eta_v');
        
    end
    ncBound{'ubar_east'}=ncfloat('v2d_time', 'eta_u');
    ncBound{'vbar_east'}=ncfloat('v2d_time', 'eta_v');
    
end;
if (NestingTotalArray.AddiRecordInfo.DoWest == 1)
    ncBound{'zeta_west'}=ncfloat('zeta_time', 'eta_rho');
    if Do3D==1
        ncBound{'temp_west'}=ncfloat('temp_time', 's_rho', 'eta_rho');
        ncBound{'salt_west'}=ncfloat('salt_time', 's_rho', 'eta_rho');
        ncBound{'u_west'}=ncfloat('v3d_time', 's_rho', 'eta_u');
        ncBound{'v_west'}=ncfloat('v3d_time', 's_rho', 'eta_v');
    end
    ncBound{'ubar_west'}=ncfloat('v2d_time', 'eta_u');
    ncBound{'vbar_west'}=ncfloat('v2d_time', 'eta_v');
    
end;
if (NestingTotalArray.AddiRecordInfo.DoNorth == 1)
    ncBound{'zeta_north'}=ncfloat('zeta_time', 'xi_rho');
    if Do3D==1
        ncBound{'temp_north'}=ncfloat('temp_time', 's_rho', 'xi_rho');
        ncBound{'salt_north'}=ncfloat('salt_time', 's_rho', 'xi_rho');
        ncBound{'u_north'}=ncfloat('v3d_time', 's_rho', 'xi_u');
        ncBound{'v_north'}=ncfloat('v3d_time', 's_rho', 'xi_v');
    end
    ncBound{'ubar_north'}=ncfloat('v2d_time', 'xi_u');
    ncBound{'vbar_north'}=ncfloat('v2d_time', 'xi_v');
    
end;
if (NestingTotalArray.AddiRecordInfo.DoSouth == 1)
    ncBound{'zeta_south'}=ncfloat('zeta_time', 'xi_rho');
    if Do3D==1
        ncBound{'temp_south'}=ncfloat('temp_time', 's_rho', 'xi_rho');
        ncBound{'salt_south'}=ncfloat('salt_time', 's_rho', 'xi_rho');
        ncBound{'u_south'}=ncfloat('v3d_time', 's_rho', 'xi_u');
        ncBound{'v_south'}=ncfloat('v3d_time', 's_rho', 'xi_v');
    end
    ncBound{'ubar_south'}=ncfloat('v2d_time', 'xi_u');
    ncBound{'vbar_south'}=ncfloat('v2d_time', 'xi_v');
    
end;

for iTime=1:nbTime
    iFile=ListIFile(iTime,1);
    iRecord=ListIRecord(iTime,1)
    HistoryFile=[PrefixHis StringNumber(iFile, 4) '.nc'];
    
    chk=0;
    ctr=0
    while chk~=1;
        try
            TheState=ReadSingleHistoryRecord(...
                HistoryFile, NestingTotalArray.GrdArrBig, iRecord,nc,thredds);
            chk=1;
        catch err
            waitdur=1;
            ctr= ctr+1;
            sprintf('%s\n', err.message)
            sprintf('Attempt %d in %d minutes', ctr, waitdur)
            pause(waitdur*60)
        end
    end
    
    disp(['iTime=' num2str(iTime)]);
    fprintf('Date on record + date start for input file=\n %s + %s = %s\n',...
        datestr(TheState.eTime/24), datestr(datenum(2012,6,25)), datestr(TheState.eTime/24+datenum(2012,6,25)));
    eTime=TheState.eTime/24;
    ncBound{'zeta_time'}(iTime)=eTime;
    ncBound{'v2d_time'}(iTime)=eTime;
    if Do3D==1
        ncBound{'v3d_time'}(iTime)=eTime;
        ncBound{'temp_time'}(iTime)=eTime;
        ncBound{'salt_time'}(iTime)=eTime;
    end
    if (NestingTotalArray.UseSpMat == 1)
        ZETAsma=InterpolSpMat_R2R_2Dfield(TheState.ZETA,...
            NestingTotalArray);
        if Do3D==1
            TEMPsma=InterpolSpMat_R2R_3Dfield(TheState.TEMP,...
                NestingTotalArray);
            SALTsma=InterpolSpMat_R2R_3Dfield(TheState.SALT,...
                NestingTotalArray);
            [Usma, Vsma]=InterpolSpMat_R2R_3Duvfield(NestingTotalArray.ArrayBigSma3Duv, TheState.U, TheState.V);
        end
        [UBARsma, VBARsma]=InterpolSpMat_R2R_2Duvfield(TheState.UBAR, TheState.VBAR,...
            NestingTotalArray);
        
    else
        ZETAsma=InterpolMemEff_R2R_2Dfield(...
            NestingTotalArray, TheState.ZETA);
        TEMPsma=InterpolMemEff_R2R_3Dfield(...
            NestingTotalArray, NestingTotalArray.AddiRecordInfo, ...
            TheState.TEMP);
        SALTsma=InterpolMemEff_R2R_3Dfield(...
            NestingTotalArray, NestingTotalArray.AddiRecordInfo, ...
            TheState.SALT);
        [UBARsma, VBARsma]=InterpolMemEff_R2R_2Duvfield(...
            NestingTotalArray, ...
            TheState.UBAR, TheState.VBAR);
        [Usma, Vsma]=InterpolMemEff_R2R_3Duvfield(...
            NestingTotalArray, NestingTotalArray.AddiRecordInfo, ...
            TheState.U, TheState.V);
    end;
    if (NestingTotalArray.AddiRecordInfo.DoEast == 1)
        ZETAeast=squeeze(ZETAsma(:, xi_rho_sma));
        if Do3D==1
            TEMPeast=squeeze(TEMPsma(:, :, xi_rho_sma));
            SALTeast=squeeze(SALTsma(:, :, xi_rho_sma));
            Ueast=squeeze(Usma(:, :, xi_u_sma));
            Veast=squeeze(Vsma(:, :, xi_v_sma));
        end
        UBAReast=squeeze(UBARsma(:, xi_u_sma));
        VBAReast=squeeze(VBARsma(:, xi_v_sma));
        
        ncBound{'zeta_east'}(iTime, :)=ZETAeast;
        if Do3D==1
            ncBound{'temp_east'}(iTime, :, :)=TEMPeast;
            ncBound{'salt_east'}(iTime, :, :)=SALTeast;
            
            ncBound{'u_east'}(iTime, :, :)=Ueast;
            ncBound{'v_east'}(iTime, :, :)=Veast;
        end
        ncBound{'ubar_east'}(iTime, :)=UBAReast;
        ncBound{'vbar_east'}(iTime, :)=VBAReast;
    end;
    %
    if (NestingTotalArray.AddiRecordInfo.DoWest == 1)
        ZETAwest=squeeze(ZETAsma(:, 1));
        if Do3D==1
            TEMPwest=squeeze(TEMPsma(:, :, 1));
            SALTwest=squeeze(SALTsma(:, :, 1));
            Uwest=squeeze(Usma(:, :, 1));
            Vwest=squeeze(Vsma(:, :, 1));
        end
        UBARwest=squeeze(UBARsma(:, 1));
        VBARwest=squeeze(VBARsma(:, 1));
        
        ncBound{'zeta_west'}(iTime, :)=ZETAwest;
        if Do3D==1
            ncBound{'temp_west'}(iTime, :, :)=TEMPwest;
            ncBound{'salt_west'}(iTime, :, :)=SALTwest;
            ncBound{'u_west'}(iTime, :, :)=Uwest;
            ncBound{'v_west'}(iTime, :, :)=Vwest;
        end
        ncBound{'ubar_west'}(iTime, :)=UBARwest;
        ncBound{'vbar_west'}(iTime, :)=VBARwest;
        
    end;
    %
    if (NestingTotalArray.AddiRecordInfo.DoSouth == 1)
        ZETAsouth=squeeze(ZETAsma(1, :));
        if Do3D==1
            TEMPsouth=squeeze(TEMPsma(:, 1, :));
            SALTsouth=squeeze(SALTsma(:, 1, :));
            Usouth=squeeze(Usma(:, 1, :));
            Vsouth=squeeze(Vsma(:, 1, :));
        end
        UBARsouth=squeeze(UBARsma(1, :));
        VBARsouth=squeeze(VBARsma(1, :));
        
        ncBound{'zeta_south'}(iTime, :)=ZETAsouth;
        if Do3D==1
            ncBound{'temp_south'}(iTime, :, :)=TEMPsouth;
            ncBound{'salt_south'}(iTime, :, :)=SALTsouth;
            ncBound{'u_south'}(iTime, :, :)=Usouth;
            ncBound{'v_south'}(iTime, :, :)=Vsouth;
        end
        ncBound{'ubar_south'}(iTime, :)=UBARsouth;
        ncBound{'vbar_south'}(iTime, :)=VBARsouth;
        
    end;
    %
    if (NestingTotalArray.AddiRecordInfo.DoNorth == 1)
        ZETAnorth=squeeze(ZETAsma(eta_rho_sma,:));
        if Do3D==1
            TEMPnorth=squeeze(TEMPsma(:, eta_rho_sma,:));
            SALTnorth=squeeze(SALTsma(:, eta_rho_sma,:));
            Unorth=squeeze(Usma(:, eta_u_sma,:));
            Vnorth=squeeze(Vsma(:, eta_v_sma,:));
        end
        UBARnorth=squeeze(UBARsma(eta_u_sma,:));
        VBARnorth=squeeze(VBARsma(eta_v_sma,:));
        
        ncBound{'zeta_north'}(iTime, :)=ZETAnorth;
        if Do3D==1
            ncBound{'temp_north'}(iTime, :, :)=TEMPnorth;
            ncBound{'salt_north'}(iTime, :, :)=SALTnorth;
            ncBound{'u_north'}(iTime, :, :)=Unorth;
            ncBound{'v_north'}(iTime, :, :)=Vnorth;
        end
        ncBound{'ubar_north'}(iTime, :)=UBARnorth;
        ncBound{'vbar_north'}(iTime, :)=VBARnorth;
        
    end;
end;
close(ncBound);
