function [train_x, train_y, val_x, val_y] = Prepare_lab_data(train_data, val_data, predictors, parameter)

    % Define feature extraction functions for predictors
    feature_extraction = @(data, field) vertcat(arrayfun(@(x) x.(field)(:, 10:end), data, 'UniformOutput', false));
    
    switch predictors
        case 'Mag'
            % Extract 'mag' features for val and train sets
            val_x = feature_extraction(val_data, 'mag');
            train_x = feature_extraction(train_data, 'mag');
            val_x = vertcat(val_x{:});
            train_x = vertcat(train_x{:});
            
        case 'Phs'
            % Extract 'phs' features for val and train sets
            val_x = feature_extraction(val_data, 'phs');
            train_x = feature_extraction(train_data, 'phs');
            val_x = vertcat(val_x{:});
            train_x = vertcat(train_x{:});
            
        case 'MaP'
            % Extract both 'mag' and 'phs' features and concatenate them horizontally
            val_x_mag = feature_extraction(val_data, 'mag');
            val_x_phs = feature_extraction(val_data, 'phs');
            train_x_mag = feature_extraction(train_data, 'mag');
            train_x_phs = feature_extraction(train_data, 'phs');
            
            % Concatenate 'mag' and 'phs' horizontally without additional vertcat
            val_x = horzcat(val_x_mag{:}, val_x_phs{:});

            train_x_mag = vertcat(train_x_mag{:});
            train_x_phs = vertcat(train_x_phs{:});
            train_x = [train_x_mag, train_x_phs];
            % train_x = horzcat(train_x_mag{:}, train_x_phs{:});
    end

    % Define target extraction function
    target_extraction = @(data, field) vertcat(arrayfun(@(x) x.gt.(field), data, 'UniformOutput', false));
    
    switch parameter
        case 'WC_Calculated'
            % Extract 'WC_Calculated' for val and train sets
            val_y = target_extraction(val_data, 'WC_Calculated');
            train_y = target_extraction(train_data, 'WC_Calculated');
            
        case 'WC_Prepared'
            % Extract 'WC_Prepared' for val and train sets
            val_y = target_extraction(val_data, 'WC_Prepared');
            train_y = target_extraction(train_data, 'WC_Prepared');
    end

    % Flatten target cell arrays into matrices
    val_y = vertcat(val_y{:});
    train_y = vertcat(train_y{:});
end
