function [train_x, train_y, val_x, val_y] = Prepare_lab_data( ...
    train_data, val_data, predictors, parameter)
% -------------------------------------------------------------------------
% Extracts feature and target data for training and validation.
%
% Description:
% This function extracts features and target variables from the
% provided training and validation datasets for soil analysis. The
% function allows flexible feature extraction based on the specified
% predictors ('Mag', 'Phs', or 'MaP') and target extraction based on
% the specified parameter ('water' or different forms of nitrogen).
% The processed data is returned in the form of training and validation
% feature matrices and target variables.
%
% Inputs:
%   train_data  - Training dataset struct array, each element contains
%                 fields for predictors and targets.
%   val_data    - Validation dataset struct array, structured similarly
%                 to train_data.
%   predictors  - A string specifying which predictors to use:
%                 'Mag', 'Phs', or 'MaP' (both 'mag' and 'phs').
%   parameter   - A string specifying the target parameter to extract:
%                 'WC_Calculated' or 'WC_Prepared' (more will be added)
%
% Outputs:
%   train_x     - Training feature matrix.
%   train_y     - Training target matrix.
%   val_x       - Validation feature matrix.
%   val_y       - Validation target matrix.
%
% Author: Mingqiang Han
% Date: 09-20-24
% -------------------------------------------------------------------------

% Define a function to extract features from the 'mag' or 'phs' fields,
% starting from the 10th column onward (column 1:9: reponses with
% frequency less than 1000 Hz have error).
% The features are concatenated across all data entries.
feature_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.(field)(:, 10:end), data, ...
    'UniformOutput', false));

% Switch-case structure to handle different predictor types.
switch predictors
    case 'Mag'
        % Extract 'mag' features from training and validation datasets
        val_x = feature_extraction(val_data, 'mag'); % validation
        train_x = feature_extraction(train_data, 'mag'); % training
        % Vertically concatenate the feature matrices
        val_x = vertcat(val_x{:});
        train_x = vertcat(train_x{:});

    case 'Phs'
        % Extract 'phs' features from training and validation datasets
        val_x = feature_extraction(val_data, 'phs'); % validation
        train_x = feature_extraction(train_data, 'phs'); % training
        % Vertically concatenate the feature matrices
        val_x = vertcat(val_x{:});
        train_x = vertcat(train_x{:});

    case 'MaP'
        % Extract both 'mag' and 'phs' features
        % for validation and training datasets
        val_x_mag = feature_extraction(val_data, 'mag'); % validation
        val_x_phs = feature_extraction(val_data, 'phs'); % validation
        train_x_mag = feature_extraction(train_data, 'mag'); % training
        train_x_phs = feature_extraction(train_data, 'phs'); % training

        % Concatenate 'mag' and 'phs' features horizontally
        % for validation data
        val_x = horzcat(val_x_mag{:}, val_x_phs{:});

        % Concatenate 'mag' and 'phs' features vertically
        % for training data
        train_x_mag = vertcat(train_x_mag{:});
        train_x_phs = vertcat(train_x_phs{:});
        train_x = [train_x_mag, train_x_phs]; % Combine features
end

% Define a function to extract target values
% from the 'gt' field of the data
target_extraction = @(data, field) vertcat(arrayfun(@(x) ...
    x.gt.(field), data, 'UniformOutput', false));

% Switch-case structure to handle different target parameters.
switch parameter
    case 'WC_Calculated'
        % Extract 'WC_Calculated' target for
        % validation and training datasets
        val_y = target_extraction(val_data, 'WC_Calculated');
        train_y = target_extraction(train_data, 'WC_Calculated');

    case 'WC_Prepared'
        % Extract 'WC_Prepared' target for
        % validation and training datasets
        val_y = target_extraction(val_data, 'WC_Prepared');
        train_y = target_extraction(train_data, 'WC_Prepared');
    case 'Urea'
        % Extract 'WC_Prepared' target for
        % validation and training datasets
        val_y = target_extraction(val_data, 'Urea');
        train_y = target_extraction(train_data, 'Urea');
    case 'WC'
        % Extract 'WC_Prepared' target for
        % validation and training datasets
        val_y = target_extraction(val_data, 'WC');
        train_y = target_extraction(train_data, 'WC');
end

% Flatten the cell arrays of target values into matrices
val_y = vertcat(val_y{:});
train_y = vertcat(train_y{:});
end
