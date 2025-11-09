clc;
clear;
close all;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

results_file_path = 'results\lab\wc_N';
results_file_name = 'existing_model.csv';

gt_subpath = 'Lab\LC_Angle.xlsx';
lab_exptype = 'WC_Bending';
lab_expnum = 'R1';
lab_expcbtype = 'LC';

[data_val, gt_val, num_samples] = load_lab_data(mainpath, lab_exptype, ...
                          lab_expnum, lab_expcbtype, gt_subpath);


% % Define parameters
cur_cabletype = {'LC'};
Predictors = {'Mag', 'Phs', 'MaP'}; % , 'Phs', 'MaP'
num_max_vr = 50;
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(vr_selection, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, model_name);


% Load data
data_wc = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);


for j = 1:length(Predictors)
    for i = 1: length(cur_cabletype)
        matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_wc);
        [data_x_wc, data_y_wc, ~] = extract_and_clean_data( data_wc(matches), 'lab', Predictors{j}, 'WC_Calculated');

        train_x = data_x_wc;
        train_y = data_y_wc;
        
        if strcmp (Predictors{j}, 'Mag')
            val_x = data_val.mag(:, 10:end);
        elseif strcmp (Predictors{j}, 'Phs')
            val_x = data_val.phs(:, 10:end);
        elseif strcmp (Predictors{j}, 'MaP')
            val_x = [data_val.mag(:, 10:end) data_val.phs(:, 10:end)];
        end
        
        val_y = gt_val.WC_Calculated;

        [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
        fprintf('Cable(%s), Var(%s) Varnum(%d)\n', cur_cabletype{i}, Predictors{j},  best_var_num);
        output_label = strcat(Predictors{j}, '_', cur_cabletype{i});
        save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
    end
end
