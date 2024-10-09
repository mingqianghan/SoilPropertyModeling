function [best_mdl, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model)
% Trains a regression model using MRMR feature selection and selects the best
% model based on validation performance (Rsquared). Supports Linear Regression,
% SVM, and PLS models.
%
% Inputs:
%   train_x    - Training feature matrix.
%   train_y    - Training target vector.
%   val_x      - Validation feature matrix.
%   val_y      - Validation target vector.
%   num_max_vr - Maximum number of features to select and evaluate.
%   rg_model   - Regression model to use ('LR', 'SVM', 'PLS').
%
% Outputs:
%   best_mdl   - Struct containing the best model and related information.
%   score_idx  - Ranked indices of selected features (based on MRMR scores).
%   scores     - MRMR scores for each feature.

% Feature selection using MRMR
[score_idx, scores] = fsrmrmr(train_x, train_y);

% Initialize tracking variables for the best model
best_rmse = inf;
best_mdl = struct();

% Iterate over the number of selected features (from 1 to num_max_vr)
for n_fea = 1:num_max_vr
    fea_indices = score_idx(1:n_fea);
    train_x_new = train_x(:, fea_indices);
    val_x_new = val_x(:, fea_indices);
    
    % Train and evaluate the model

    [mdl, val_rsquare, val_rmse, train_rsquare] = train_and_evaluate_model(rg_model, train_x_new, train_y, val_x_new, val_y, n_fea);
    
    % Update the best model if conditions are met
    if val_rmse < best_rmse && train_rsquare >= val_rsquare
        best_rmse = val_rmse;
        % Stores information about the best model
        best_mdl.name = rg_model;
        best_mdl.mdl = mdl;
        best_mdl.var_num = n_fea;
        best_mdl.train_rsquare = train_rsquare;
        best_mdl.val_rsquare = val_rsquare;

        if strcmp(rg_model, 'PLS')
            best_mdl.n_comp = mdl.n_comp;
            best_mdl.BETA = mdl.BETA;  % Store the PLS coefficients
        end
    end
end
end