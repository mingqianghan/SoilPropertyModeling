clc;
clear;
close all;

num_max_vr = 100;
fs_method = {'CARS', 'MRMR', 'SPA'};    % MRMR, SPA, CARS, PLS_VIP
rg_model = 'ANN';      % ANN, ANN_v2
OptParams = true;

training_ratio = 0.80;

for fm = 1:length(fs_method)
    % File paths
    year = '24';
    mainpath = 'data\UG nodes';
    results_file_path = 'results_new_old_model\Field_inter_sensor\NO3_80_no_outliers';
    results_file_name = 'existing_model.csv';

    plot_name = {'EP', 'LP'};
    N_type = {'WN', 'ON'};
    Predictors = {'Mag', 'Phs', 'MaP'};

    full_results_path = fullfile(results_file_path, results_file_name);
    model_name = strcat(fs_method{fm}, '_', rg_model);

    % Check if model already exists and create necessary directories
    write_data = check_model(results_file_path, full_results_path, ...
        model_name, fs_method{fm});


    all_data = access_all_field_data(year, mainpath);


    for j = 1:length(Predictors)
        fprintf('\nFeatures: %s\n', Predictors{j});

        for i = 1: length(plot_name)
            for k = 1:length(N_type)
                matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC')&&strcmp(x.Plotname, plot_name{i})&&strcmp(x.Ntype, N_type{k}), all_data);
                [data_x_field, data_y_field, ~] = extract_and_clean_data(all_data(matches), 'field', Predictors{j}, 'NO3');

                [train_x, train_y, val_x, val_y] = train_val_split_remove_outliers(data_x_field, data_y_field, 'ratio', 'train_ratio', training_ratio);

                [best_mdl, best_fs] = train_model_with_feature_selection(train_x, train_y, val_x, val_y, num_max_vr, fs_method{fm}, rg_model, OptParams);

                fprintf('Plot(%s) Ntype(%s) Varnum(%d)\n', plot_name{i}, N_type{k}, length(best_mdl.f_idx));
                % best_mdl.mdl.ModelParameters
                % fprintf('Cable(%s), Val Set(%s), Varnum(%d)\n', cur_cabletype{i}, cur_expnum{j}, length(best_mdl.f_idx));

                output_label = strcat(Predictors{j}, '_', plot_name{i}, '_', N_type{k});
                save_model_performance(best_mdl, best_fs, train_x, train_y, val_x, val_y, fs_method{fm}, rg_model, output_label, write_data, results_file_path);

                % [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
                % fprintf('Plot(%s) Ntype(%s) Varnum(%d)\n', plot_name{i}, N_type{k}, best_var_num);
                % output_label = strcat(Predictors{j});
                % save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
            end
        end
    end
end
