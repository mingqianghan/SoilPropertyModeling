clc;
clear;
close all;

num_max_vr = 100;
fs_method = 'CARS';    % MRMR, SPA, CARS, or PLS_VIP
rg_model = 'ANN';      % SVM, PLS, ANN  (LR)
OptParams = true;

response_var = 'NO3';

% File paths
mainpath = 'data';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';
lab_data_N_exp = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);

matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), lab_data_N_exp);
lab_data_N_exp = lab_data_N_exp(matches);

% File paths
year = '24';
mainpath = 'data\UG nodes';
field_data = access_all_field_data(year, mainpath);

plot_name = {'EP', 'LP'};
N_type = {'WN', 'ON'};
Predictors = {'Mag', 'Phs', 'MaP'};

results_file_path = 'results\Lab_Field_N_withpred\NO3';
results_file_name = 'existing_model.csv';

% Full path for results file
full_results_path = fullfile(results_file_path, results_file_name);
model_name = strcat(fs_method, '_', rg_model);

% Check if model already exists and create necessary directories
write_data = check_model(results_file_path, full_results_path, ...
                         model_name, fs_method);

for j = 1:length(Predictors)
    fprintf('\nFeatures: %s\n', Predictors{j});

    [data_x_N_exp, data_y_N_exp, ~] = extract_and_clean_data(lab_data_N_exp, 'lab', Predictors{j}, response_var);

    % for i = 1: length(plot_name)
    %     for k = 1:length(N_type)
    %         matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC')&&strcmp(x.Plotname, plot_name{i})&&strcmp(x.Ntype, N_type{k}), field_data);
    %         [data_x_field, data_y_field, ~] = extract_and_clean_data(field_data(matches), 'field', Predictors{j}, response_var);
    % 
    %         [train_x_field, train_y_field, val_x, val_y, test_x, test_y] = train_val_test_split(data_x_field, data_y_field, 0.5, 0.25);
    % 
    %         train_x = [train_x_field; data_x_N_exp];
    %         train_y = [train_y_field; data_y_N_exp];
    % 
    %         [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);
    % 
    %         fprintf('Plot(%s) Ntype(%s) Varnum(%d)\n', plot_name{i}, N_type{k}, length(best_mdl.f_idx));
    %         fprintf('Train: %d %.2f-%.2f, Val: %d %.2f-%.2f, Test: %d %.2f-%.2f\n', ...
    %             size(train_y, 1), min(train_y), max(train_y), ...
    %             size(val_y, 1), min(val_y), max(val_y), ...
    %             size(test_y, 1), min(test_y), max(test_y));
    %         best_mdl.mdl.ModelParameters
    %         output_label = strcat(Predictors{j}, '_', plot_name{i}, '_', N_type{k});
    %         save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);
    % 
    %         yPred_test = model_predict(best_mdl, test_x);
    %         scores = model_evaluation(yPred_test, test_y);
    % 
    %         fprintf('Test -> Rsquare: %.2f, RMSE: %.2f, MAE: %.2f\n', ...
    %                 scores.rsquare, scores.rmse, scores.mae);
    %     end
    % end

    fprintf('\n All fields\n');
    matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), field_data);
    [data_x_field, data_y_field, ~] = extract_and_clean_data(field_data(matches), 'field', Predictors{j}, response_var);

    [train_x_field, train_y_field, val_x, val_y, test_x, test_y] = train_val_test_split(data_x_field, data_y_field, 0.5, 0.25);

    train_x = [train_x_field; data_x_N_exp];
    train_y = [train_y_field; data_y_N_exp];
    
    [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);

    fprintf('Varnum(%d)\n', length(best_mdl.f_idx));
    fprintf('Train: %d %.2f-%.2f, Val: %d %.2f-%.2f, Test: %d %.2f-%.2f\n', ...
        size(train_y, 1), min(train_y), max(train_y), ...
        size(val_y, 1), min(val_y), max(val_y), ...
        size(test_y, 1), min(test_y), max(test_y));
    best_mdl.mdl.ModelParameters
    output_label = strcat(Predictors{j}, '_', 'all', '_', 'all');
    save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);

    yPred_test = model_predict(best_mdl, test_x);
    scores = model_evaluation(yPred_test, test_y);

    fprintf('Test -> Rsquare: %.2f, RMSE: %.2f, MAE: %.2f\n', ...
        scores.rsquare, scores.rmse, scores.mae);
end


