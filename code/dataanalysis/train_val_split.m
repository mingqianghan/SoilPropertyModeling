function [train_x, train_y, val_x, val_y] = train_val_split( ...
                                            data_x, data_y, ...
                                            train_ratio, ...
                                            seed)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------

% Set default values for parameters
if nargin < 4  % If the third argument is not provided
    seed = 42;    % Default value for 'c'
end
if nargin < 3  % If the second argument is not provided
    train_ratio = 0.7;     % Default value for 'b'
end

% Set the random seed for reproducibility
rng(seed);

num_samples = size(data_x, 1);

% Determine the number of training samples
num_train_samples = round(train_ratio * num_samples);
% Create a random permutation of the indices for shuffling the data
rand_indices = randperm(num_samples);

% Split the indices into training and validation sets
train_indices = rand_indices(1:num_train_samples);
val_indices = rand_indices(num_train_samples + 1:end);

train_x = data_x(train_indices, :);
train_y = data_y(train_indices, :);

val_x = data_x(val_indices, :);
val_y = data_y(val_indices, :);

fprintf('Valid:%d, Training:%d, Val:%d\n', ...
          num_samples, size(train_x, 1), size(val_x, 1));
end
