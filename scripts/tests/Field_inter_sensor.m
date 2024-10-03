clc;
clear;
close all;

% File paths
year = '24';
mainpath = 'data\UG nodes';

plot_name = {'EP', 'LP'};
N_type = {'WN', 'ON'};
Predictors = {'Mag', 'Phs', 'MaP'}; 
num_max_vr = 20;
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

output_label = 'none';
write_data = false;
results_file_path = 'none';


all_data = access_all_field_data(year, mainpath);


for j = 1:length(Predictors)
    fprintf('\nFeatures: %s\n', Predictors{j});

    for i = 1: length(plot_name)
        for k = 1:length(N_type)
            matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC')&&strcmp(x.Plotname, plot_name{i})&&strcmp(x.Ntype, N_type{k}), all_data);
            [data_x_field, data_y_field, ~] = extract_and_clean_data( all_data(matches), 'field', Predictors{j}, 'VWC');

            [train_x, train_y, val_x, val_y] = train_val_split(data_x_field, data_y_field, 'ratio', 'train_ratio', 0.8);

            [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
            fprintf('Plot(%s) Ntype(%s) Varnum(%d)\n', plot_name{i}, N_type{k}, best_var_num);
            output_label = strcat(Predictors{j});
            save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
        end
    end
end
