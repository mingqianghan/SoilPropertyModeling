
function [mdl, train_scores, val_scores] = train_and_evaluate_model( ...
          rg_model, train_x, train_y, val_x, val_y, n_fea, OptParams)
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
% - train_scores: performance_metrics for training set.
% - val_scores: performance_metrics for validation set.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------

switch rg_model
    case 'LR'  % Linear Regression
        mdl = fitlm(train_x, train_y);
        [train_scores, val_scores] = evaluate_model( ...
            mdl, train_x, train_y, val_x, val_y);

    case 'ANN'  % Artificial Neural Network
        if OptParams
            fixed_params = {'Standardize', true;};
            param_sets = {'LayerSizes', 1:9; ...
                'Lambda',  [1e-5, 1e-4, 0.001, 0.01, 0.1, 1];
                'Activations', {'relu', 'tanh', 'sigmoid'};
                'LayerWeightsInitializer', {'glorot','he'};};
            % param_sets = {'LayerSizes', 1; ...
            %     'Lambda',  [1e-5];
            %      'Activations', {'relu'};};
            [mdl, train_scores, val_scores] = train_model( ...
                @fitrnet, train_x, train_y, val_x, val_y, ...
                param_sets, fixed_params);
        else
            mdl = fitrnet(train_x, train_y, ...
                              'LayerSizes', 3, ...
                              'Activations', 'relu', ...
                              'Standardize', true, ...
                              'Lambda', 0.001);
            [train_scores, val_scores] = evaluate_model( ...
                mdl, train_x, train_y, val_x, val_y);
        end
    case 'ANN_v2'
        [mdl, train_scores, val_scores]= ann_model(train_x, train_y, val_x, val_y);

    case 'SVM'  % Support Vector Machine
        if OptParams
            set(0,'DefaultFigureVisible','off')
            fixed_params = {};
            param_sets = {'OptimizeHyperparameters', {'all'}, ...
              'HyperparameterOptimizationOptions', struct( ...
              'Optimizer', 'bayesopt', ...
              'MaxObjectiveEvaluations', 100, ...
              'Kfold', 3)};
            % param_sets = {'BoxConstraint', [0.1, 1, 10, 50, 100], ...
            %     'Epsilon', [0.01, 0.1, 1, 1.5, 2], ...
            %     'KernelFunction', {'linear', 'gaussian'}, ...
            %     'KernelScale', {0.1, 1, 10, 'auto'}, ...
            %     'Nu', [0.1, 0.5, 0.8], ...
            %     'Standardize', {true, false} };
            evalc('[mdl, train_scores, val_scores] = train_model(@fitrsvm, train_x, train_y, val_x, val_y, param_sets, fixed_params);');
        else
            mdl = fitrsvm(train_x, train_y, ...
                  'KernelFunction', 'gaussian', ...
                  'KernelScale', 'auto');
            [train_scores, val_scores] = evaluate_model( ...
                mdl, train_x, train_y, val_x, val_y);
        end

    case 'PLS'  % Partial Least Squares
        [mdl, train_scores, val_scores] = train_pls( ...
            train_x, train_y, val_x, val_y, n_fea);

    otherwise
        error('Unsupported model type');
end
end


%% Function: evaluate_model (Helper function)
function [train_scores, val_scores] = ...
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
% - train_scores: performance_metrics for training set.
% - val_scores: performance_metrics for validation set.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
yPred_train = predict(mdl, train_x);
yPred_val = predict(mdl, val_x);
train_scores = model_evaluation(yPred_train, train_y);
val_scores = model_evaluation(yPred_val, val_y);
end


%% Function: train_model (Helper function)
function [best_mdl, best_train_scores, best_val_scores] = train_model( ...
          train_func, train_x, train_y, val_x, val_y, param_sets, ...
          fixed_params)
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
% - best_train_scores:
%   performance metrics for the training set of the best model.
% - best_val_scores:
%   performance metrics for the validation set of the best model.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
best_val_rmse = inf;
best_train_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_val_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_mdl = [];

% Generate all combinations of parameters
param_combinations = all_combinations(param_sets);
for i = 1:size(param_combinations, 1)
    params = param_combinations{i};
    % Set random seed for each training iteration
    % to ensure reproducibility
    rng(3453);

    warnState = warning('off', 'all');
    mdl = train_func(train_x, train_y, params{:}, fixed_params{:});
    warning(warnState);

    [train_scores, val_scores] = evaluate_model( ...
        mdl, train_x, train_y, val_x, val_y);

    % Select the model based on validation RMSE
    % and generalization performance
    if val_scores.rmse < best_val_rmse && ...
            train_scores.rsquare >= val_scores.rsquare
        best_val_rmse = val_scores.rmse;
        best_train_scores = train_scores;
        best_val_scores = val_scores;
        best_mdl = mdl;
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
function [best_mdl, best_train_scores, best_val_scores] = train_pls( ...
          train_x, train_y, val_x, val_y, n_fea)
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
% - best_train_scores:
%   performance metrics for the training set of the best model.
% - best_val_scores:
%   performance metrics for the validation set of the best model.
%
% Author: Mingqiang Han
% Date: 10-09-24
% -------------------------------------------------------------------------
num_train = size(train_x, 1);
num_val = size(val_x, 1);
best_val_rmse = inf;
best_train_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_val_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_mdl = [];

