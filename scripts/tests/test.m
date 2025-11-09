clc;
clear;
close all;

% File paths
year = '24';
mainpath = 'data\UG nodes';


% results_file_path = 'results\lab\wc';
% results_file_name = 'existing_model.csv';
% 
% % Define parameters
% lab_exptype = 'WC';  
% cur_expnum = {'R1', 'R2', 'R3'};
% cur_cabletype = {'SC', 'LC'};
% Predictors = {'Mag', 'Phs', 'MaP'}; 
% num_max_vr = 20;
% rg_model = 'LR';  % LR, SVM
% vr_selection = 'MRMR';

num_max_vr = 20;
rg_model = 'LR';  % LR, SVM
vr_selection = 'MRMR';

output_label = 'none';
write_data = false;
results_file_path = 'none';


% year = '24';
% mainpath = 'data\UG nodes';
all_data = access_all_field_data(year, mainpath);

cur_cabletype = 'LC';
matches = false(1, length(all_data));

for i = 1:length(all_data)

    if strcmp(all_data(i).Cabletype,cur_cabletype) && strcmp(all_data(i).Plotname,'LP')
          matches(i) = true;  % Mark the index where the match is found 
    end
end

% After the loop, extract the matched structs using the logical index
matched_data = all_data(matches);
train_ratio = 0.9;

[data_x_valid, data_y_valid, data_category] = extract_and_clean_data(matched_data, 'field', 'Mag', 'VWC');
[train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, ...
                                                   'category', 'val_categories', 'LP_ON' , 'category_array', data_category);
% [train_x, train_y, val_x, val_y] = train_val_split(data_x_valid, data_y_valid, ...
%                                                    'category', 'val_categories', {'LP_ON'} , 'category_array', data_category);

[best_mdl, best_var_num, score_idx, scores] = MRMR_based_models(train_x, train_y, val_x, val_y, num_max_vr, rg_model);
save_model_performance(best_mdl, best_var_num, score_idx, scores, train_x, train_y, val_x, val_y, vr_selection, rg_model, output_label, write_data, results_file_path);


