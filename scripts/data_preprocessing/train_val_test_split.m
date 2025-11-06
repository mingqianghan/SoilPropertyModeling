function [train_x, train_y, val_x, val_y, test_x, test_y] = train_val_test_split(data_x, data_y, train_ratio, val_ratio)

num_bins =  4;
showfigure =  true;
seed = 333;

[train_x, train_y, val_x, val_y, test_x, test_y] = splitbyratio(data_x, data_y, train_ratio, val_ratio, num_bins, showfigure, seed);

    % Nested function to split data by ratio
    function [train_x, train_y, val_x, val_y, test_x, test_y] = splitbyratio(data_x, data_y, train_ratio, val_ratio, num_bins, showfigure, seed)
        rng(seed);  % Set the random seed for reproducibility

        % Detect outliers using the IQR method
        Q1 = prctile(data_y, 25);  % 25th percentile
        Q3 = prctile(data_y, 75);  % 75th percentile
        IQR = Q3 - Q1;             % Interquartile range

        % Define outlier boundaries
        lower_bound = Q1 - 1.5 * IQR;
        upper_bound = Q3 + 1.5 * IQR;

        % Identify outliers
        outlier_indices = (data_y < lower_bound) | (data_y > upper_bound);
        inlier_indices = ~outlier_indices;

        % Separate inliers and outliers
        inlier_x = data_x(inlier_indices, :);
        inlier_y = data_y(inlier_indices, :);
        % outliers_x = data_x(outlier_indices, :);
        % outliers_y = data_y(outlier_indices, :);

        
        [binIdx, edges] = discretize(inlier_y, num_bins);  % Determine bin edges and counts

        % Initialize indices
        train_indices = [];
        val_indices = [];
        test_indices = [];

        % Stratify by each bin
        for i = 1:num_bins
            % Get indices for samples in the current bin
            bin_samples = find(binIdx == i);

            % Shuffle indices within the bin
            bin_samples = bin_samples(randperm(numel(bin_samples)));

            % Determine number of training samples for the current bin
            num_train_bin = round(train_ratio * numel(bin_samples));
            num_val_bin = round(val_ratio * numel(bin_samples));

            % Assign to training and validation indices
            train_indices = [train_indices; bin_samples(1:num_train_bin)];
            val_indices = [val_indices; bin_samples(num_train_bin+1:num_train_bin+num_val_bin)];
            test_indices = [test_indices; bin_samples(num_train_bin+num_val_bin + 1:end)];
        end
        % train_indices
        % val_indices
        % test_indices

        train_x = inlier_x(train_indices, :);
        train_y = inlier_y(train_indices, :);
        val_x = inlier_x(val_indices, :);
        val_y = inlier_y(val_indices, :);
        test_x = inlier_x(test_indices, :);
        test_y = inlier_y(test_indices, :);

        if showfigure
            figure;
            subplot(1, 3, 1);
            histogram(train_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
            title('Training Set Target Distribution');
            xlabel('Target Value');
            ylabel('Frequency');

            subplot(1, 3, 2);
            histogram(val_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
            title('Validation Set Target Distribution');
            xlabel('Target Value');
            ylabel('Frequency');

            subplot(1, 3, 3);
            histogram(test_y, 'BinEdges', edges, 'DisplayStyle', 'bar');
            title('Test Set Target Distribution');
            xlabel('Target Value');
            ylabel('Frequency');
 
        end
    end
end
