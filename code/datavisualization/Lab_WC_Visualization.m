clc
clear
close all

% file paths
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';

% Define parameters
lab_exptype = 'WC';  

data = access_all_lab_data(mainpath, lab_exptype, WC_gt_subpath);

fre = calculate_frequencies_Hz();

fontsize = 13;

% Define a set of colors to cycle through
colors = [
    0.0000 0.4470 0.7410;  % Blue
    0.8500 0.3250 0.0980;  % Red
    0.9290 0.6940 0.1250;  % Yellow
    0.4940 0.1840 0.5560;  % Purple
    0.4660 0.6740 0.1880;  % Green
    0.3010 0.7450 0.9330;  % Light Blue
    0.6350 0.0780 0.1840;  % Dark Red
    0.0000 0.0000 0.0000;  % Black
    1.0000 0.5490 0.0000;  % Orange
    0.2500 0.8784 0.8157;  % Turquoise
    0.5410 0.1686 0.8863;  % Medium Purple
    0.0000 0.5020 0.0000;  % Dark Green
    0.9412 0.5020 0.5020;  % Rosy Brown
    0.6784 1.0000 0.1843;  % Lime Green
    1.0000 0.8431 0.0000;  % Gold
    0.8039 0.3608 0.3608;  % Light Red
];

% Magnitude
for i = 1:length(data)
    figure,
    
    set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]

    % Create a semilogx plot with different colors for each line
    hold on;
    for j = 1:length(data(i).gt.WC_Prepared)
        semilogx(fre, data(i).mag(j, :), 'LineWidth', 2, 'Color', colors(j, :));
    end
    hold off;
    
    % Title with fontsize
    title([data(i).expnum '-' data(i).cabletype '-' 'Magnitude'], 'FontSize', fontsize);
    
    % Create the legend with formatted values and title
    legend_values = arrayfun(@(x) sprintf('%.3f', x), data(i).gt.WC_Prepared, 'UniformOutput', false);
    lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
    title(lgd, 'VWC');  % Add title to the legend
    
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
    figure,
    
    set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]

    % Create a semilogx plot with different colors for each line
    hold on;
    for j = 1:length(data(i).gt.WC_Prepared)
        semilogx(fre, data(i).phs(j, :), 'LineWidth', 2, 'Color', colors(j, :));
    end
    hold off;
    
    % Title with fontsize
    title([data(i).expnum '-' data(i).cabletype '-' 'Phase'], 'FontSize', fontsize);
    
    % Create the legend with formatted values and title
    legend_values = arrayfun(@(x) sprintf('%.3f', x), data(i).gt.WC_Prepared, 'UniformOutput', false);
    lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
    title(lgd, 'VWC');  % Add title to the legend
    
    % Axis labels with custom font size
    xlabel('frequency (Hz)', 'FontSize', fontsize);
    ylabel('Absolute Phase Difference (degrees)', 'Fontsize', fontsize);
    
    % Set tick label sizes (both X and Y axes)
    ax = gca;  % Get the current axis
    ax.XAxis.FontSize = fontsize;  % Set X-axis tick label size
    ax.YAxis.FontSize = fontsize;  % Set Y-axis tick label size
    set(gca,'XScale','log')  % Ensure X-axis is logarithmic
end