clc;
clear;
close all;

% File paths
year = '24';
mainpath = 'data\UG nodes';

plot_name = {'EP', 'LP'};
N_type = {'WN', 'ON'};
Predictors = {'Mag', 'Phs', 'MaP'}; 
num_max_vr = 50;
rg_model = 'PLS';  % LR, SVM
vr_selection = 'MRMR';

output_label = 'none';
write_data = false;
results_file_path = 'none';

% % Create grids for all combinations
% [A, B] = ndgrid(plot_name, N_type);
% 
% % Concatenate the combinations with an underscore
% combinations = strcat(A(:), '_', B(:));

% combinations = {'EP_WN', 'LP_WN', 'LP_ON'};
combinations = {'EP_WN', 'EP_ON', 'LP_WN', 'LP_ON'};


all_data = access_all_field_data(year, mainpath);


for j = 1:length(Predictors)
    fprintf('\nFeatures: %s\n', Predictors{j});
    for i = 1:length(combinations)
  
        % matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC')&&~(strcmp(x.Plotname, 'EP')&&strcmp(x.Ntype, 'ON')), all_data);
        matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), all_data);
       
        [data_x_field, data_y_field, data_categories] = extract_and_clean_data( all_data(matches), 'field', Predictors{j}, 'VWC');
        
        [train_x, train_y, val_x, val_y] = train_val_split(data_x_field, data_y_field, 'category', 'val_categories', combinations{i}, 'category_array',data_categories);

        [best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
        fprintf('Val(%s) Varnum(%d)\n', combinations{i}, best_var_num);
        output_label = strcat(Predictors{j});
        save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path)
    
    end
end
