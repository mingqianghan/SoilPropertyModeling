clc;
clear;
close all;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
results_file_path = 'results\lab\wc';
results_file_name = 'existing_model.csv';

% Define parameters
lab_exptype = 'WC';  
cur_expnum = {'R1', 'R2', 'R3'};
cur_cabletype = {'SC', 'LC'};
Predictors = {'Mag', 'Phs', 'MaP'}; 
num_max_vr = 20;
rg_model = 'SVM';  % LR, SVM
vr_selection = 'MRMR';

% Load data
data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(vr_selection, '_', rg_model);

write_data = check_model(results_file_path, ...
                         full_results_path, ...
                         model_name);

% Iterate over predictors, experiment setups, and cable types
for k = 1:length(Predictors)
    fprintf('\nVS Method: %s, Regression model: %s\n', vr_selection, rg_model);
    fprintf('Features: %s\n', Predictors{k});

    for i = 1:length(cur_expnum)
        % Split validation and training data by experiment number
        val_idx = strcmp({data.expnum}, cur_expnum{i});
        val_data_split = data(val_idx);
        train_data_split = data(~val_idx);

        for j = 1:length(cur_cabletype)
            % Split validation and training data by cable type
            val_data = val_data_split(strcmp({val_data_split.cabletype}, cur_cabletype{j}));
            train_data = train_data_split(strcmp({train_data_split.cabletype}, cur_cabletype{j}));

            % Generate output label
            output_label = strcat(Predictors{k}, '_', cur_cabletype{j}, '_', cur_expnum{i});

            % Prepare data for training and validation
            [train_x, train_y, val_x, val_y] = Prepare_lab_data(train_data, val_data, Predictors{k}, 'WC_Prepared');

            % Train model using MRMR-based feature selection
            [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
            fprintf('Cable_Type(%s), Val_Set(%s), Var_Num(%d): \n', cur_cabletype{j}, cur_expnum{i}, best_var_num);

            % Save model performance
            save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path);
        end
    end
end
