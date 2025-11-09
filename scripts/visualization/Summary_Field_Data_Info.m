clc;
clear;
close all;

% Define paths and year
year = '24';
mainpath = 'data\UG nodes';
data_path_water = 'auxiliary data\weatherdata.txt';
data_path_nitrogen = 'auxiliary data\fertilizer.xlsx';

% Access field data
results = access_all_field_data(year, mainpath);

% Define matching criteria and filter results
types = {'EP', 'LP'};
nitrogen = {'WN', 'ON'};
fields = {'VWC', 'NO3', 'NH4', 'totN'};
data_all = struct();

% Initialize data_all struct
for f = 1:length(fields)
    data_all.(fields{f}) = struct();
end

% Extract matches, group data in data_all, and calculate statistics
for t = 1:length(types)
    for n = 1:length(nitrogen)
        % Create a valid field name by concatenating with underscore
        key = [types{t}, '_', nitrogen{n}];
        matches = strcmp({results.Cabletype}, 'LC') & ...
                  strcmp({results.Plotname}, types{t}) & ...
                  strcmp({results.Ntype}, nitrogen{n});
        
        % Extract the required data
        matching_results = results(matches);
        if isempty(matching_results)
            continue;
        end
        
        % Extract date and field values
        date = vertcat(matching_results.data.date);
        
        % Loop through fields and process data
        for f = 1:length(fields)
            field_values = vertcat(matching_results.gt);
            field_values = [field_values.(fields{f})];
            
            % Store the current key data under the corresponding field
            data_all.(fields{f}).(key) = {date, field_values};
            
            % Calculate statistics for the current field
            stat = calculate_data_statistics(field_values);
            
            % Display the calculated statistics
            fprintf('%s - %s statistics: \n', key, fields{f});
            disp(stat);
        end
    end
end

% Use a loop to plot the data instead of repetitive calls
ylabels = {'VWC (cm^3/cm^3)', 'NO_3-N (ppm)', ...
           'NH_4-N (ppm)', 'Total N (%)'};
fields_to_plot = {'VWC', 'NO3', 'NH4', 'totN'};

% Plot the time series water
% plot_time_series_water(fullfile(mainpath, data_path_water), data_all.VWC)

% % plot the time series nitogen
% plot_time_series_data(fullfile(mainpath, data_path_water), ...
%                       fullfile(mainpath, data_path_nitrogen), ...
%                       data_all)

% Plot data distribution for each field
for i = 1:length(fields_to_plot)
    ytitle = ylabels{i};
    plot_data_distribution(data_all.(fields_to_plot{i}), ytitle);
end
