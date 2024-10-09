function [best_mdl, best_fs] = train_model_with_feature_selection( ...
    train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model)
% -------------------------------------------------------------------------
% Function to train a regression model with feature selection based on
% the specified feature selection method (MRMR or PLS_VIP).
%
% Input:
%   - train_x: Predictor variables (training data).
%   - train_y: Response variable (training target).
%   - val_x: Predictor variables (validation data).
%   - val_y: Response variable (validation target).
%   - num_max_vr: Maximum number of variables (features) to select.
%   - fs_method: Feature selection method ('MRMR' or 'PLS_VIP').
%   - rg_model: Regression model to be trained (e.g., 'PLS').
%
% Output:
%   - best_mdl: The trained regression model with the best performance.
%   - best_fs: Feature selection result
%              (indices and scores of selected features).
%
% Author: Mingqiang Han
% Date: 10-07-24
% -------------------------------------------------------------------------

% Initialize feature selection parameters
fs_param.name = fs_method;
fs_param.ncomp = [];  % ncomp is used for 'PLS_VIP' only

% Calculate the maximum number of PLS components (rows of train_x - 1)
max_comp = size(train_x, 1) - 1;
best_rmse = inf;  % Initialize best RMSE value as infinity
best_mdl = [];    % Initialize the best model variable
best_fs = [];     % Initialize the best feature selection variable

% Switch based on the feature selection method
switch fs_method
    case 'MRMR'
        % Process feature selection using MRMR method
        [best_mdl, best_fs, ~] = process_feature_selection(...
        train_x, train_y, val_x, val_y, num_max_vr, rg_model, fs_param);

    case 'PLS_VIP'
        % Iterate over the possible number of PLS components
        for ncomp = 1:max_comp
            % Set the number of PLS components in fs_param
            fs_param.ncomp = ncomp;
            % Perform feature selection and model training
            [best_mdl_temp, best_fs_temp, best_rmse_temp] = ...
                process_feature_selection(train_x, train_y, ...
                val_x, val_y, num_max_vr, rg_model, fs_param);

            % Track the best model based on RMSE and Rsquare criteria
            if best_rmse_temp < best_rmse ...
                && best_mdl_temp.train_rsquare >= best_mdl_temp.val_rsquare
                best_mdl = best_mdl_temp;  % Updates 
                best_fs = best_fs_temp;    
                best_rmse = best_rmse_temp; 
            end
        end

    otherwise
        error('Unsupported feature selection method. Choose either MRMR or PLS_VIP.');
end
end


function [best_mdl, best_fs, best_rmse] = process_feature_selection(...
    train_x, train_y, val_x, val_y, max_vr, rg_model, fs_param)
% -------------------------------------------------------------------------
% Helper function to process feature selection and track the best model.
%
% Input:
%   - train_x: Predictor variables (training data).
%   - train_y: Response variable (training target).
%   - val_x: Predictor variables (validation data).
%   - val_y: Response variable (validation target).
%   - num_max_vr: Maximum number of variables (features) to select.
%   - rg_model: Regression model to be trained (e.g., 'PLS').
%   - fs_param: Feature selection parameters 
%               (method name, number of components).
%
% Output:
%   - best_mdl: The trained regression model with the best performance.
%   - best_fs: Feature selection result 
%              (indices and scores of selected features).
%   - best_rmse: RMSE value for the best model.
%
% Author: Mingqiang Han
% Date: 10-07-24
% -------------------------------------------------------------------------

% Perform feature selection using the specified method
[score_idx, scores] = feature_selection(train_x, train_y, fs_param);
fs.idx = score_idx;   % Store indices of selected features
fs.score = scores;    % Store scores of selected features

% Initialize tracking variables for best model and RMSE
best_rmse = inf;
best_mdl = [];
best_fs = [];

num_train = size(train_x, 1);
num_max_vr = min(num_train-1, max_vr);

% Loop through the selected features based on the number to be considered
for n_fea = 1:num_max_vr
    fea_indices = fs.idx(1:n_fea);  % Select the top 'n_fea' features
    % Subset training data with selected features
    train_x_new = train_x(:, fea_indices);  
    % Subset validation data with selected features
    val_x_new = val_x(:, fea_indices);     

    % Train and evaluate the regression model with selected features
    [mdl, val_rsquare, val_rmse, train_rsquare] = ...
        train_and_evaluate_model(rg_model, train_x_new, train_y, ...
        val_x_new, val_y, n_fea);

    % Update the best model if the current one is better
    if val_rmse < best_rmse && train_rsquare >= val_rsquare
        best_rmse = val_rmse;  % Update best RMSE
        best_fs = fs;          % Store the feature selection result

        % Store details of the best model
        best_mdl.name = rg_model;
        best_mdl.mdl = mdl;
        best_mdl.var_num = n_fea;  % Number of selected features
        best_mdl.train_rsquare = train_rsquare;
        best_mdl.val_rsquare = val_rsquare;

        % For PLS, store additional coefficients
        if strcmp(rg_model, 'PLS')
            best_mdl.n_comp = mdl.n_comp;  % Number of PLS components
            best_mdl.BETA = mdl.BETA;      % PLS regression coefficients
        end
    end
end

end
