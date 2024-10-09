function save_model_performance(best_mdl, best_fs, train_x, train_y, ...
                                val_x, val_y, fs_method, rg_model, ...
                                output_label, write_data, ...
                                results_file_path)
% -------------------------------------------------------------------------
% This function evaluates the performance of a trained regression model on 
% both training and validation datasets, saves the performance metrics, 
% predictions, and feature importance scores to CSV files if required.
%
% Inputs:
%   mdl           - Trained regression model
%   var_num       - Number of selected features for evaluation
%   score_idx     - Indices of selected features ranked by importance
%   scores        - Feature importance scores
%   train_x       - Training dataset (features)
%   train_y       - Ground truth labels for training data
%   val_x         - Validation dataset (features)
%   val_y         - Ground truth labels for validation data
%   vr_selection  - Variable selection method label
%   rg_model      - Regression model label
%   output_label  - Label for saving output files
%   write_data    - Boolean indicating whether to write data to files
%   file_path     - Path where the output files will be saved
%
% Outputs:
%   The function saves performance metrics, predictions, and feature 
%   importance scores in CSV files if write_data is true.
%
% Author: Mingqiang Han
% Date: 09-20-24
% -------------------------------------------------------------------------

% Select top features based on their importance
best_fea_indices = score_idx(1:var_num);

% Evaluate the model on the training set
yPred_train = predict(mdl, train_x(:, best_fea_indices));
[train_r_square, train_rmse, train_mae] = model_evaluation(yPred_train, ...
                                                           train_y);

% Evaluate the model on the validation set
yPred_val = predict(mdl, val_x(:, best_fea_indices));
[val_r_square, val_rmse, val_mae] = model_evaluation(yPred_val, val_y);

% Display results for both training and validation
fprintf('Train -> Rsquare: %.2f, RMSE: %.2f, MAE: %.2f\n', ...
        train_r_square, train_rmse, train_mae);
fprintf('Val   -> Rsquare: %.2f, RMSE: %.2f, MAE: %.2f\n', ...
        val_r_square, val_rmse, val_mae);

% Prepare file name and label information
file_name_base = strcat(vr_selection, '_', rg_model);
fre_label = strcat(vr_selection, '_', output_label);

% Prepare table for performance metrics
new_data = table({output_label}, var_num, train_r_square, train_rmse, ...
                 train_mae, val_r_square, val_rmse, val_mae, ...
                 'VariableNames', {'Label', 'Var_Num', ...
                 'Train_R2', 'Train_RMSE', 'Train_MAE', ...
                 'Val_R2', 'Val_RMSE', 'Val_MAE'});

% Prepare tables for ground truth and predictions (training)
train_labels = strcat(output_label, '_train_gt');
train_gt_data = table({train_labels}, train_y');

train_labels = strcat(output_label, '_train_pred');
train_pred_data = table({train_labels}, yPred_train');

% Prepare tables for ground truth and predictions (validation)
val_labels = strcat(output_label, '_val_gt');
val_gt_data = table({val_labels}, val_y');

val_labels = strcat(output_label, '_val_pred');
val_pred_data = table({val_labels}, yPred_val');

% Prepare tables for feature ranking and scores
fre_rank = table({strcat(fre_label, '_idx')}, score_idx);
fre_score = table({strcat(fre_label, '_score')}, scores);

% If write_data flag is true,
% save the performance metrics, predictions, and scores
if write_data
    % Save performance metrics to file
    file_name = strcat(file_name_base, '_performance.csv');
    path_name = fullfile(file_path, file_name);
    writetable(new_data, path_name, 'WriteMode', 'append');
    
    % Save predictions to file
    file_name = strcat(file_name_base, '_predictions.csv');
    path_name = fullfile(file_path, file_name);
    writetable(train_gt_data, path_name, 'WriteMode', 'append');
    writetable(train_pred_data, path_name, 'WriteMode', 'append');
    writetable(val_gt_data, path_name, 'WriteMode', 'append');
    writetable(val_pred_data, path_name, 'WriteMode', 'append');
    
    % Save feature importance scores to file
    file_name = strcat(file_name_base, '_scores.csv');
    path_name = fullfile(file_path, file_name);
    writetable(fre_rank, path_name, 'WriteMode', 'append');
    writetable(fre_score, path_name, 'WriteMode', 'append');

    model_name = strcat(file_name_base, '_', output_label, '.mat');
    full_model_path = fullfile(file_path, model_name);
    save(full_model_path, 'mdl');
end
end