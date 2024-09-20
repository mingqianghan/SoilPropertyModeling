clc
clear
close all

% file paths
mainpath = 'data';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

% Define parameters
lab_exptype = 'Nitrogen';  

data = access_all_lab_data(mainpath, lab_exptype, N_gt_subpath);

fre = calculate_frequencies_Hz();

N_levels = 10;
WC_levels = 3;

fontsize = 13;

% Define a set of colors to cycle through
colors = [
    1.0 0.0 0.0;    % Red
    0.0 0.0 1.0;    % Blue
    0.0 1.0 0.0;    % Green
    1.0 1.0 0.0;    % Yellow
    1.0 0.65 0.0;   % Orange
    0.5 0.0 0.5;    % Purple
    0.0 1.0 1.0;    % Cyan
    1.0 0.0 1.0;    % Magenta
    0.65 0.16 0.16; % Brown
    0.5 0.5 0.5;    % Gray
];


WC_idx = zeros(N_levels,WC_levels);

% Magnitude
for i = 1:length(data)
    
    WC_idx = [find(data(i).gt.WC == 0.108),... 
              find(data(i).gt.WC == 0.216),...
              find(data(i).gt.WC == 0.324)];
    for k = 1:WC_levels
        figure,
        set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]
        
        % Create a semilogx plot with different colors for each line
        hold on;
        for j = 1:N_levels
            semilogx(fre, data(i).mag(WC_idx(j,k), :), 'LineWidth', 2, 'Color', colors(j, :));
        end
        hold off;
    
        % Title with fontsize
        title([data(i).expnum '-' data(i).cabletype '-' 'VWC:' num2str(data(i).gt.WC(WC_idx(1,k))) '-' 'Magnitude'], ...
              'FontSize', fontsize);
    
        % Create the legend with formatted values and title
        legend_values = arrayfun(@(x) sprintf('%02d', x), data(i).gt.Urea(WC_idx(:,k)), 'UniformOutput', false);
        lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
        title(lgd, 'Urea added (mg)');  % Add title to the legend
    
        % Axis labels with custom font size
        xlabel('frequency (Hz)', 'FontSize', fontsize);
        ylabel(' V_{probe}/V_{total} (dB)', 'FontSize', fontsize);
    
        % Set tick label sizes (both X and Y axes)
        ax = gca;  % Get the current axis
        ax.XAxis.FontSize = fontsize;  % Set X-axis tick label size
        ax.YAxis.FontSize = fontsize;  % Set Y-axis tick label size
       set(gca,'XScale','log')  % Ensure X-axis is logarithmic
    end
    figure,
    
    set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]

    % Create a semilogx plot with different colors for each line
    hold on;
    for j = 1:WC_levels*N_levels
        if j<=10
            semilogx(fre, data(i).mag(j, :), '-', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        elseif j>10 && j<=20
            semilogx(fre, data(i).mag(j, :), '--', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        else
            semilogx(fre, data(i).mag(j, :), '-.', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        end
    end
    hold off;
    
    % Title with fontsize
    title([data(i).expnum '-' data(i).cabletype '-' 'Magnitude'], 'FontSize', fontsize);
    
    % Create the legend with formatted values and title
    legend_values = arrayfun(@(vwc, urea) sprintf('W:%.2f U:%02d', vwc, urea), ...
                               data(i).gt.WC, data(i).gt.Urea, 'UniformOutput', false);
    lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
    title(lgd, 'VWC & N');  % Add title to the legend
    
    % Axis labels with custom font size
    xlabel('frequency (Hz)', 'FontSize', fontsize);
    ylabel(' V_{probe}/V_{total} (dB)', 'FontSize', fontsize);
    
    % Set tick label sizes (both X and Y axes)
    ax = gca;  % Get the current axis
    ax.XAxis.FontSize = fontsize;  % Set X-axis tick label size
    ax.YAxis.FontSize = fontsize;  % Set Y-axis tick label size
    set(gca,'XScale','log')  % Ensure X-axis is logarithmic
end

% Phase
for i = 1:length(data)
    
    WC_idx = [find(data(i).gt.WC == 0.108),... 
              find(data(i).gt.WC == 0.216),...
              find(data(i).gt.WC == 0.324)];
    for k = 1:WC_levels
        figure,
        set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]
        
        % Create a semilogx plot with different colors for each line
        hold on;
        for j = 1:N_levels
            semilogx(fre, data(i).phs(WC_idx(j,k), :), 'LineWidth', 2, 'Color', colors(j, :));
        end
        hold off;
    
        % Title with fontsize
        title([data(i).expnum '-' data(i).cabletype '-' 'VWC:' num2str(data(i).gt.WC(WC_idx(1,k))) '-' 'Phase'], ...
              'FontSize', fontsize);
    
        % Create the legend with formatted values and title
        legend_values = arrayfun(@(x) sprintf('%02d', x), data(i).gt.Urea(WC_idx(:,k)), 'UniformOutput', false);
        lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
        title(lgd, 'Urea added (mg)');  % Add title to the legend
    
        % Axis labels with custom font size
        xlabel('frequency (Hz)', 'FontSize', fontsize);
        ylabel('Absolute Phase Difference (degrees)', 'Fontsize', fontsize);
    
        % Set tick label sizes (both X and Y axes)
        ax = gca;  % Get the current axis
        ax.XAxis.FontSize = fontsize;  % Set X-axis tick label size
        ax.YAxis.FontSize = fontsize;  % Set Y-axis tick label size
       set(gca,'XScale','log')  % Ensure X-axis is logarithmic
    end
    figure,
    
    set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]

    % Create a semilogx plot with different colors for each line
    hold on;
    for j = 1:WC_levels*N_levels
        if j<=10
            semilogx(fre, data(i).phs(j, :), '-', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        elseif j>10 && j<=20
            semilogx(fre, data(i).phs(j, :), '--', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        else
            semilogx(fre, data(i).phs(j, :), '-.', 'LineWidth', 2, 'Color', colors(mod(j-1,N_levels)+1, :));
        end
    end
    hold off;
    
    % Title with fontsize
    title([data(i).expnum '-' data(i).cabletype '-' 'Phase'], 'FontSize', fontsize);
    
    % Create the legend with formatted values and title
    legend_values = arrayfun(@(vwc, urea) sprintf('W:%.2f U:%02d', vwc, urea), ...
                               data(i).gt.WC, data(i).gt.Urea, 'UniformOutput', false);
    lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
    title(lgd, 'VWC & N');  % Add title to the legend
    
    % Axis labels with custom font size
    xlabel('frequency (Hz)', 'FontSize', fontsize);
    ylabel('Absolute Phase Difference (degrees)', 'Fontsize', fontsize);
    
    % Set tick label sizes (both X and Y axes)
    ax = gca;  % Get the current axis
    ax.XAxis.FontSize = fontsize;  % Set X-axis tick label size
    ax.YAxis.FontSize = fontsize;  % Set Y-axis tick label size
    set(gca,'XScale','log')  % Ensure X-axis is logarithmic
end