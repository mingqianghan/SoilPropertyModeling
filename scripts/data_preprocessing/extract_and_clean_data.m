function [data_x_valid, data_y_valid, data_category] = ...
         extract_and_clean_data(all_data, data_type, predictors, parameter)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------

% Extract feature data from 'all_data.data'
data_x = vertcat(all_data.data);

% Feature extraction function to slice off the first 9 columns and concatenate remaining rows
feature_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.(field)(:, 10:end), data, ...
    'UniformOutput', false));

% Target extraction from the 'gt' field of all_data
target_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.gt.(field), data, 'UniformOutput', false));


switch data_type
    case 'lab'
        class_names = arrayfun(@(x) [x.expnum], all_data, 'UniformOutput', false);
        numsamples = [all_data.Numsamples];
        create_categories = arrayfun(@(x, y) repmat({x}, y, 1), class_names, numsamples, 'UniformOutput', false);
        data_category = vertcat(create_categories{:});
        data_category = cellfun(@char, data_category, 'UniformOutput', false);
        data_category = categorical(data_category);

        switch parameter
            case 'WC_Calculated'
                target_data = target_extraction(all_data, 'WC_Calculated');
            case 'WC_Prepared'
                target_data = target_extraction(all_data, 'WC_Prepared');
            case 'Urea'
                target_data = target_extraction(all_data, 'Urea');
            case 'WC'
                target_data = target_extraction(all_data, 'WC');
            case 'NO3'
                target_data = target_extraction(all_data, 'NO3');
            case 'NH4'
                target_data = target_extraction(all_data, 'NH4');
            case 'totN'
                target_data = target_extraction(all_data, 'totN');
        end

    case 'field'
        class_names = arrayfun(@(x) [x.Plotname '_' x.Ntype], all_data, 'UniformOutput', false);
        numsamples = [all_data.Numsamples];
        create_categories = arrayfun(@(x, y) repmat({x}, y, 1), class_names, numsamples, 'UniformOutput', false);
        data_category = vertcat(create_categories{:});
        data_category = cellfun(@char, data_category, 'UniformOutput', false);
        data_category = categorical(data_category);

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
    otherwise
        error('Invalid data type. Choose "lab" or "field".');
end
target_data = vertcat(target_data{:});  % Concatenate the target values


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


% Find rows with NaN values in target_data and clean both sensor_data and target_data
nan_indices = isnan(target_data);
data_y_valid = target_data(~nan_indices, :);  % Valid target values
data_x_valid = sensor_data(~nan_indices, :);  % Corresponding valid feature rows
data_category = data_category(~nan_indices, :);

end
