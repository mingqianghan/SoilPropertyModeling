function Idx = spa_classic(X, k, M)
% -------------------------------------------------------------------------
% Classic Successive Projections Algorithm (SPA)
% 
% This algorithm selects a subset of M variables from a dataset through
% successive projections, ensuring that the selected variables are as 
% uncorrelated as possible. It aims to maximize the variance and 
% representation of the original data.
%
% The selection starts with a specific variable (indexed by k) and proceeds
% by iteratively projecting the remaining variables onto the orthogonal 
% subspace of the already selected variables.
%
% Inputs:
%   X --> Data matrix (N x K), where:
%         - N is the number of observations (rows)
%         - K is the number of predictor variables (columns)
%   k --> Index of the first variable to select for the projection.
%   M --> Number of variables to select in total.
%
% Outputs:
%   Idx --> A set of indices of the selected variables, representing the 
%           most informative variables based on successive projections.
%
% Author: Mingqiang Han
% Date: 10-14-24
% -------------------------------------------------------------------------

% Get the size of the input matrix X. 
% N represents the number of observations (rows), K represents the number 
% of predictor variables (columns).
[N, K] = size(X);

% Initialize the index set that will store the M selected variable indices.
% We start by preallocating space and selecting the first variable, k.
Idx = zeros(1, M);
Idx(1) = k;

% Select the initial variable by its index k and form a new matrix 
% that will store the selected columns.
X_selected = X(:, k);  % This initializes with the first selected column

% Iteratively select the remaining M-1 variables
for i = 2:M
    % Project the remaining variables onto the orthogonal subspace of X_selected.
    % P is the projection matrix that ensures orthogonality with the already 
    % selected variables.
    
    % Calculate the projection operator for orthogonality
    P = eye(N) - (X_selected / (X_selected' * X_selected)) * X_selected';
    
    % Apply the projection to all variables in X (this excludes already selected ones).
    X_projected = P * X;

    % Compute the norms of the projected columns, which will help identify
    % the variable that contributes the most new information to the selected set.
    norms = sum(X_projected.^2);
    
    % Exclude the already selected variables by setting their norms to zero, so
    % they won't be chosen again.
    norms(Idx(1:i-1)) = 0;

    % Find the variable with the largest norm in the projected space.
    % This variable is most orthogonal to the already selected set.
    [~, new_selection] = max(norms);

    % Add the new variable to the selected index set
    Idx(i) = new_selection;

    % Update X_selected by appending the newly selected variable's column.
    X_selected = [X_selected, X(:, new_selection)];
end
end
