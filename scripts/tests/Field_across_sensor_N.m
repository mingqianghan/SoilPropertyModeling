clc;
clear;
close all;

num_max_vr = 100;
fs_method = {'CARS', 'MRMR', 'SPA'};    % MRMR, SPA, CARS, PLS_VIP
rg_model = 'ANN';      % LR, SVM, PLS, ANN
OptParams = true;

training_ratio = 0.80;

for fm = 1:length(fs_method)
    % File paths
    year = '24';
    mainpath = 'data\UG nodes';
    results_file_path = 'results_new_old_model\Field_accross_sensor\NO3_80_th100_cat';
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

        matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), all_data);
        [data_x_field, data_y_field, label] = extract_and_clean_data(all_data(matches), 'field', Predictors{j}, 'NO3');

        [train_x, train_y, val_x, val_y, train_label, val_label] = train_val_split_with_label(data_x_field, data_y_field, label, 'ratio', 'train_ratio', training_ratio);

        catTrain = categorical(train_label, categories(train_label));
        catTrain_dummy = dummyvar(catTrain);

        catVal = categorical(val_label, categories(catTrain)); 
        catVal_dummy = dummyvar(catVal);

        catTrain_dummy = catTrain_dummy(:, 1:end-1);
        catVal_dummy   = catVal_dummy(:, 1:end-1);

        [best_mdl, best_fs] = train_model_with_feature_selection_with_label(train_x, train_y, val_x, val_y, catTrain_dummy, catVal_dummy, num_max_vr, fs_method{fm}, rg_model, OptParams);
        %best_mdl.mdl.ModelParameters
        fprintf('Varnum(%d)\n', length(best_mdl.f_idx));
        fprintf('Train: %d %.2f-%.2f, Val: %d %.2f-%.2f\n', ...
            size(train_y, 1), min(train_y), max(train_y), ...
            size(val_y, 1), min(val_y), max(val_y));

        output_label = strcat(Predictors{j}, '_', ' ', '_', ' ');
        save_model_performance_with_label(best_mdl, best_fs, train_x, train_y, val_x, val_y, catTrain_dummy, catVal_dummy, fs_method{fm}, rg_model, output_label, write_data, results_file_path);

    end
end
