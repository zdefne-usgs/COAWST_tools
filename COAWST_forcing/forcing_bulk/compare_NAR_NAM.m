clear
close all
% parname='swrad'
% parname='rain'
% parname='lwrad'
% parname='Pair'
% parname='Tair'
% parname='Qair'
% parname='Wind Speed'
parname='Wind Direction'

date1=datenum(2012, 10,1);
date2=datenum(2012, 12,1);
% WQ modeling
% date1=datenum(2012, 5,1);
% date2=datenum(2012, 7,1);

r=load('bbleh_narr_NENA_data_2012');
m=load('bbleh_nam_data_2012');
it1r=near(r.time, date1);
it2r=near(r.time, date2);
it1m=near(m.time, date1);
it2m=near(m.time, date2);

if strcmpi(parname, 'Wind Speed')
    u=getfield(r, 'Uwind');
    v=getfield(r, 'Vwind');
    parr=abs(u+i*v);
    u=getfield(m, 'Uwind');
    v=getfield(m, 'Vwind');
    parm=abs(u+i*v);
elseif strcmpi(parname, 'Wind Direction')
    u=getfield(r, 'Uwind');
    v=getfield(r, 'Vwind');
    parr=atan(u./v);
    u=getfield(m, 'Uwind');
    v=getfield(m, 'Vwind');
    parm=atan(u./v);
else
    parr=getfield(r, parname);
    parm=getfield(m, parname);
end
plot(r.time(it1r:it2r), parr(it1r:it2r, 3,3), m.time(it1m:it2m), parm(it1m:it2m,5,5), 'r--')
title(parname)
legend('NARR', 'NAM')
axis tight
plotwide
datedd
set(gcf, 'paperpositionMode', 'auto')
saveas(gcf, [parname '_NARR_vs_NAM.png'])

if strcmpi(parname, 'Wind Direction')
    u=getfield(r, 'Uwind');
    v=getfield(r, 'Vwind');
    Vr=abs(u+i*v);
    u=getfield(m, 'Uwind');
    v=getfield(m, 'Vwind');
    Vm=abs(u+i*v);
figure
wind_rose(parm(it1r:it2r, 3,3)/pi*360, Vm(it1r:it2r, 3,3),'dtype','meteo', 'n', 12)
title('NAM')
set(gcf, 'paperpositionMode', 'auto')
saveas(gcf, [parname '_NAMrose.png'])
figure
wind_rose(parr(it1r:it2r, 3,3)/pi*360, Vr(it1r:it2r, 3,3),'dtype','meteo', 'n', 12)
title('NARR')
set(gcf, 'paperpositionMode', 'auto')
saveas(gcf, [parname '_NARRrose.png'])
end
