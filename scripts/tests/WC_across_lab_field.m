clc;
clear;
close all;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
% N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';
data_wc = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);
% data_N = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);


% File paths
year = '24';
mainpath = 'data\UG nodes';
data_field = access_all_field_data(year, mainpath);

results_file_path = 'results\lab_field\wc';
results_file_name = 'existing_model.csv';

% % Define parameters
plot_name = {'EP', 'LP'};
N_type = {'WN', 'ON'};
Predictors = {'Mag', 'Phs', 'MaP'}; 
num_max_vr = 20;
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(vr_selection, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, model_name);



for j = 1:length(Predictors)
    fprintf('\nFeatures: %s\n', Predictors{j});

    matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), data_wc);
    [data_x_wc, data_y_wc, ~] = extract_and_clean_data( data_wc(matches), 'lab', Predictors{j}, 'WC_Calculated');


    for i = 1: length(plot_name)
        for k = 1:length(N_type)
            matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC')&&strcmp(x.Plotname, plot_name{i})&&strcmp(x.Ntype, N_type{k}), data_field);
            [data_x_field, data_y_field, ~] = extract_and_clean_data( data_field(matches), 'field', Predictors{j}, 'VWC');

            train_x = data_x_wc;
            train_y = data_y_wc;
            val_x = data_x_field;
            val_y = data_y_field;

            [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
            fprintf('Plot(%s) Ntype(%s) Varnum(%d)\n', plot_name{i}, N_type{k}, best_var_num);
            output_label = strcat(Predictors{j});
            save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
        end
    end
end