% Train PLS model with different numbers of components
for n_comp = 1:n_fea
    [~, ~, ~, ~, BETA] = plsregress(train_x, train_y, n_comp);
    yPred_train = [ones(num_train, 1), train_x] * BETA;
    yPred_val = [ones(num_val, 1), val_x] * BETA;
    % Evaluate PLS model
    train_scores = model_evaluation(yPred_train, train_y);
    val_scores = model_evaluation(yPred_val, val_y);

    % Select the model based on validation RMSE 
    % and generalization performance
    if val_scores.rmse < best_val_rmse && ...
            train_scores.rsquare >= val_scores.rsquare
        best_val_rmse = val_scores.rmse;
        best_train_scores = train_scores;
        best_val_scores = val_scores;
        best_mdl.BETA = BETA;
        % best_mdl.n_comp = n_comp;
    end
end
end


function [best_mdl, best_train_scores, best_val_scores] = ann_model(train_x, train_y, val_x, val_y)

rng(3453);

[train_x_S, scaleSettings] = mapminmax(train_x');
val_x_S =  mapminmax('apply', val_x', scaleSettings);

% Combine training and validation data for training and record indices
all_x = [train_x_S, val_x_S];
all_y = [train_y', val_y'];
nTrain = size(train_x, 2);
nVal   = size(val_x, 2);

% Define hidden layer configurations to test
hiddenLayerConfigs = {2, 4, 6, 8, [2 2], [2 3], [3 3]};
% hiddenLayerConfigs = {2, 4, 6};
% training function:
trainingFunctions = {'trainlm', 'trainscg', 'traingd'};
% trainingFunctions = {'trainlm','trainscg'};
% Regularization coefficients to test (helps control overfitting)
regularization_list = [0, 0.01, 0.03, 0.05, 0.1, 0.3, 0.5];
activationFunctions = {'tansig', 'logsig', 'poslin', 'purelin'};  % Activation functions for hidden layers
learningRates = [0.0001, 0.001, 0.01, 0.1];

best_val_rmse = inf;
best_train_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_val_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
best_net = [];


for tf = 1:length(trainingFunctions)
    trainFcn = trainingFunctions{tf};

    for lr = 1:length(learningRates)
        lr_val = learningRates(lr);

        % Skip unnecessary learning rates for trainlm
        if strcmp(trainFcn, 'trainlm') && lr_val ~= learningRates(1)
            continue;
        end

        for hl = 1:length(hiddenLayerConfigs)
            config = hiddenLayerConfigs{hl};
            for reg = 1:length(regularization_list)
                reg_val = regularization_list(reg);
                for af = 1:length(activationFunctions)
                    actFunc = activationFunctions{af};

                    % Create a feedforward network with the current hyperparameters
                    net = feedforwardnet(config, trainFcn);

                    % Set activation functions for each hidden layer (excluding output layer)
                    for i = 1:(length(net.layers)-1)
                        net.layers{i}.transferFcn = actFunc;
                    end

                    % For regression, set output layer transfer function to 'purelin'
                    net.layers{end}.transferFcn = 'purelin';

                    % Training parameters
                    net.trainParam.epochs = 100;
                    net.trainParam.showWindow = false;
                    if isfield(net.trainParam, 'lr')  % Only set if applicable
                        net.trainParam.lr = lr_val;
                    end
                    net.performParam.regularization = reg_val;

                    % Explicitly define training and validation indices
                    net.divideFcn = 'divideind';
                    net.divideParam.trainInd = 1:nTrain;
                    net.divideParam.valInd = nTrain + (1:nVal);
                    net.divideParam.testInd = [];

                    % Train the network
                    [net, tr] = train(net, all_x, all_y);

                    % Evaluate performance on the validation set using mean squared error
                    val_pred = net(val_x_S);
                    val_scores = model_evaluation(val_pred, val_y');

                    train_pred = net(train_x_S);
                    train_scores = model_evaluation(train_pred, train_y');


                    % Update best network if current configuration improves performance
                    if val_scores.rmse < best_val_rmse && train_scores.rsquare >= val_scores.rsquare
                        best_val_rmse = val_scores.rmse;
                        best_net = net;
                        best_train_scores = train_scores;
                        best_val_scores = val_scores;
                    end
                end
            end
        end  % End Regularization loop
    end  % End Hidden Layers loop
end  % End Training Functions loop

% Save scaling settings in the best network for future use (e.g., test data)
best_net.userdata.scaleSettings = scaleSettings;
best_mdl = best_net;

end