clc
clear
close all

% file paths
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

% Define parameters
lab_exptype = 'WC';  

data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

fre = calculate_frequencies_Hz();

cur_expnum = {'R1', 'R2', "R3"};
cur_cabletype = {'SC', 'LC'};

for i = 1:length(cur_expnum)
    val_idx = strcmp({data.expnum}, cur_expnum{i});
    val_data_split = data(val_idx);
    train_data_split = data(~val_idx);
    for j = 1:length(cur_cabletype)
        val_data = val_data_split(strcmp({val_data_split.cabletype}, cur_cabletype{j}));
        train_data = train_data_split(strcmp({train_data_split.cabletype}, cur_cabletype{j}));

        val_x = vertcat(val_data.mag);
        train_x = vertcat(train_data.mag);

        % Use arrayfun to extract WC_Calculated and concatenate
        val_y = arrayfun(@(x) x.gt.WC_Prepared, val_data, 'UniformOutput', false);
        % Convert the cell array into a matrix by concatenating the 16x1 arrays
        val_y = vertcat(val_y{:});

        % Use arrayfun to extract WC_Calculated and concatenate
        train_y = arrayfun(@(x) x.gt.WC_Prepared, train_data, 'UniformOutput', false);
        % Convert the cell array into a matrix by concatenating the 16x1 arrays
        train_y = vertcat(train_y{:});

        [idx, scores]= fsrmrmr(train_x,train_y);
        [~, sortedIndices] = sort(scores, 'descend'); 

        best_r_square = inf;
        best_rmse = inf;
        best_mae = inf;
        best_var_num = inf;
        for k = 1:10
            fea_indices = sortedIndices(1:k);
            mdl = fitlm(train_x(:,fea_indices), train_y);

            yPred_val = predict(mdl, val_x(:,fea_indices));
            [r_square, rmse, mae] = model_evaluation(yPred_val, val_y);
            if r_square < best_r_square
                best_r_square = r_square;
                best_rmse = rmse;
                best_mae = mae;
                best_var_num = k;
            end
        end
        fprintf('Val_Set(%s) Cable type(%s) ', cur_expnum{i}, cur_cabletype{j});
        fprintf('Varnum: %2d, rsquare: %.2f, rmse: %.2f, mae: %.2f\n', best_var_num, best_r_square, best_rmse, best_mae);

    end
end

