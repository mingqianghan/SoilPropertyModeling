clc;
clear;
close all;

num_max_vr = 100;
fs_method = 'CARS'; % MRMR, SPA, CARS, or PLS_VIP
rg_model = 'ANN';      % LR, SVM, PLS, ANN
OptParams = true;

% % Define parameters
cur_cabletype = {'SC', 'LC'};
Predictors = {'Mag', 'Phs', 'MaP'}; % , 'Phs', 'MaP'
cur_expnum = {'R1', 'R2', 'R3' };


% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

results_file_path = 'results_new\Lab_wc_across_calibration';
results_file_name = 'existing_model.csv';


% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(fs_method, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, ...
                         model_name, fs_method);


% Load data
data_wc = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);
data_N = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);

fprintf('\nVS Method: %s, Regression model: %s\n', fs_method, rg_model);
for k = 1:length(cur_expnum)
    fprintf('\nVal: %s\n', cur_expnum{k});
    for j = 1:length(Predictors)
        for i = 1: length(cur_cabletype)
            matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_wc);
            [data_x_wc, data_y_wc, ~] = extract_and_clean_data(data_wc(matches), 'lab', Predictors{j}, 'WC_Calculated');
            % matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_N);
            matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i})&& strcmp(x.expnum, cur_expnum{k}), data_N);
            [data_x_N, data_y_N, ~] = extract_and_clean_data( data_N(matches), 'lab', Predictors{j}, 'WC');
            matches_R4 = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i})&& strcmp(x.expnum, 'R4'), data_N);
            [data_x_N_R4, data_y_N_R4, ~] = extract_and_clean_data( data_N(matches_R4), 'lab', Predictors{j}, 'WC');

            train_x = data_x_wc;
            train_y = data_y_wc;
            val_x = [data_x_N; data_x_N_R4];
            val_y = [data_y_N; data_y_N_R4];

            [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);
            %best_mdl.mdl.ModelParameters

            fprintf('Cable(%s), Var(%s) Varnum(%d)\n', cur_cabletype{i}, Predictors{j},  length(best_mdl.f_idx));

            output_label = strcat(Predictors{j}, '_', cur_cabletype{i}, '_', cur_expnum{k});
            save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);
        end
    end
end
