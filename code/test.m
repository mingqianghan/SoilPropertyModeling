clc;
clear;
close all;

% File paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

% Define parameters
lab_exptype = 'WC';  

% Access lab data
data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

% Experiment and cable types
cur_expnum = {'R1', 'R2', 'R3'};
cur_cabletype = {'SC', 'LC'};
Predictors = 'MaP'; %Phs, MaP

num_max_vr = 20;
rg_model = 'LR'; %LR, SVM
vr_selection = 'MRMR';

existing_models = readtable('results\lab\wc\existing_model.csv', 'ReadVariableNames', true, 'Delimiter', ',', 'TreatAsEmpty', '_', 'TextType', 'string');
model_name = strcat(vr_selection, '_', rg_model);

if ismember(model_name, existing_models{:, 1})
    write_data = false;
else
    write_data = true;
    writematrix(model_name,'results\lab\wc\existing_model.csv', ...
               'WriteMode', 'append');
end

fprintf('\nVS Method: %s, Regrssion model: %s\n', vr_selection, rg_model)
% Loop through experimental setups and cable types
for i = 1:length(cur_expnum)
    % Split validation and training data based on experiment number
    val_idx = strcmp({data.expnum}, cur_expnum{i});
    val_data_split = data(val_idx);
    train_data_split = data(~val_idx);
    
    for j = 1:length(cur_cabletype)
        % Further split based on cable type
        val_data = val_data_split(strcmp({val_data_split.cabletype}, cur_cabletype{j}));
        train_data = train_data_split(strcmp({train_data_split.cabletype}, cur_cabletype{j}));
        

        output_label = strcat(Predictors, '_', cur_cabletype{j}, '_', ...
                              cur_expnum{i});

        [train_x, train_y, val_x, val_y] =  Prepare_lab_data(train_data, ...
                                                            val_data, ...
                                                            Predictors, ...
                                                            'WC_Prepared');

        [best_mdl, best_var_num, score_idx, scores]= MRMR_based_models(...
                                                      train_x, train_y, ...
                                                      val_x, val_y, ...
                                                      num_max_vr, rg_model);
        fprintf('Cable_Type(%s), Val_Set(%s), Var_Num(%d): \n', cur_cabletype{j}, cur_expnum{i}, best_var_num);

        save_model_performance(best_mdl, best_var_num, score_idx, scores, ...
                               train_x, train_y, val_x, val_y, ...
                               vr_selection, rg_model, output_label, write_data)
    end  
end
