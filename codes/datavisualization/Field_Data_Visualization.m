clc
clear
close all

year = '24';
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data\UG nodes';
all_data = access_all_field_data(year, mainpath);
fre = calculate_frequencies_Hz();

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

fontsize = 13;

for i = 1:length(all_data)
    current_sample_num = all_data(i).Numsamples;
    if current_sample_num > 0
        % Define plot indices for large sample sets
        if current_sample_num <= 10
            plot_idx = 1:current_sample_num;
        else
            randomidx = randperm(current_sample_num-5, 5);
            plot_idx = [randomidx current_sample_num-4:current_sample_num];
        end

        % Create legend values
        legend_values = arrayfun(@(VWC, NO3, NH4) sprintf('%2.1f - %2.1f - %2.1f', VWC, NO3, NH4), ...
                                all_data(i).gt.VWC(plot_idx)*100, all_data(i).gt.NO3(plot_idx), all_data(i).gt.NH4(plot_idx), ...
                                 'UniformOutput', false);

        % Plot magnitude
        plot_data(fre, all_data(i).data.mag, plot_idx, ...
                  [all_data(i).Plotname '-' all_data(i).Ntype '-' all_data(i).Cabletype '-' 'Magnitude'], ...
                  legend_values, ' V_{probe}/V_{total} (dB)', fontsize, colors);

        % Plot phase
        plot_data(fre, all_data(i).data.phs, plot_idx, ...
                  [all_data(i).Plotname '-' all_data(i).Ntype '-' all_data(i).Cabletype '-' 'Phase'], ...
                  legend_values, 'Absolute Phase Difference (degrees)', fontsize, colors);
    end
end


% Create a reusable function for plotting
function plot_data(frequencies, data, plot_idx, title_str, legend_values, ylabel_str, fontsize, colors)
    figure;
    set(gcf, 'Position', [100, 100, 850, 600]);  % Adjust size [left, bottom, width, height]
    hold on;
    for j = 1:length(plot_idx)
        semilogx(frequencies, data(plot_idx(j),:), 'LineWidth', 2, 'Color', colors(j, :));
    end
    title(title_str, 'FontSize', fontsize);
    lgd = legend(legend_values, 'Location', 'eastoutside', 'FontSize', fontsize);
    title(lgd, {'VWC - NO3 - NH4', '   %   - ppm - ppm'});
    xlabel('frequency (Hz)', 'FontSize', fontsize);
    ylabel(ylabel_str, 'FontSize', fontsize);
    ax = gca;  
    ax.XAxis.FontSize = fontsize; 
    ax.YAxis.FontSize = fontsize;  
    set(gca,'XScale','log')  % Ensure X-axis is logarithmic
    hold off;
end
