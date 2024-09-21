clc;
clear;
close all;

% File paths
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

% Define parameters
lab_exptype = 'WC';  

% Access lab data
data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

% Frequency calculation
fre = calculate_frequencies_Hz();

% Experiment and cable types
cur_expnum = {'R1', 'R2', 'R3'};
cur_cabletype = {'SC', 'LC'};
Predictors = {'Mag', 'Phs', 'MaP'};

% Loop through experimental setups and cable types
for i = 1:length(cur_expnum)
    % Split validation and training data based on experiment number
    val_idx = strcmp({data.expnum}, cur_expnum{i});
    val_data_split = data(val_idx);
    train_data_split = data(~val_idx);
    
    for j = 1:length(cur_cabletype)
        % Further split based on cable type
        val_data = val_data_split(strcmp({val_data_split.cabletype}, cur_cabletype{j}));
        train_data = train_data_split(strcmp({train_data_split.cabletype}, cur_cabletype{j}));

        % Extract features and target for validation and training sets
        val_x = vertcat(arrayfun(@(x) x.mag(:, 10:end), val_data, 'UniformOutput', false));
        train_x = vertcat(arrayfun(@(x) x.mag(:, 10:end), train_data, 'UniformOutput', false));

        val_x = vertcat(val_x{:});
        train_x = vertcat(train_x{:});

        % Extract the ground truth (WC_Calculated) for val and train sets
        val_y = vertcat(arrayfun(@(x) x.gt.WC_Calculated, val_data, 'UniformOutput', false));
        train_y = vertcat(arrayfun(@(x) x.gt.WC_Calculated, train_data, 'UniformOutput', false));

        val_y = vertcat(val_y{:});
        train_y = vertcat(train_y{:});

        % Feature selection using MRMR
        [score_idx, scores] = fsrmrmr(train_x, train_y);

        % Train the model using the selected features
        best_r_square = -inf;
        for k = 1:10
            fea_indices = score_idx(1:k);
            mdl = fitlm(train_x(:, fea_indices), train_y);

            % Validate the model
            yPred_val = predict(mdl, val_x(:, fea_indices));
            [r_square, rmse, mae] = model_evaluation(yPred_val, val_y);
            
            % Track the best model
            if r_square > best_r_square
                best_r_square = r_square;
                best_rmse = rmse;
                best_mae = mae;
                best_var_num = k;
                best_mdl = mdl;
            end
        end

        % Evaluate the model on the training set
        best_fea_indices = score_idx(1:best_var_num);
        yPred_train = predict(best_mdl, train_x(:, best_fea_indices));
        [train_r_square, train_rmse, train_mae] = model_evaluation(yPred_train, train_y);

        % Reevaluate on validation set with the best model
        yPred_val = predict(best_mdl, val_x(:, best_fea_indices));

        % Display results
        fprintf('Cable_Type(%s), Val_Set(%s), Var_Num(%d): \n', cur_cabletype{j}, cur_expnum{i}, best_var_num);
        fprintf('Train -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', train_r_square, train_rmse, train_mae);
        fprintf('Val   -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', best_r_square, best_rmse, best_mae);

        % Prepare labels for saving results
        combined_label = strcat('MR2LR_Mg_', cur_cabletype{j}, '_', cur_expnum{i});
        combined_base = strcat('MR2_Mg_', cur_cabletype{j}, '_', cur_expnum{i});

        % Append performance results to the results table
        new_data = table({combined_label}, best_var_num, train_r_square, ...
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
end