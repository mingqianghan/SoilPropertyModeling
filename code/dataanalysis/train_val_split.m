function [train_x, train_y, val_x, val_y, train_categories, val_categories] = train_val_split(data_x, data_y, split_method, varargin)
% -------------------------------------------------------------------------
% train_val_split: Function to split the data into training and validation sets.
%
% Inputs:
%   - data_x: Input features (n_samples x n_features).
%   - data_y: Output labels (n_samples x 1).
%   - split_method: Method to split the data. Options:
%     - 'category': Split by categories in data_y.
%     - 'ratio': Split by a specific ratio.
%   - varargin: Optional parameters, provided as parameter/value pairs:
%     - 'train_ratio': Ratio of training data (default is 0.7).
%     - 'val_categories': Categories for validation set (only used in 'category' mode).
%     - 'category_array': Array of the same length as data_y representing the category of each data point.
%     - 'seed': Random seed for reproducibility (default is 42).
%
% Outputs:
%   - train_x, train_y: Training features and labels.
%   - val_x, val_y: Validation features and labels.
%   - train_categories, val_categories: Category labels for training and validation sets.
% -------------------------------------------------------------------------

% Parse optional input arguments
p = inputParser;
addParameter(p, 'train_ratio', 0.7, @isnumeric);    % Default train/val split ratio is 0.7
addParameter(p, 'val_categories', [], @(x) isvector(x) || isempty(x));  % Validation categories for category-based split
addParameter(p, 'category_array', [], @(x) isvector(x) && numel(x) == numel(data_y));  % Category array for data points
addParameter(p, 'seed', 42, @isnumeric);            % Default seed for reproducibility

parse(p, varargin{:});
train_ratio = p.Results.train_ratio;
val_categories = p.Results.val_categories;
category_array = p.Results.category_array;
seed = p.Results.seed;

% Perform split based on the method
switch split_method
    case 'category'
        if isempty(val_categories)
            error('For category split, "val_categories" must be provided.');
        end
        if isempty(category_array)
            error('For category split, "category_array" must be provided.');
        end
        % Call the category-based splitting function
        [train_x, train_y, val_x, val_y, train_categories, val_categories] = splitbycategories(data_x, data_y, val_categories, category_array);
        
    case 'ratio'
        % Call the ratio-based splitting function
        [train_x, train_y, val_x, val_y] = splitbyratio(data_x, data_y, train_ratio, seed);
        train_categories = [];  % No categories in ratio-based split
        val_categories = [];
        
    otherwise
        error('Invalid split method. Choose "category" or "ratio".');
end

    % Nested function to split data by ratio
    function [train_x, train_y, val_x, val_y] = splitbyratio(data_x, data_y, train_ratio, seed)
        rng(seed);  % Set the random seed for reproducibility
        num_samples = size(data_x, 1);
        num_train_samples = round(train_ratio * num_samples);
        rand_indices = randperm(num_samples);  % Shuffle the indices
        train_indices = rand_indices(1:num_train_samples);
        val_indices = rand_indices(num_train_samples + 1:end);
        train_x = data_x(train_indices, :);
        train_y = data_y(train_indices, :);
        val_x = data_x(val_indices, :);
        val_y = data_y(val_indices, :);
    end

    % Nested function to split data by categories with a category array
    function [train_x, train_y, val_x, val_y, train_categories, val_categories] = splitbycategories(data_x, data_y, val_categories, category_array)
        % Create logical indexing for validation set based on val_categories
        is_val = ismember(category_array, val_categories);  % Logical array for validation set
        val_x = data_x(is_val, :);
        val_y = data_y(is_val, :);
        val_categories = category_array(is_val);  % Get the categories for the validation set
        
        % Get training set based on the remaining data
        train_x = data_x(~is_val, :);
        train_y = data_y(~is_val, :);
        train_categories = category_array(~is_val);  % Get the categories for the training set
    end

% Summary of the split
fprintf('Total: %d, Training: %d, Validation: %d\n', ...
    size(data_x, 1), size(train_x, 1), size(val_x, 1));
end
