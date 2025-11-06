function yPred_test = model_predict_with_label(mdl, test_x, label_dummy)
% -------------------------------------------------------------------------
% This function predicts the response variable for a given set of test data
% using a specified model.
%
% Inputs:
%   - mdl: A structure that contains the model information,
%          including its type ('PLS' or other), the model coefficients,
%          and the selected feature indices.
%   - test_x: A matrix of test data where rows represent observations
%             and columns represent features.
%
% Outputs:
%   - yPred_test: A vector of predicted response values for the test data.
%
% Author: Mingqiang Han
% Date: 10-10-24
% -------------------------------------------------------------------------

% Check if the model type is 'PLS' (Partial Least Squares)
if strcmp(mdl.name, 'PLS')
    % For PLS models, add a column of ones to the test data for the intercept,
    % select only the relevant features (indexed by mdl.f_idx), and then
    % multiply by the model coefficients (BETA) to obtain the predictions.
    yPred_test = [ones(size(test_x, 1), 1), ...
        test_x(:, mdl.f_idx)] * mdl.mdl.BETA;
elseif strcmp(mdl.name, 'ANN_v2')
    test_x = test_x(:, mdl.f_idx);
    test_x_S =  mapminmax('apply', test_x', mdl.mdl.userdata.scaleSettings);
    yPred_test = mdl.mdl(test_x_S);
else
    % For non-PLS models, use the model's predict function to obtain predictions.
    % Only use the relevant features (indexed by mdl.f_idx) for prediction.
    yPred_test = predict(mdl.mdl, [test_x(:, mdl.f_idx), label_dummy]);
    yPred_test = yPred_test';
end

end