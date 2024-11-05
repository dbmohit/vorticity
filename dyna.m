% Load necessary variables from the NetCDF file
filename = 'uwnd.mon.mean.nc';  % Replace with your actual file name
filename_v = "vwnd.mon.mean.nc";
% Read latitude, longitude, time, and uwnd variables
lat = ncread(filename, 'lat');
lon = ncread(filename, 'lon');
time = ncread(filename, 'time');
uwnd = ncread(filename, 'uwnd');  % Replace with the variable for vorticity
vwind = ncread(filename_v,"vwnd");

time_v = ncread(filename_v, 'time');
% Read levels and find the index for 850 hPa
levels = ncread(filename, 'level');
levels_v = ncread(filename_v, 'level');
level_index = find(levels == 850);  % Adjust according to your levels
level_index_v = find(levels_v == 850);

% Extract the 850 hPa data (u-wind) for all times
uwnd_850 = squeeze(uwnd(:, :, level_index, :));
vwind_850 = squeeze(vwind(:, :, level_index_v, :));
%% Convert time from hours since 1800-01-01 to MATLAB datenum
time_datenum = datenum('1800-01-01') + time / 24;

% Identify indices for June to September (month 6 to 9)
months = month(time_datenum);  % Get month numbers from datetime
summer_indices = find(months >= 6 & months <= 9);

% Extract summer data
uwnd_summer = uwnd_850(:, :, summer_indices);
%% v
time_datenum_v = datenum('1800-01-01') + time_v / 24;

% Identify indices for June to September (month 6 to 9)
months_v = month(time_datenum_v);  % Get month numbers from datetime
summer_indices_v = find(months_v >= 6 & months_v <= 9);

% Extract summer data
vwnd_summer = vwind_850(:, :, summer_indices_v);
%%

% Calculate relative vorticity (using uwnd; you may need to calculate it if it's not directly available)
% This is a placeholder; replace with actual vorticity computation as needed.
dudy = calculate_du_dx(uwnd_summer,lat);
dvdx = calculate_du_dx(vwnd_summer,lon);
vor = dvdx-dudy;
relative_vorticity = vor;  % Implement this function

% Visualization of the average relative vorticity during summer months
average_vorticity = mean(relative_vorticity, 3);  % Average over summer months

%% Create a contour plot
load("topo.mat");
figure;
uwnd_summer_avg = mean(uwnd_summer,3);
vwnd_summer_avg = mean(vwnd_summer,3);





contourf(lon, lat, average_vorticity',-3:3, 'LineColor', 'none');
colorbar;
hold on
contour(0:359,-89:90,topo,-3:3,'k')
hold on
quiver(lon, lat, uwnd_summer_avg', vwnd_summer_avg','k')

hold off
title('Average Relative Vorticity at 850 hPa (June-September)');
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');

function du_dx = calculate_du_dx(uwnd, lon)
    % CALCULATE_DU_DX Calculates the derivative of u-wind with respect to x (longitude).
    %
    % Inputs:
    %   uwnd - 3D or 4D array of u-wind data (lon, lat, [level, time])
    %   lon  - 1D array of longitude values
    %
    % Outputs:
    %   du_dx - Array of the same size as uwnd containing the derivative of u-wind

    % Ensure uwnd is a 3D array (lon, lat, time)
    if ndims(uwnd) == 4
        uwnd = squeeze(uwnd(:, :, :, :));  % Adjust based on specific dimension
    end

    % Calculate the grid spacing in degrees
    dx = mean(diff(lon));  % Assume uniform spacing for simplicity

    % Initialize the array for the derivative
    du_dx = zeros(size(uwnd));  % Same size as uwnd

    % Central difference for interior points
    du_dx(2:end-1, :, :) = (uwnd(3:end, :, :) - uwnd(1:end-2, :, :)) / (2 * dx);

    % Forward difference for the first point
    du_dx(1, :, :) = (uwnd(2, :, :) - uwnd(1, :, :)) / dx;

    % Backward difference for the last point
    du_dx(end, :, :) = (uwnd(end, :, :) - uwnd(end-1, :, :)) / dx;
end
