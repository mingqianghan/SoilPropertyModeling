function [best_mdl, best_var_num, score_idx, scores] = ...
          MRMR_based_models(train_x, train_y, val_x, val_y, ...
                            num_max_vr, rg_model)
    % Trains a regression model using MRMR (Minimum Redundancy Maximum 
    % Relevance) feature selection and selects the best model based on 
    % validation performance.
    %
    % Author: Mingqiang Han
    % Date: 09-20-24
    %
    % Description:
    % This function applies MRMR feature selection to the training data 
    % and trains a regression model (based on the choice) using the top 
    % features based on the MRMR ranking. It evaluates the models on the 
    % validation set and tracks the best model based on the Rsquared value.
    % The function returns the best model, the number of selected features,
    % and the feature rankings.
    %
    % Inputs:
    %   train_x     - Training feature matrix.
    %   train_y     - Training target vector.
    %   val_x       - Validation feature matrix.
    %   val_y       - Validation target vector.
    %   num_max_vr  - Maximum number of features to select and evaluate.
    %   rg_model    - Regression model to use 
    %                 ('LR' for Linear Regression, 
    %                  'SVM' for Support Vector Machine,
    %                  more will be added).
    %
    % Outputs:
    %   best_mdl    - The best regression model based on validation
    %                 Rsquared values.
    %   best_var_num- The number of selected features for the best model.
    %   score_idx   - Ranked indices of selected features based on 
    %                 MRMR scores.
    %   scores      - MRMR scores for each feature.
    %
   
    
    % Feature selection using MRMR (Minimum Redundancy Maximum Relevance)
    % fsrmrmr returns the ranked indices of features and their MRMR scores
    [score_idx, scores] = fsrmrmr(train_x, train_y);
    
    % Initialize variables to track the best model and highest 
    % Rsquared value
    best_r_square = -inf;

    % Iterate over the number of selected features (from 1 to num_max_vr)
    for k = 1:num_max_vr
        % Select the top 'k' features based on MRMR ranking
        fea_indices = score_idx(1:k);

        % Train the regression model using the selected features
        if strcmp(rg_model, 'LR')
            % Train a Linear Regression model
            mdl = fitlm(train_x(:, fea_indices), train_y);
        elseif strcmp(rg_model, 'SVM')
            % Train a Support Vector Machine (SVM) model
            mdl = fitrsvm(train_x(:, fea_indices), train_y);
        end
        
        % Validate the model by predicting on the validation set
        yPred_val = predict(mdl, val_x(:, fea_indices));

        % Evaluate the model on the validation data and calculate 
        % the Rsquared value
        [r_square, ~, ~] = model_evaluation(yPred_val, val_y);
                
        % Track the best model based on the highest Rsquared value
        if r_square > best_r_square
            % Update best Rsquared value
            best_r_square = r_square;
            % Update number of selected features for the best model
            best_var_num = k;
            % Update the best model
            best_mdl = mdl;          
        end
    end
end
