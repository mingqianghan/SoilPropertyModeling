function Idx = spa_qr(X, k, M)
% -------------------------------------------------------------------------
% This function implements a variable selection method using QR 
% decomposition with column pivoting. It follows the general approach 
% of the Successive Projections Algorithm (SPA).
%
% Reference:
% Original inspiration from: https://github.com/FuSiry/Wavelength-selection
%
% Inputs:
%   X --> Data matrix of size N x K, where N is the number of observations,
%         and K is the number of predictor variables.
%   k --> Index of the first variable to prioritize in the projection step.
%   M --> Number of variables to select.
%
% Output:
%   Idx --> A set of indices of the selected variables
%
% Author: Mingqiang Han
% Date: 10-14-24
% -------------------------------------------------------------------------

% Create a copy of the original matrix
X_projected = X;

% Calculate the squared norms of each column. This helps in assessing
% the contribution of each variable.
norms = sum(X_projected.^2);

% Find the maximum norm value to rescale the kth column. Rescaling
% ensures that the kth variable has a higher weight in the projection 
% process, prioritizing it.
norm_max = max(norms);
X_projected(:, k) = X_projected(:, k) * 2 * norm_max / norms(k);

% Use QR decomposition with column pivoting. The QR factorization
% reorders the variables by their importance in representing the dataset.
% Column pivoting selects the most influential variables first.
[~, ~, order] = qr(X_projected, "econ", "vector");

% Extract the top M variables based on their importance.
Idx = order(1:M); 
end
