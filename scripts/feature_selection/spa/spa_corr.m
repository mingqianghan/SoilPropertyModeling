function Idx = spa_corr(X, y, M)
% -------------------------------------------------------------------------
% This function selects variables using the Successive Projections 
% Algorithm (SPA). The first variable is selected based on the highest 
% absolute correlation with  the response variable.
% 
% Inputs:
%   X  - The matrix of independent variables (predictors), 
%        where each column represents a variable.
%   y  - The response variable (dependent variable) vector.
%   M  - The number of variables to select.
%
% Outputs:
%   Idx - The indices of the selected variables.
%
% Author: Mingqiang Han
% Date  : 10-14-2024
% -------------------------------------------------------------------------

% Normalize the variables and the response
X_centered = X - mean(X);    % Center each predictor variable
y_centered = y - mean(y);    % Center the response variable

% 
% Compute the Pearson correlation between each predictor and the response
%
% Element-wise product and sum for each variable
numerator = sum(X_centered .* y_centered, 1); 
% Norms for correlation calculation
denominator = sqrt(sum(X_centered .^ 2, 1)) * norm(y_centered); 
% Pearson correlation coefficients for each predictor
correlations = numerator ./ denominator;  

% Identify the variable with the highest absolute correlation with 
% the response
[~, first_variable_idx] = max(abs(correlations)); 

% Select M variables using the QR-based SPA method
Idx = spa_qr(X, first_variable_idx, M);

% Idx = spa_classic(X, first_variable_idx, M);

end

