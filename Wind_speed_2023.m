function specific_wind_speed_1D=Wind_speed_2023()

filename = 'Dogger_Bank_wind.nc';  

info = ncinfo(filename);

disp('Dimensions:');
disp(info.Dimensions);

disp('Variables:');
disp(info.Variables);

lat = ncread(filename, 'latitude');  
lon = ncread(filename, 'longitude');  

u10 = ncread(filename, 'u10');  
v10 = ncread(filename, 'v10'); 


wind_speed = sqrt(u10.^2 + v10.^2);


lat_index = find(lat == 54.5);
lon_index = find(lon == 1);

specific_wind_speed = wind_speed(lon_index,lat_index, :);

specific_wind_speed_1D = squeeze(specific_wind_speed); 