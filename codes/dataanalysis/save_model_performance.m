function save_model_performance(mdl, var_num, score_idx, scores, ...
                                train_x, train_y, val_x, val_y, ...
                                output_label)

% Evaluate the model on the training set
best_fea_indices = score_idx(1:var_num);

yPred_train = predict(mdl, train_x(:, best_fea_indices));
[train_r_square, train_rmse, train_mae] = model_evaluation(yPred_train, train_y);

% Evaluate the model on validation set
yPred_val = predict(mdl, val_x(:, best_fea_indices));
[val_r_square, val_rmse, val_mae] = model_evaluation(yPred_val, val_y);

% Display results
fprintf('Train -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', train_r_square, train_rmse, train_mae);
fprintf('Val   -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', val_r_square, val_rmse, val_mae);

% % Prepare labels for saving results
% combined_label = strcat('MR2LR_Mg_', cur_cabletype{j}, '_', cur_expnum{i});
% combined_base = strcat('MR2_Mg_', cur_cabletype{j}, '_', cur_expnum{i});

% Append performance results to the results table
new_data = table(output_label, best_var_num, train_r_square, ...
                 train_rmse, train_mae, best_r_square, best_rmse, best_mae, ...
                 'VariableNames', {'Label', 'Var_Num', 'Train_R2', 'Train_RMSE', 'Train_MAE', 'Val_R2', 'Val_RMSE', 'Val_MAE'});

        
train_labels = strcat(combined_label, '_train_gt');
train_gt_data = table({train_labels}, train_y');
        
train_labels = strcat(combined_label, '_train_pred');
train_pred_data = table({train_labels}, yPred_train');

val_labels = strcat(combined_label, '_val_gt');
val_gt_data = table({val_labels}, val_y');
        
val_labels = strcat(combined_label, '_val_pred');
val_pred_data = table({val_labels}, yPred_val');

% Frequency ranking and scores
fre_rank = table({strcat(combined_base, '_idx')}, score_idx);
fre_score = table({strcat(combined_base, '_score')}, scores);

% Save results to CSV files
writetable(new_data, 'results\WC_lab_performance.csv', 'WriteMode', 'append');
writetable(train_gt_data, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
writetable(train_pred_data, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
writetable(val_gt_data, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
writetable(val_pred_data, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
writetable(fre_rank, 'results\WC_lab_fre_score.csv', 'WriteMode', 'append');
writetable(fre_score, 'results\WC_lab_fre_score.csv', 'WriteMode', 'append');
end