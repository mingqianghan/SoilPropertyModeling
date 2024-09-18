function [best_mdl, best_var_num, score_idx, scores]= MRMR_based_models(...
                                                      train_x, train_y, ...
                                                      val_x, val_y, ...
                                                      num_max_vr, rg_model)
% Feature selection using MRMR
[score_idx, scores] = fsrmrmr(train_x, train_y);

% Train the model using the selected features
best_r_square = -inf;

for k = 1:num_max_vr
    fea_indices = score_idx(1:k);

    if strcmp(rg_model, 'LR')
        mdl = fitlm(train_x(:, fea_indices), train_y);
    else

    end
    
    % Validate the model
    yPred_val = predict(mdl, val_x(:, fea_indices));
    [r_square, ~, ~] = model_evaluation(yPred_val, val_y);
            
    % Track the best model
    if r_square > best_r_square
        best_r_square = r_square;
        best_var_num = k;
        best_mdl = mdl;
    end
end

end