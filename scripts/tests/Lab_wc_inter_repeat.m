clc;
clear;
close all;

num_max_vr = 100;
fs_method = 'SPA'; % MRMR, SPA, CARS, or PLS_VIP
rg_model = 'ANN';      % SVM, PLS, ANN  (LR)
OptParams = true;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
results_file_path = 'results_new\Lab_wc_inter_repeat';
results_file_name = 'existing_model.csv';

% Define parameters 
cur_expnum = {'R1', 'R2', 'R3'};
cur_cabletype = {'SC', 'LC'};
Predictors = {'Mag', 'Phs', 'MaP'}; 


% Load data
data = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(fs_method, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, ...
                         model_name, fs_method);

fprintf('\nVS Method: %s, Regression model: %s\n', fs_method, rg_model);
for k = 1:length(Predictors)
    fprintf('\nFeatures: %s\n', Predictors{k});
    for i = 1:length(cur_cabletype)
        matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data);
        [data_x_valid, data_y_valid, data_category] = extract_and_clean_data(data(matches), 'lab', Predictors{k}, 'WC_Calculated');
        for j = 1:length(cur_expnum)
            [train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, ...
                'category', 'val_categories', cur_expnum{j}, 'category_array', data_category);

            [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);
            % best_mdl.mdl.userdata.scaleSettings

            fprintf('Cable(%s), Val Set(%s), Varnum(%d)\n', cur_cabletype{i}, cur_expnum{j}, length(best_mdl.f_idx));

            output_label = strcat(Predictors{k}, '_', cur_cabletype{i}, '_', cur_expnum{j});
            save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);

        end
    end
end