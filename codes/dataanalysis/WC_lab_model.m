clc
clear
close all

% file paths
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

% Define parameters
lab_exptype = 'WC';  

data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

fre = calculate_frequencies_Hz();

cur_expnum = {'R1', 'R2', "R3"};
cur_cabletype = {'SC', 'LC'};

% Initialize an empty table with the correct structure or load the existing one
if exist('results\WC_lab_performance.csv', 'file')
    results_table = readtable('results\WC_lab_performance.csv');  % Load existing table
else
    % Create an empty table with the same structure as new_data
    results_table = table([], [], [], [], [], [], [], [], ...
        'VariableNames', {'Label', 'Var_Num', 'Train_R2', ...
                          'Train_RMSE', 'Train_MAE', 'Val_R2', ...
                          'Val_RMSE', 'Val_MAE'});  
end

for i = 1:length(cur_expnum)
    val_idx = strcmp({data.expnum}, cur_expnum{i});
    val_data_split = data(val_idx);
    train_data_split = data(~val_idx);
    
    for j = 1:length(cur_cabletype)
        val_data = val_data_split(strcmp({val_data_split.cabletype}, cur_cabletype{j}));
        train_data = train_data_split(strcmp({train_data_split.cabletype}, cur_cabletype{j}));

        val_x = arrayfun(@(x) x.mag(:, 10:end), val_data, 'UniformOutput', false);
        val_x = vertcat(val_x{:});

        train_x = arrayfun(@(x) x.mag(:, 10:end), train_data, 'UniformOutput', false);
        train_x = vertcat(train_x{:});

        % Use arrayfun to extract WC_Calculated and concatenate
        val_y = arrayfun(@(x) x.gt.WC_Calculated, val_data, 'UniformOutput', false);
        val_y = vertcat(val_y{:});

        train_y = arrayfun(@(x) x.gt.WC_Calculated, train_data, 'UniformOutput', false);
        train_y = vertcat(train_y{:});

        [score_idx, scores] = fsrmrmr(train_x, train_y);

        best_r_square = -inf;
        for k = 1:10
            fea_indices = score_idx(1:k);
            mdl = fitlm(train_x(:, fea_indices), train_y);

            yPred_val = predict(mdl, val_x(:, fea_indices));
            [r_square, rmse, mae] = model_evaluation(yPred_val, val_y);
            if r_square > best_r_square
                best_r_square = r_square;
                best_rmse = rmse;
                best_mae = mae;
                best_var_num = k;
                best_mdl = mdl;
            end
        end

        best_fea_indices = score_idx(1:best_var_num);
        yPred_train = predict(best_mdl, train_x(:, best_fea_indices));
        [train_r_square, train_rmse, train_mae] = model_evaluation(yPred_train, train_y);

        yPred_val = predict(best_mdl, val_x(:, best_fea_indices));

        % Display results
        fprintf('Cable_Type(%s), Val_Set(%s), Var_Num(%d): \n', cur_cabletype{j}, cur_expnum{i}, best_var_num);
        fprintf('Train -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', train_r_square, train_rmse, train_mae);
        fprintf('Val   -> rsquare: %.2f, rmse: %.2f, mae: %.2f\n', best_r_square, best_rmse, best_mae);

        combined_string1 = strcat('MR2LR_Mg_', cur_cabletype{j}, '_', cur_expnum{i});
        combined_string6 = strcat('MR2_Mg_', cur_cabletype{j}, '_', cur_expnum{i});
        % Prepare data to append to the table
        new_data = table(...
            {combined_string1}, best_var_num, train_r_square, ...
            train_rmse, train_mae, best_r_square, best_rmse, best_mae, ...
            'VariableNames', {'Label', 'Var_Num', 'Train_R2', ...
                              'Train_RMSE', 'Train_MAE', 'Val_R2', ...
                              'Val_RMSE', 'Val_MAE'});

        combined_string2 = strcat(combined_string1, '_train_gt');
        combined_string3 = strcat(combined_string1, '_train_pred');
        combined_string4 = strcat(combined_string1, '_val_gt');
        combined_string5 = strcat(combined_string1, '_val_pred');

        % Convert the variable names into a cell array of character vectors
        predictions = table({combined_string2}, train_y');
        writetable(predictions, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
        predictions = table({combined_string3}, yPred_train');
        writetable(predictions, 'results\WC_lab_predictions.csv', 'WriteMode', 'append')
        predictions = table({combined_string3}, val_y');
        writetable(predictions, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');
        predictions = table({combined_string4}, yPred_val');
        writetable(predictions, 'results\WC_lab_predictions.csv', 'WriteMode', 'append');

        combined_string7 = strcat(combined_string6, '_idx');
        combined_string8 = strcat(combined_string6, '_score');
        fre_rank = table({combined_string7}, score_idx);
        fre_score = table({combined_string8}, scores);
        writetable(fre_rank, 'results\WC_lab_fre_score.csv', 'WriteMode', 'append');
        writetable(fre_score, 'results\WC_lab_fre_score.csv', 'WriteMode', 'append');


        % Save the updated table to CSV after each iteration
        writetable(new_data, 'results\WC_lab_performance.csv', 'WriteMode', 'append');

    end
end