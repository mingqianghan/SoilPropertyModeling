clc
clear
close all

% file paths
mainpath = 'data';
N_gt_subpath = 'Lab\Nitrogen_Calibration_NH4NO3.xlsx';

% Define parameters
lab_exptype = 'NH4NO3';  
data = access_all_lab_data(mainpath, lab_exptype, N_gt_subpath);
fre = calculate_frequencies_Hz();

N_levels = 6;
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

% Precompute WC_idx for all datasets
for i = 1:length(data)
    data(i).WC_idx = [find(data(i).gt.WC == 0.108), ... 
                      find(data(i).gt.WC == 0.216), ...
                      find(data(i).gt.WC == 0.324)];
end

% Plot Magnitude and Phase using the new functions
create_plots(data, fre, WC_levels, N_levels, colors, fontsize, 'mag', ...
            ' V_{probe}/V_{total} (dB)');
create_combined_plots(data, fre,  WC_levels, N_levels, colors, ...
                      fontsize, 'mag', ' V_{probe}/V_{total} (dB)');

create_plots(data, fre,  WC_levels, N_levels, colors, fontsize, 'phs', ...
            'Absolute Phase Difference (degrees)');
create_combined_plots(data, fre,  WC_levels, N_levels, colors, ...
                      fontsize, 'phs', ...
                      'Absolute Phase Difference (degrees)');

% Function to create semilogx plots
function create_plots(data, fre, WC_levels, N_levels, colors, ...
                      fontsize, plot_type, ylabel_text)
    for i = 1:length(data)
        WC_idx = data(i).WC_idx;
        for k = 1:WC_levels
            figure('Position', [100, 100, 850, 600]);
            hold on;
            
            for j = 1:N_levels
                semilogx(fre, data(i).data.(plot_type)(WC_idx(j, k), :),...
                         'LineWidth', 2, 'Color', colors(j, :));
            end
            hold off;

            % Title and labels
            title([data(i).expnum '-' data(i).Cabletype '-VWC:' ...
                   num2str(data(i).gt.WC(WC_idx(1, k))) '-' plot_type], ...
                   'FontSize', fontsize);
            xlabel('frequency (Hz)', 'FontSize', fontsize);
            ylabel(ylabel_text, 'FontSize', fontsize);

            % Create legend
            legend_values = arrayfun(@(x) sprintf('%02d', x), ...
                            data(i).gt.NH4NO3(WC_idx(:, k)), ...
                            'UniformOutput', false);
            lgd = legend(legend_values, 'Location', 'eastoutside', ...
                         'FontSize', fontsize);
            title(lgd, 'NH4NO3 added (mg)');
            
            % Axis settings
            ax = gca;
            ax.XAxis.FontSize = fontsize;
            ax.YAxis.FontSize = fontsize;
            set(gca, 'XScale', 'log');
        end
    end
end

% Function to create combined plots
function create_combined_plots(data, fre, WC_levels, N_levels, ...
                               colors, fontsize, plot_type, ylabel_text)
    for i = 1:length(data)
        figure('Position', [100, 100, 850, 600]);
        hold on;
        
        for j = 1:WC_levels * N_levels
            if j <= 6
                semilogx(fre, data(i).data.(plot_type)(j, :), '-', ...
                         'LineWidth', 2, 'Color', ...
                         colors(mod(j-1, N_levels)+1, :));
            elseif j <= 12
                semilogx(fre, data(i).data.(plot_type)(j, :), '--', ...
                         'LineWidth', 2, 'Color', ...
                         colors(mod(j-1, N_levels)+1, :));
            else
                semilogx(fre, data(i).data.(plot_type)(j, :), '-.', ...
                         'LineWidth', 2, 'Color', ...
                         colors(mod(j-1, N_levels)+1, :));
            end
        end
        hold off;

        % Title and labels
        title([data(i).expnum '-' data(i).Cabletype '-' plot_type], ...
              'FontSize', fontsize);
        xlabel('frequency (Hz)', 'FontSize', fontsize);
        ylabel(ylabel_text, 'FontSize', fontsize);

        % Create legend
        legend_values = arrayfun(@(vwc, urea) ...
                        sprintf('W:%.2f N:%02d', vwc, urea), ...
                        data(i).gt.WC, data(i).gt.NH4NO3, ...
                        'UniformOutput', false);
        lgd = legend(legend_values, 'Location', 'eastoutside', ...
                     'FontSize', fontsize);
        title(lgd, 'VWC & N');

        % Axis settings
        ax = gca;
        ax.XAxis.FontSize = fontsize;
        ax.YAxis.FontSize = fontsize;
        set(gca, 'XScale', 'log');
    end
end
