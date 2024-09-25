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
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

% Load data
data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(vr_selection, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, model_name);

% Iterate over predictors, experiment setups, and cable types
for k = 1:length(Predictors)
    fprintf('\nVS Method: %s, Regression model: %s\n', vr_selection, rg_model);
    fprintf('Features: %s\n', Predictors{k});
    
    for i = 1:length(cur_cabletype)
        matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data);
        [data_x_valid, data_y_valid, data_category] = extract_and_clean_data( data(matches), 'lab', Predictors{k}, 'WC_Calculated');
        for j = 1:length(cur_expnum)
            [train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, ...
                                                   'category', 'val_categories', cur_expnum{j}, 'category_array', data_category);
            [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
            fprintf('Cable(%s), Val Set(%s), Varnum(%d)\n', cur_cabletype{i}, cur_expnum{j}, best_var_num);
            output_label = strcat(Predictors{k}, '_', cur_cabletype{i}, '_', cur_expnum{j});
            save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)

        end
    end
end