function results = access_all_field_data(year, mainpath)
% -------------------------------------------------------------------------
% This function retrieves and organizes field data for a given year, 
% mainpath, and various experimental configurations (plot type, 
% nitrogen type, and cable type). It loops through predefined combinations
% of plot types, nitrogen types, and cable types to collect data and store
% the results in a structure array.
%
% Input:
%   - year: The year for which the data is being accessed (string).
%   - mainpath: The main directory path 
%               where the field data is stored (string).
%
% Output:
%   - results: A structure array containing the following fields:
%       - Plotname: The name of the plot 
%                   (EP for Early Planting, LP for Late Planting).
%       - Ntype: Nitrogen condition 
%                  (WN for With Nitrogen, ON for Without Nitrogen).
%       - Cabletype: The type of cable used 
%                  (LC for Long Cable, SC for Short Cable).
%       - Numsamples: The number of samples found for this configuration.
%       - data: The data collected from the field for this configuration.
%       - gt: Ground truth data corresponding to the field data.
%
% Author: Mingqiang Han
% Date: 09-12-24
% -------------------------------------------------------------------------

% Define possible plot types, nitrogen types, and cable types
plot_name = {'EP', 'LP'};    % EP (Early Planting) or LP (Late Planting)
subplot_name = {'WN', 'ON'}; % WN (With Nitrogen) or ON (Without Nitrogen)
Cable_Type = {'SC', 'LC'};   % LC (Long Cable) or SC (Short Cable)

% Pre-allocate a structure array to store the results for each combination
results = struct('Plotname', {}, 'Ntype', {}, 'Cabletype', {}, ...
                 'Numsamples', {}, 'data', {}, 'gt', {});

% Initialize index to store results in the structure array
idx = 1;

% Loop through each combination of plot type, nitrogen type, and cable type
for i = 1:length(plot_name)
    for j = 1:length(subplot_name)
        for k = 1:length(Cable_Type)
            
            % Get the current plot, nitrogen condition, and cable type
            current_plot = plot_name{i};
            current_subplot = subplot_name{j};
            current_cabletype = Cable_Type{k};

            % Display the current configuration being processed
            fprintf('Plot(%s), Nitrogen(%s), Cable type(%s) -> ', ...
                    current_plot, current_subplot, current_cabletype);
            
            % Load field data for the current configuration
            [data, gt, data_size] = load_field_data(year, mainpath, ...
                                                    current_plot, ...
                                                    current_subplot, ...
                                                    current_cabletype);
            
            % Display the number of samples found for this configuration
            fprintf('Found %3d samples.\n', data_size);
            
            % Store the results in the structure array
            results(idx).Plotname = current_plot;     
            results(idx).Ntype = current_subplot;     
            results(idx).Cabletype = current_cabletype;  
            results(idx).Numsamples = data_size;         
            results(idx).data = data;                    
            results(idx).gt = gt;                     
            
            % Increment the index for the next configuration
            idx = idx + 1;
        end
    end
end
end
