figure
bbleh_coastline('g')
load bbleh_narr_NENA_data_2012 ix iy lons lats
for xi=1:length(ix)
    for eta=1:length(iy)    
        plot(lons(xi), lats(eta), '.')
        text(lons(xi), lats(eta), sprintf('%d,%d',ix(xi), iy(eta)))
    end
end
ylim([min(lats(:)) max(lats(:))])
axis equal
title('NARR grid')
% Grid point near Barnegat Inlet
plot(lons(3),lats(3), 'o') 
set(gcf, 'paperpositionMode', 'auto')
saveas(gcf, 'NARRgrd.png')