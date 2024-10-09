function [score_idx, scores] = ...
         feature_selection(train_x, train_y, fs_param)
% -------------------------------------------------------------------------
% Feature selection based on the method specified in fs_param.
%
% Input:
%   - train_x: The matrix of predictor variables (features).
%   - train_y: The response variable (target).
%   - fs_param: A struct containing the feature selection method 
%     ('MRMR' or 'PLS_VIP') and parameters (such as number of components 
%     for PLS).
%
% Output:
%   - score_idx: Indices of features sorted by their importance.
%   - scores: Feature importance scores corresponding to the indices.
%
% Author: Mingqiang Han
% Date: 10-07-24
% -------------------------------------------------------------------------

switch fs_param.name
    case 'MRMR'  % If the selected method is MRMR
        % Use the fsrmrmr function to perform MRMR feature selection
        [score_idx, scores] = fsrmrmr(train_x, train_y);
        
    case 'PLS_VIP'
        % Perform PLS regression using the number of components (ncomp)
        [XL, YL, XS, ~, ~, ~, ~, stats] = plsregress( ...
            train_x, train_y, fs_param.ncomp);
        
        % Calculate normalized PLS weights
        W0 = bsxfun(@rdivide, stats.W, sqrt(sum(stats.W.^2, 1))); 
        
        % Calculate the product of the summed squares of 
        % XS (PLS components) and YL (response loadings)
        sumSq = sum(XS.^2, 1) .* sum(YL.^2, 1);  
        
        % Calculate VIP scores for the specified number of components 
        vipScores = sqrt(size(XL, 1) * sum( ...
            bsxfun(@times, sumSq, W0.^2), 2) ./ sum(sumSq, 2));
        
        % Sort VIP scores in descending order 
        % and get their corresponding feature indices
        [scores, score_idx] = sort(vipScores, 'descend');
end
