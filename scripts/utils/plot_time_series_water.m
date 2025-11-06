function plot_time_series_water(aux_file_path, data)
% -------------------------------------------------------------------------
% This function reads weather data from a specified auxiliary file 
% and plots precipitation and soil moisture values over time. It creates 
% a figure with two subplots: one for precipitation and one for soil 
% moisture. Each subplot displays data for a specified time range.
%
% Weather data is from Kansas State University Mesonet
% https://mesonet.k-state.edu/
% Station location: Mahattan (Latitude: 39.209, Longitude: -96.592)
%
% Inputs:
% - aux_file_path: File path to the auxiliary file containing weather data.
% - data: A struct containing soil moisture data with keys representing 
%         the series name. Each field is a cell array where the first 
%         element is the timestamp and the second element is the soil 
%         moisture values.
%
% Author: Mingqiang Han
% Date: 10-18-24
% -------------------------------------------------------------------------

% Read weather data
weather_data = readtable(aux_file_path);

% Compute date range based on the input soil moisture data
% Minimum date from all data
datemin = min(cellfun(@(x) min(x{1}), struct2cell(data))); 
% Maximum date from all data
datemax = max(cellfun(@(x) max(x{1}), struct2cell(data))); 

% Extract and filter rain data based on timestamps
% Extract timestamps starting from the 3rd entry
timestamps = weather_data.("Timestamp")(3:end);
% Extract precipitation data starting from the 3rd entry
precipitation = weather_data.("Precipitation")(3:end); 
% Filter data within the date range of soil moisture data
date_filter = timestamps >= datemin & timestamps <= datemax; 
% Store filtered timestamps and precipitation
rain = {timestamps(date_filter), precipitation(date_filter)}; 

% Create a figure and set the figure properties
figure('Position', [100, 100, 900, 600]); % Set figure size and position

% Plot precipitation (Top plot)
ax1 = subplot(2, 1, 1); % Create top subplot for precipitation
% Plot precipitation as bar chart
bar(rain{1}, rain{2}, 'FaceColor', [0.6216 0.6216 0.6216], ...
    'EdgeColor', 'none', 'BarWidth', 0.8); 
ylabel('Precipitation (mm)', 'FontSize', 11); 
set(gca, 'YDir', 'reverse', 'XColor', 'none', 'YColor', 'k', ...
    'box', 'off', 'FontSize', 10); 

% Plot soil moisture (Bottom plot)
ax2 = subplot(2, 1, 2); % Create bottom subplot for soil moisture
hold on;
% Colors for each series
colors = {[0, 0, 0.6353], [0.9137, 0.7804, 0.0863], 
          [0.7373, 0.1529, 0.1765], [0.3137, 0.6784, 0.6235]}; 
markers = {'o', 's', '^', 'd'}; % Markers for each series
keys = fieldnames(data); % Extract keys (series names) from the data struct

% Loop through each soil moisture series and plot the data
for i = 1:numel(keys)
    plot(data.(keys{i}){1}, data.(keys{i}){2}, ...
        'LineWidth', 2, 'Color', colors{i}, 'Marker', markers{i}, ...
        'MarkerSize', 6, 'MarkerFaceColor', colors{i}); 
end
hold off;
ylabel('Soil Moisture (cm^3/cm^3)', 'FontSize', 11); %
set(gca, 'YDir', 'normal', 'XColor', 'k', 'YColor', 'k', ...
    'box', 'off', 'FontSize', 10); % Set axis properties
ylim([0.15, 0.5]); % Set y-axis limits for soil moisture plot

for i = 1:length(keys)
    keys{i} = strrep(keys{i}, '_', '-');
end

% Add legend for soil moisture series
legend(keys, 'Location', 'southwest', 'FontSize', 11, 'TextColor', 'k', ...
       'Orientation', 'horizontal', 'Interpreter', 'none');

% Adjust subplot positions
adjust_subplot(ax1, -0.04, 0.14, 1.15, 0.7);
adjust_subplot(ax2, -0.04, -0.01, 1.15, 1.8); 

% Link x-axes and set x-axis limits for both subplots
linkaxes([ax1, ax2], 'x'); % Link x-axes of both subplots
xlim([datemin, datemax]); % Set x-axis limits 

% Helper function to adjust subplot positions
    function adjust_subplot(ax, x_offset, y_offset, width_factor, height_factor)
        % ADJUST_SUBPLOT Adjusts the position of the given subplot.
        %
        % Inputs:
        % - ax: Axis handle of the subplot to adjust.
        % - x_offset, y_offset: Amounts to shift the subplot 
        %                       in x and y directions.
        % - width_factor, height_factor: Factors to adjust subplot 
        %                                width and height.
        %
        pos = get(ax, 'Position'); % Get current position of the subplot
        pos(1) = pos(1) + x_offset; % Adjust x position
        pos(3) = pos(3) * width_factor; % Adjust width
        pos(2) = pos(2) + y_offset; % Adjust y position
        pos(4) = pos(4) * height_factor; % Adjust height
        set(ax, 'Position', pos); % Set new position
    end
end
