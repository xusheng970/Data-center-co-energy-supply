
[lon1, lat1] =meshgrid(-15:0.25:15, 60:-0.25:45); 
wind_speed_xxx= Results_wind';       

figure;
axesm('MapProjection', 'mercator', 'MapLatLimit', [45 60], 'MapLonLimit', [-15 15]);
gridm off; box off; framem on; 


set(gca, 'xtick', [], 'ytick', []); 

S = gshhs('gshhs_l.b');  

hold on;
num_contours_filled = 40; 
[C, h] = contourfm(lat1, lon1, wind_speed_xxx, num_contours_filled, 'LineStyle', 'none');

colormap("gray"); 

contour_levels = [5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11]; %  wind speed  
%contour_levels = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55,0.6]; %  CF
%contour_levels = [3.5, 3.75, 4, 4.25, 4.5, 4.75, 5,5.25,5.5]; %  LCOH
%contour_levels = [0.111,0.112,0.113,0.114,0.115,0.116,0.117,0.118,0.119,0.120]; %  LCOS
caxis([min(contour_levels), max(contour_levels)]);

h_colorbar=colorbar('Ticks', contour_levels, 'TickLabels', {'<5.0', '5.5','6.0', '6.5','7.0', '7.5','8.0','8.5', '9.0','9.5', '10.0','10.5', '>11.0'}); %  wind speed
%h_colorbar=colorbar('Ticks', contour_levels, 'Location', 'southoutside','TickLabels', {'<0.2', '0.25','0.3', '0.35','0.4', '0.45','0.5','0.55', '>0.6'}); %  CF
%h_colorbar=colorbar('Ticks', contour_levels, 'TickLabels', {'<3.50', '3.75', '4.00', '4.25', '4.50', '4.75','5.00','5.25','>5.50'}); %  LCOH
%h_colorbar=colorbar('Ticks', contour_levels, 'TickLabels', {'<0.111','0.112','0.113','0.114','0.115','0.116','0.117','0.118','0.119','>0.120'}); %  LCOS
set(h_colorbar, 'FontSize', 18);

num_contours_lines = 20; 
contourm(lat1, lon1, wind_speed_xxx, num_contours_lines, 'LineColor', [0.5, 0.5, 0.5], 'LineWidth', 0.1); 


for i = 1:length(S)
    i
    if length(S(i).Lat) == length(S(i).Lon)
        if strcmp(S(i).LevelString, 'land') 
         
            geoshow(S(i).Lat, S(i).Lon, 'DisplayType', 'polygon', 'FaceColor', [0.9 0.95 1], 'EdgeColor', 'none'); 
        end
    end
end


for i = 1:length(S)
    i
    if length(S(i).Lat) == length(S(i).Lon)
        plotm(S(i).Lat, S(i).Lon, 'k', 'LineWidth',1); 
    end
end

