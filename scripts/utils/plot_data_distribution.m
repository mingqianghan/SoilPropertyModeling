function plot_data_distribution(plot_data, ytitle)
% -------------------------------------------------------------------------
% This function creates a box plot with scatter points for data from 
% different treatments
% 
% Input: 
%   plot_data - structure containing fields:
%               'EP_WN', 'EP_ON', 'LP_WN', 'LP_ON'
%   ytitle - string specifying the title for the y-axis
%
% Note: Consider replacing the box plot with a violin plot in the future 
%       for better data visualization.
%
% Author: Mingqiang Han
% Date: 10-18-24
% -------------------------------------------------------------------------

% Sample treatment names
locations = fieldnames(plot_data);

% Initialize a cell array to store the cleaned data for each treatment
n_locations = length(locations);
cleaned_data_all = cell(n_locations, 1);

% Extract data for each treatment and clean it (remove NaN values)
for i = 1:n_locations
    % Get the data for the current treatment
    data = plot_data.(locations{i}){2};
    % Remove NaN values from the data
    data(isnan(data)) = [];
    % Store the cleaned data
    cleaned_data_all{i} = data;
end

% Define colors for each treatment to be used in the box plot
colors = [
    0.8275    0.1216    0.0667  % Red (#d31f11)
    0.3843    0.7843    0.8275  % Cyan (#62c8d3)
    0.9569    0.4784         0  % Orange (#f47a00)
         0    0.4431    0.5686  % Blue (#007191)
];


figure('Position', [100, 100, 400, 600]); % Set figure size and position
% Replace underscores with hyphens for better plot labels
for i = 1:length(locations)
    locations{i} = strrep(locations{i}, '_', '-');
end

% Create the original box plot without the default outlier symbols
% Generate group labels for each treatment
group_labels = repelem(locations, cellfun(@numel, cleaned_data_all)); 
boxplot(vertcat(cleaned_data_all{:}), group_labels, 'Widths', 0.7, ...
        'Notch', 'on', 'Symbol', '');
hold on; 

% Fill each box in the box plot with the corresponding color
h = findobj(gca, 'Tag', 'Box');
for j = 1:length(h)
    % Add color to each box
    patch(get(h(j), 'XData'), get(h(j), 'YData'), colors(j, :));
end

% Overlay scatter plots with jitter for each treatment to visualize 
% individual data points
for i = 1:n_locations
    % Add random jitter to x-coordinates for better visualization 
    % of individual points
    x_jitter = 0.05 * randn(size(cleaned_data_all{i}));
    scatter(i + x_jitter, cleaned_data_all{i}, 20, 'k', 'filled'); 
end

% Set y-axis label
ylabel(ytitle);

% Turn off the right and top border for a cleaner plot appearance
set(gca, 'box', 'off');

hold off; % Release the plot hold
end
