function [best_mdl, best_fs] = train_model_with_feature_selection_with_label( ...
    train_x, train_y, val_x, val_y, catTrain, catVal, num_max_vr, fs_method, rg_model, ...
    OptParams)
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
%   - fs_method: Feature selection method ('MRMR' 'SPA', or 'PLS_VIP').
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
fs_param.ncomp = [];  % ncomp is used for 'PLS_VIP' and 'CARS'
fs_param.max_var = num_max_vr;  % used for SPA

% Calculate the maximum number of PLS components (rows of train_x - 1)
max_comp = size(train_x, 1) - 1;
best_rmse = inf;  % Initialize best RMSE value as infinity
best_mdl = [];    % Initialize the best model variable
best_fs = [];     % Initialize the best feature selection variable

% Switch based on the feature selection method
switch fs_method
    case 'MRMR'
        % Process feature selection using MRMR method
        [best_mdl, best_fs] = process_feature_selection( ...
            train_x, train_y, val_x, val_y, catTrain, catVal, num_max_vr, rg_model, ...
            fs_param, OptParams);
    case 'SPA'
        % Process feature selection using SPA method
        [best_mdl, best_fs] = process_feature_selection( ...
            train_x, train_y, val_x, val_y, catTrain, catVal, num_max_vr, rg_model, ...
            fs_param, OptParams);
    case 'CARS'
        [best_mdl, best_fs] = ...
            process_feature_selection(train_x, train_y, ...
            val_x, val_y, catTrain, catVal, num_max_vr, rg_model, fs_param, OptParams);
        % for ncomp = 1:max_comp
        %     % Set the number of PLS components in fs_param
        %     fs_param.ncomp = ncomp;
        %     % Perform feature selection and model training
        %     [best_mdl_temp, best_fs_temp] = ...
        %         process_feature_selection(train_x, train_y, ...
        %         val_x, val_y, num_max_vr, rg_model, fs_param, OptParams);
        %
        %     % Track the best model based on RMSE and Rsquare criteria
        %     if best_mdl_temp.val_scores.rmse < best_rmse && ...
        %             best_mdl_temp.train_scores.rsquare >= ...
        %             best_mdl_temp.val_scores.rsquare
        %         best_mdl = best_mdl_temp;  % Updates
        %         best_fs = best_fs_temp;
        %     end
        % end

    case 'PLS_VIP'
        h = waitbar(0, 'PLS Component...');
        % Iterate over the possible number of PLS components
        for ncomp = 1:max_comp

            waitbar(ncomp / max_comp, h, ...
            sprintf('PLS component: %d of %d', ncomp, max_comp));

            % Set the number of PLS components in fs_param
            fs_param.ncomp = ncomp;
            % Perform feature selection and model training
            [best_mdl_temp, best_fs_temp] = ...
                process_feature_selection(train_x, train_y, ...
                val_x, val_y, catTrain, catVal, num_max_vr, rg_model, fs_param, OptParams);

            % Track the best model based on RMSE and Rsquare criteria
            if best_mdl_temp.val_scores.rmse < best_rmse && ...
                    best_mdl_temp.train_scores.rsquare >= ...
                    best_mdl_temp.val_scores.rsquare
                best_mdl = best_mdl_temp;  % Updates
                best_fs = best_fs_temp;
            end
        end

        close(h);
    otherwise
        error(['Unsupported feature selection method. ' ...
            'Choose either MRMR or PLS_VIP.']);
end
end


function [best_mdl, best_fs] = process_feature_selection( ...
    train_x, train_y, val_x, val_y, catTrain, catVal, max_vr, rg_model, fs_param, OptParams)
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
%
% Author: Mingqiang Han
% Date: 10-07-24
% -------------------------------------------------------------------------

% Perform feature selection using the specified method
[score_idx, scores] = feature_selection(train_x, train_y, fs_param);
best_fs.idx = score_idx;   % Store indices of selected features
best_fs.score = scores;    % Store scores of selected features

% Initialize tracking variables for best model and RMSE
best_rmse = inf;
best_mdl = [];

num_train = size(train_x, 1);
num_max_vr = min([num_train-1, max_vr, length(score_idx)]);

h = waitbar(0, 'Number of features...');

% Loop through the selected features based on the number to be considered
for n_fea = 1:num_max_vr

    waitbar(n_fea / num_max_vr, h, ...
            sprintf('Model Progress: %d of %d', n_fea, num_max_vr));

    fea_indices = score_idx(1:n_fea);  % Select the top 'n_fea' features
    % Subset training data with selected features
    train_x_new = train_x(:, fea_indices); 
    train_x_new = [train_x_new, catTrain];
    % Subset validation data with selected features
    val_x_new = val_x(:, fea_indices);    
    val_x_new = [val_x_new, catVal];

    % Train and evaluate the regression model with selected features
    [mdl, train_eval_scores, val_eval_scores] = ...
        train_and_evaluate_model(rg_model, train_x_new, train_y, ...
        val_x_new, val_y, n_fea, OptParams);

    [train_eval_scores.rsquare train_eval_scores.rmse val_eval_scores.rsquare val_eval_scores.rmse]

    % Update the best model if the current one is better
    if val_eval_scores.rmse < best_rmse && ...
        train_eval_scores.rsquare >= val_eval_scores.rsquare
        best_rmse = val_eval_scores.rmse;  % Update best RMSE
    
        % Store details of the best model
        best_mdl.name = rg_model;
        best_mdl.mdl = mdl;
        best_mdl.f_idx = fea_indices; 
        best_mdl.train_scores = train_eval_scores;
        best_mdl.val_scores = val_eval_scores;
    end
end
close(h);
end
