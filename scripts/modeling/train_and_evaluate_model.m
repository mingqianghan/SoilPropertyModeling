function [mdl, val_rsquare, val_rmse, train_rsquare] = ...
         train_and_evaluate_model(rg_model, train_x, train_y, ...
         val_x, val_y, n_fea, OptParams)
% -------------------------------------------------------------------------
% This function trains a regression model based on the specified
% model type (e.g., LR, ANN, SVM, PLS).
%
% Inputs:
% - rg_model: The regression model type ('LR', 'ANN', 'SVM', 'PLS').
% - train_x, train_y: Training feature matrix and labels.
% - val_x, val_y: Validation feature matrix and labels.
% - n_fea: Number of features (used for PLS).
% -  OptParams: Optimize hyperparameters or not (Boolen: true or false)
%               for SVM and ANN only
%
% Outputs:
% - mdl: The trained model.
% - val_rsquare: R-squared value for validation set.
% - val_rmse: Root Mean Squared Error for validation set.
% - train_rsquare: R-squared value for training set.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------

switch rg_model
    case 'LR'  % Linear Regression
        mdl = fitlm(train_x, train_y);
        [train_rsquare, val_rsquare, val_rmse] = evaluate_model( ...
            mdl, train_x, train_y, val_x, val_y);

    case 'ANN'  % Artificial Neural Network
        if OptParams
            fixed_params = {'Activations', 'relu', 'Standardize', true};
            param_sets = {'LayerSizes', [2, 4, 6]; ...
                'Lambda', [0.01, 0.001]};
            [mdl, train_rsquare, val_rsquare, val_rmse] = ...
                train_model(@fitrnet, train_x, train_y, val_x, val_y, ...
                param_sets, fixed_params);
        else
            mdl = fitrnet(train_x, train_y, ...
                              'LayerSizes', 3, ...
                              'Activations', 'relu', ...
                              'Standardize', true, ...
                              'Lambda', 0.001);
            [train_rsquare, val_rsquare, val_rmse] = ...
             evaluate_model(mdl, train_x, train_y, val_x, val_y);
        end

    case 'SVM'  % Support Vector Machine
        if OptParams
            fixed_params = {'KernelScale', 'auto'};
            param_sets = {'BoxConstraint', [0.1, 1, 10]; ...
                'Epsilon', [0.01, 0.1, 1]; ...
                'KernelFunction', {'linear', 'gaussian'}};
            [mdl, train_rsquare, val_rsquare, val_rmse] = ...
                train_model(@fitrsvm, train_x, train_y, val_x, val_y, ...
                param_sets, fixed_params);
        else
            mdl = fitrsvm(train_x, train_y, ...
                            'KernelFunction', 'gaussian', ...
                            'KernelScale', 'auto');
             [train_rsquare, val_rsquare, val_rmse] = ...
              evaluate_model(mdl, train_x, train_y, val_x, val_y);
        end

    case 'PLS'  % Partial Least Squares
        [mdl, train_rsquare, val_rsquare, val_rmse] = ...
            train_pls(train_x, train_y, val_x, val_y, n_fea);

    otherwise
        error('Unsupported model type');
end
end


%% Function: evaluate_model (Helper function)
function [train_rsquare, val_rsquare, val_rmse] = ...
         evaluate_model(mdl, train_x, train_y, val_x, val_y)
% -------------------------------------------------------------------------
% This function evaluates the performance of the trained model on
% both training and validation datasets.
%
% Inputs:
% - mdl: Trained model.
% - train_x, train_y: Training features and labels.
% - val_x, val_y: Validation features and labels.
%
% Outputs:
% - train_rsquare: R-squared value for training set.
% - val_rsquare: R-squared value for validation set.
% - val_rmse: Root Mean Squared Error for validation set.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
yPred_train = predict(mdl, train_x);
yPred_val = predict(mdl, val_x);
[train_rsquare, ~, ~] = model_evaluation(yPred_train, train_y);
[val_rsquare, val_rmse, ~] = model_evaluation(yPred_val, val_y);
end


%% Function: train_model (Helper function)
function [best_mdl, best_train_rsquare, ...
          best_val_rsquare, best_val_rmse] = train_model( ...
          train_func, train_x, train_y, val_x, val_y, ...
          param_sets, fixed_params)
