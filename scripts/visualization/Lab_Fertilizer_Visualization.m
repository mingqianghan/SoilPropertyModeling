clc;
clear;
close all;

exp1 = 'R3';   % R2
exp2 = 'R4';
mainpath = 'data';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

% Load data
data_N = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);

% Filter data based on conditions
matches1 = arrayfun(@(x) strcmp(x.Cabletype, 'LC') && strcmp(x.expnum, exp1), data_N);
filtered_data1 = data_N(matches1).gt;

matches2 = arrayfun(@(x) strcmp(x.Cabletype, 'LC') && strcmp(x.expnum, exp2), data_N);
filtered_data2 = data_N(matches2).gt;

data_vars = {'Urea', 'NO3', 'NH4', 'totN', 'O_NO3', 'O_NH4', 'O_totN'};

for i = 1:numel(data_vars)
    eval(sprintf('%s_1 = filtered_data1.%s;', data_vars{i}, data_vars{i}));
    eval(sprintf('%s_2 = filtered_data2.%s;', data_vars{i}, data_vars{i}));
end

% Step 1: Split into batches
for i = 1:numel(data_vars)
    % Get the total number of elements to process
    num_batches = 3; % _1 has 30 elements and _2 has 9, so 3 batches total

    for batch = 1:num_batches
        % Calculate indices for _1
        start_idx_1 = (batch - 1) * 10 + 1;
        end_idx_1 = batch * 10;
        
        % Calculate indices for _2
        start_idx_2 = (batch - 1) * 3 + 1;
        end_idx_2 = batch * 3;

        % Extract the subsets
        eval(sprintf('%s_1_batch = %s_1(%d:%d);', data_vars{i}, data_vars{i}, start_idx_1, end_idx_1));
        eval(sprintf('%s_2_batch = %s_2(%d:%d);', data_vars{i}, data_vars{i}, start_idx_2, end_idx_2));
        
        % Combine the subsets
        eval(sprintf('%s_combined_batch%d = [%s_1_batch; %s_2_batch];', ...
                     data_vars{i}, batch, data_vars{i}, data_vars{i}));
    end
end

% Step 2: Combine all batches back into one variable
for i = 1:numel(data_vars)
    % Initialize an empty array to store the final combined set
    eval(sprintf('%s = [];', data_vars{i}));
    
    % Loop through the three batches and concatenate them
    for batch = 1:3
        eval(sprintf('%s = [%s; %s_combined_batch%d];', ...
                     data_vars{i}, data_vars{i}, data_vars{i}, batch));
    end
end

% Define common properties
segments = {
    1:13, [0, 0, 0.6353], 'SM: 0.108 cm^3/cm^3';
    14:26, [0.3137, 0.6784, 0.6235], 'SM: 0.216 cm^3/cm^3';
    27:39, [0.7373, 0.1529, 0.1765], 'SM: 0.324 cm^3/cm^3'
};
face_color = [0.6216 0.6216 0.6216];
bar_width = 0.4;

% Plot settings
figure_titles = {'NO3-N (ppm)', 'NH4-N (ppm)', 'Total N (%)'};
data_old = {O_NO3, O_NH4, O_totN};
data_new = {NO3, NH4, totN};

for i = 1:3
    figure;
    hold on;
    bar(Urea(1:13), data_old{i}(1:13), 'FaceColor', face_color, 'EdgeColor', 'none', 'BarWidth', bar_width);
    for j = 1:size(segments, 1)
        idx = segments{j, 1};
        plot(Urea(idx), data_new{i}(idx), 'LineWidth', 1.5, 'Color', segments{j, 2});
    end
    hold off;
    xlabel('Urea applied (mg)');
    ylabel(figure_titles{i});
    legend('Before applying urea', segments{:, 3}, 'Location', 'best');
end

% Relative changes plots
data_titles = {'NO3-N relative changes (%)', 'NH4-N relative changes (%)', 'Total N relative changes (%)'};

for i = 1:3
    figure;
    hold on;
    handles = [];  % Initialize an array to store plot handles for legend
    for j = 1:size(segments, 1)
        idx = segments{j, 1};
        rel_change = (data_new{i}(idx) - data_old{i}(idx)) ./ data_old{i}(idx) * 100;
        h = plot(Urea(idx), rel_change, 'LineWidth', 1.5, 'Color', segments{j, 2});
        handles = [handles, h];  % Store handle for legend
    end
    yline(0, '--k', 'LineWidth', 1.5);
    hold off;
    xlabel('Urea applied (mg)');
    ylabel(data_titles{i});
    legend(handles, segments{:, 3}, 'Location', 'best');  % Only add legend for plots
end

