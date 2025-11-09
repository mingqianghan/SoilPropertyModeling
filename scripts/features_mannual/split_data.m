function [train_x, train_y, train_label, ...
          val_x, val_y, val_label, ...
          test_x, test_y, test_label] = split_data(data_x, data_y, train_ratio, test_ratio, label, showfigure)

rng(1);

 if nargin < 5
     showfigure = false;
 end

% Parameters
num_bins = 4;
% disp(min(data_y))
% disp(max(data_y))

% Outlier detection using the IQR method (is this method good?)
Q1 = prctile(data_y, 25);
Q3 = prctile(data_y, 75);
IQR = Q3 - Q1;
lower_bound = Q1 - 1.5 * IQR;
upper_bound = 100; %Q3 + 1.5 * IQR; %(VWC) 100 (NO3) 65(NH4);

% Select inliers (remove outliers)
inliers = (data_y >= lower_bound) & (data_y <= upper_bound);
inlier_x = data_x(inliers, :);
inlier_y = data_y(inliers, :);
inlier_label = label(inliers, :);

% disp(min(inlier_y))
% disp(max(inlier_y))

% Stratify using discretization of target values
[binIdx, edges] = discretize(inlier_y, num_bins);

% Initialize index arrays for splits
train_indices = [];
val_indices = [];
test_indices = [];

% Process each bin separately
for i = 1:num_bins
    % Get indices for the current bin and shuffle them
    bin_samples = find(binIdx == i);
    bin_samples = bin_samples(randperm(numel(bin_samples)));

    if test_ratio == 0
        % split into two sets
        % When test_ratio is 0, assign remaining samples after training to validation.
        n_train = round(train_ratio * numel(bin_samples));
        train_indices = [train_indices; bin_samples(1:n_train)];
        val_indices = [val_indices; bin_samples(n_train+1:end)];
    else
        % split into three sets
        % Otherwise, split into training, validation, and test sets.
        n_train = round(train_ratio * numel(bin_samples));
        n_val = round(test_ratio * numel(bin_samples));
        train_indices = [train_indices; bin_samples(1:n_train)];
        val_indices = [val_indices; bin_samples(n_train+1:n_train+n_val)];
        test_indices = [test_indices; bin_samples(n_train+n_val+1:end)];
    end
end

% Build output splits from the inlier data
train_x = inlier_x(train_indices, :);
train_y = inlier_y(train_indices, :);
train_label = inlier_label(train_indices, :);
val_x   = inlier_x(val_indices, :);
val_y   = inlier_y(val_indices, :);
val_label = inlier_label(val_indices, :);

if test_ratio == 0
    test_x = [];
    test_y = [];
    test_label = [];
else
    test_x = inlier_x(test_indices, :);
    test_y = inlier_y(test_indices, :);
    test_label = inlier_label(test_indices, :);
end

% Plot distributions if requested
if showfigure
    if test_ratio == 0
        figure;
        subplot(1,2,1);
        histogram(train_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
        title('Training Set');
        xlabel('Target'); ylabel('Frequency');

        subplot(1,2,2);
        histogram(val_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
        title('Validation Set');
        xlabel('Target'); ylabel('Frequency');
    else
        figure;
        subplot(1,3,1);
        histogram(train_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
        title('Training Set');
        xlabel('Target'); ylabel('Frequency');

        subplot(1,3,2);
        histogram(val_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
        title('Validation Set');
        xlabel('Target'); ylabel('Frequency');

        subplot(1,3,3);
        histogram(test_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
        title('Test Set');
        xlabel('Target'); ylabel('Frequency');
    end
end
end