% -------------------------------------------------------------------------
% This function trains a model using different combinations of
% hyperparameters and selects the best model based on validation RMSE.
%
% Inputs:
% - train_func: Function handle to train a specific model type.
% - train_x, train_y: Training features and labels.
% - val_x, val_y: Validation features and labels.
% - param_sets: Hyperparameters and their possible values.
% - fixed_params: Fixed hyperparameters.
%
% Outputs:
% - best_mdl: Trained model with the best performance.
% - best_train_rsquare:
%   R-squared value for the training set of the best model.
% - best_val_rsquare:
% R-squared value for the validation set of the best model.
% - best_val_rmse: RMSE for the validation set of the best model.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
best_val_rmse = inf;
best_train_rsquare = -inf;
best_val_rsquare = -inf;
best_mdl = [];

% Generate all combinations of parameters
param_combinations = all_combinations(param_sets);
for i = 1:size(param_combinations, 1)
    params = param_combinations{i};
    % Set random seed for each training iteration
    % to ensure reproducibility
    rng(3453);
    mdl_new = train_func(train_x, train_y, params{:}, fixed_params{:});
    [train_rsquare_new, val_rsquare_new, val_rmse_new] = ...
        evaluate_model(mdl_new, train_x, train_y, val_x, val_y);

    % Select the model based on validation RMSE
    % and generalization performance
    if val_rmse_new < best_val_rmse && ...
            train_rsquare_new >= val_rsquare_new
        best_val_rmse = val_rmse_new;
        best_train_rsquare = train_rsquare_new;
        best_val_rsquare = val_rsquare_new;
        best_mdl = mdl_new;
    end
end
end


%% Function: all_combinations (Helper function)
function param_combinations = all_combinations(param_sets)
% -------------------------------------------------------------------------
% This function generates all possible combinations of parameters 
% from the parameter sets.
%
% Inputs:
% - param_sets: Hyperparameters and their possible values.
%
% Outputs:
% - param_combinations: Cell array containing all combinations 
%                       of parameter values.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
n = size(param_sets, 1);
[grid{1:n}] = ndgrid(param_sets{:, 2});
param_combinations = cell(numel(grid{1}), 1);
for i = 1:numel(grid{1})
    combination = cell(1, n * 2);
    for j = 1:n
        param_value = grid{j}(i);
        % Convert cell value to character array if needed
        if iscell(param_value)
            param_value = char(param_value);
        end
        combination{2 * j - 1} = param_sets{j, 1};
        combination{2 * j} = param_value;
    end
    param_combinations{i} = combination;
end
end
 

%% Function: train_pls (Helper function)
function [best_mdl, best_train_rsquare, best_val_rsquare, ...
          best_val_rmse] = train_pls(train_x, train_y, val_x, val_y, n_fea)
% -------------------------------------------------------------------------
% This function trains a Partial Least Squares (PLS) regression model 
% with a varying number of components.
%
% Inputs:
% - train_x, train_y: Training features and labels.
% - val_x, val_y: Validation features and labels.
% - n_fea: Number of features to determine 
%          the maximum number of components for PLS.
%
% Outputs:
% - best_mdl: Trained PLS model with the best performance.
% - best_train_rsquare: R-squared value for the training set 
%                      of the best model.
% - best_val_rsquare: R-squared value for the validation set 
%                     of the best model.
% - best_val_rmse: RMSE for the validation set of the best model.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
num_train = size(train_x, 1);
num_val = size(val_x, 1);
best_val_rmse = inf;
best_train_rsquare = -inf;
best_val_rsquare = -inf;
best_mdl = [];

% Train PLS model with different numbers of components
for n_comp = 1:n_fea
    [~, ~, ~, ~, BETA] = plsregress(train_x, train_y, n_comp);
    yPred_train = [ones(num_train, 1), train_x] * BETA;
    yPred_val = [ones(num_val, 1), val_x] * BETA;
    % Evaluate PLS model
    [train_rsquare_new, ~, ~] = model_evaluation(yPred_train, train_y);
    [val_rsquare_new, val_rmse_new, ~] = ...
        model_evaluation(yPred_val, val_y);

    % Select the model based on validation RMSE 
    % and generalization performance
    if val_rmse_new < best_val_rmse && train_rsquare_new >= val_rsquare_new
        best_val_rmse = val_rmse_new;
        best_train_rsquare = train_rsquare_new;
        best_val_rsquare = val_rsquare_new;
        best_mdl.BETA = BETA;
        best_mdl.n_comp = n_comp;
    end
end
end