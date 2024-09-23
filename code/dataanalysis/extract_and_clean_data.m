function [data_x_valid, data_y_valid] = extract_and_clean_data( ...
                                        all_data, predictors, ...
                                        parameter)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------

% Extract feature data from 'all_data.data'
data_x = vertcat(all_data.data);

% Feature extraction function to slice off the first 9 columns and concatenate remaining rows
feature_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.(field)(:, 10:end), data, ...
    'UniformOutput', false));

% Switch-case structure to handle different predictor types
switch predictors
    case 'Mag'
        sensor_data = feature_extraction(data_x, 'mag'); 
        sensor_data = vertcat(sensor_data{:});  % Vertically concatenate the cell contents
        
    case 'Phs'
        sensor_data = feature_extraction(data_x, 'phs'); 
        sensor_data = vertcat(sensor_data{:});  % Vertically concatenate the cell contents
        
    case 'MaP'
        sensor_data_mag = feature_extraction(data_x, 'mag');
        sensor_data_phs = feature_extraction(data_x, 'phs');
        x_mag = vertcat(sensor_data_mag{:});
        x_phs = vertcat(sensor_data_phs{:});
        sensor_data = [x_mag, x_phs];  % Combine 'mag' and 'phs' horizontally
end

% Target extraction from the 'gt' field of all_data
target_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.gt.(field), data, 'UniformOutput', false));

% Switch-case structure to handle different target parameters.
switch parameter
    case 'VWC'
        target_data = target_extraction(all_data, 'VWC');
    case 'NO3'
        target_data = target_extraction(all_data, 'NO3');
    case 'NH4'
        target_data = target_extraction(all_data, 'NH4');
    case 'totN'
        target_data = target_extraction(all_data, 'totN');
end

target_data = vertcat(target_data{:});  % Concatenate the target values

% Find rows with NaN values in target_data and clean both sensor_data and target_data
nan_indices = isnan(target_data);
data_y_valid = target_data(~nan_indices, :);  % Valid target values
data_x_valid = sensor_data(~nan_indices, :);  % Corresponding valid feature rows

end
