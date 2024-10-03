clc;
clear;
close all;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

results_file_path = 'results\lab\wc_N';
results_file_name = 'existing_model.csv';

% % Define parameters
cur_cabletype = {'SC', 'LC'};
Predictors = {'Mag', 'Phs', 'MaP'}; % , 'Phs', 'MaP'
cur_expnum = {'R1', 'R2', 'R3'};
num_max_vr = 20;
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(vr_selection, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, model_name);


% Load data
data_wc = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);
data_N = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);
for k = 1:length(cur_expnum)
    fprintf('\nVal: %s\n', cur_expnum{k});
    for j = 1:length(Predictors)
        for i = 1: length(cur_cabletype)
            matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_wc);
            [data_x_wc, data_y_wc, ~] = extract_and_clean_data( data_wc(matches), 'lab', Predictors{j}, 'WC_Prepared');
            % matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_N);
            matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i})&& strcmp(x.expnum, cur_expnum{k}), data_N);
            [data_x_N, data_y_N, ~] = extract_and_clean_data( data_N(matches), 'lab', Predictors{j}, 'WC');

            train_x = data_x_wc;
            train_y = data_y_wc;
            val_x = data_x_N;
            val_y = data_y_N;

            [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
            fprintf('Cable(%s), Var(%s) Varnum(%d)\n', cur_cabletype{i}, Predictors{j},  best_var_num);
            output_label = strcat(Predictors{j}, '_', cur_cabletype{i});
            save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
        end
    end
end
