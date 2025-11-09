clc;
clear;
close all;

num_max_vr = 100;
fs_method = {'MRMR', 'SPA'};
% fs_method = {'CARS', 'MRMR', 'SPA'};
rg_model = 'ANN';      % SVM, PLS, ANN  (LR)
OptParams = true;

training_ratio = 0.80;

for fm = 1:length(fs_method)
    % File paths
    mainpath = 'data';
    N_gt_subpath_urea = 'Lab\Nitrogen_Calibration.xlsx';
    data_urea = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath_urea);

    N_gt_subpath_NH4NO3 = 'Lab\Nitrogen_Calibration_NH4NO3.xlsx';
    data_NH4NO3 = access_all_lab_data(mainpath, 'NH4NO3', N_gt_subpath_NH4NO3);

    target = 'NH4';

    results_file_path = 'results_new_old_model\Lab_N_inter_repeat_NH4NO3_Urea_R2_R3\NH4';
    results_file_name = 'existing_model.csv';

    % Define parameters
    cur_expnum = {'R1', 'R2', 'R3'};
    cur_cabletype = {'SC', 'LC'};
    Predictors = {'Mag', 'Phs', 'MaP'};

    % Full path for results file
    full_results_path = fullfile(results_file_path, results_file_name);
    model_name = strcat(fs_method{fm}, '_', rg_model);

    % Check if model already exists and create necessary directories
    write_data = check_model(results_file_path, full_results_path, ...
        model_name, fs_method{fm});



    fprintf('\nVS Method: %s, Regression model: %s\n', fs_method{fm}, rg_model);
    for k = 1:length(Predictors)
        fprintf('\nFeatures: %s\n', Predictors{k});
        for i = 1:length(cur_cabletype)
            matches_urea = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_urea);
            [data_x_urea, data_y_urea, N_label] = extract_and_clean_data(data_urea(matches_urea), 'lab', Predictors{k}, target);

            matches_NH4NO3 = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data_NH4NO3);
            [data_x_NH4NO3, data_y_NH4NO3, ~] = extract_and_clean_data(data_NH4NO3(matches_NH4NO3), 'lab', Predictors{k}, target);

            % idx = (N_label == categorical("R2"));
            idx = ismember(N_label, categorical(["R2","R3"]));
            data_x_urea_new = data_x_urea(idx, :);
            data_y_urea_new = data_y_urea(idx, :);


            data_x = [data_x_urea_new; data_x_NH4NO3];
            data_y = [data_y_urea_new; data_y_NH4NO3];
            % data_x = data_x_NH4NO3;
            % data_y = data_y_NH4NO3;

            [train_x, train_y, val_x, val_y] = train_val_split_remove_outliers(data_x, data_y, 'ratio', 'train_ratio', training_ratio);

            [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method{fm}, rg_model, OptParams);
            %best_mdl.mdl.ModelParameters
            fprintf('Cable(%s), Varnum(%d)\n', cur_cabletype{i}, length(best_mdl.f_idx));

            output_label = strcat(Predictors{k}, '_', cur_cabletype{i}, '_', ' ');
            save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method{fm}, rg_model, output_label, write_data, results_file_path);
        end
    end
end
% for k = 1:length(Predictors)
%     fprintf('\nFeatures: %s\n', Predictors{k});
%     for i = 1:length(cur_cabletype)
%         matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data);
%         [data_x_valid, data_y_valid, ~] = extract_and_clean_data(data(matches), 'lab', Predictors{k}, 'totN');
%         [train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, 'ratio', 'train_ratio', training_ratio);
% 
%         [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);
%         best_mdl.mdl.ModelParameters
%         fprintf('Cable(%s), Varnum(%d)\n', cur_cabletype{i}, length(best_mdl.f_idx));
% 
%         output_label = strcat(Predictors{k}, '_', cur_cabletype{i}, '_', ' ');
%         save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);
% 
%     end
% end
% % for k = 1:length(Predictors)
% %     fprintf('\nFeatures: %s\n', Predictors{k});
% %     for i = 1:length(cur_cabletype)
% %         matches = arrayfun(@(x) strcmp(x.Cabletype, cur_cabletype{i}), data);
% %         [data_x_valid, data_y_valid, data_category] = extract_and_clean_data(data(matches), 'lab', Predictors{k}, 'Urea');
% %         for j = 1:length(cur_expnum)
% %             [train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, ...
% %                 'category', 'val_categories', cur_expnum{j}, 'category_array', data_category);
% % 
% %             [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method, rg_model, OptParams);
% % 
% %             fprintf('Cable(%s), Val Set(%s), Varnum(%d)\n', cur_cabletype{i}, cur_expnum{j}, length(best_mdl.f_idx));
% % 
% %             output_label = strcat(Predictors{k}, '_', cur_cabletype{i}, '_', cur_expnum{j});
% %             save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method, rg_model, output_label, write_data, results_file_path);
% % 
% %         end
% %     end
% % end