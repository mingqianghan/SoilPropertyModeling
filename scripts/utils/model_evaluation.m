function scores = model_evaluation(ypred, ytrue)
% -------------------------------------------------------------------------
% This function calculates evaluation metrics for a regression model.
% It computes the R-squared (coefficient of determination), 
% RMSE (Root Mean Squared Error), and MAE (Mean Absolute Error) 
% based on the true and predicted values.
% 
% Inputs:
%   ypred - Predicted values from the model (numeric vector)
%   ytrue - True values from the dataset (numeric vector)
%
% Outputs:
%   scores - Struct containing:
%            r_square - The R-squared value, which indicates the proportion 
%                       of the variance in the dependent variable that is 
%                       predictable from the independent variables.
%            rmse     - Root Mean Squared Error, which measures the 
%                       standard deviation of the prediction errors.
%            mae      - Mean Absolute Error, which measures the average 
%                       of the absolute differences between predicted and 
%                       true values.
%
% Author: Mingqiang Han
% Date: 09-12-24
% -------------------------------------------------------------------------

% Ensure inputs are numeric vectors
if ~isnumeric(ypred) || ~isnumeric(ytrue)
    error('Inputs ypred and ytrue must be numeric vectors.');
end

if length(ypred) ~= length(ytrue)
    error('Inputs ypred and ytrue must have the same length.');
end

% Calculate residuals (difference between true and predicted values)
residuals = ytrue - ypred;

% Calculate R-squared (coefficient of determination)
% Sum of squares of residuals (SS_res) - 
% Represents the difference between the true and predicted values
ss_res = sum(residuals .^ 2); 

% Total sum of squares (SS_tot) - 
% Represents the total variance in the true values
ss_tot = sum((ytrue - mean(ytrue)) .^ 2); 

% R-squared formula: 1 - (SS_res / SS_tot)
% Indicates the proportion of variance explained by the model
r_square = 1 - (ss_res / ss_tot);

% Calculate RMSE (Root Mean Squared Error)
% RMSE is the square root of the mean of the squared residuals
rmse = sqrt(mean(residuals .^ 2));

% Calculate MAE (Mean Absolute Error)
% MAE is the mean of the absolute differences between the predicted and true values
mae = mean(abs(residuals));

% Store results in a struct for output
scores.rsquare = r_square;
scores.rmse = rmse;
scores.mae = mae;
end