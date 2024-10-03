clc;
clear;
close all;

mainpath = 'data';
gt_subpath = 'Lab\LC_Angle.xlsx';
lab_exptype = 'WC_Bending';
lab_expnum = 'R1';
lab_expcbtype = 'LC';

[data, gt, num_samples] = load_lab_data(mainpath, lab_exptype, ...
                          lab_expnum, lab_expcbtype, gt_subpath);



fre = calculate_frequencies_Hz();

fontsize = 13;
colors = {'r', 'g', 'k', 'b'};
linetype = {'-', '-.', '--'};


figure,
set(gcf, 'Position', [100, 100, 850, 600]);
hold on
for i = 1:length(linetype)
    for j = 1:length(colors)
        semilogx(fre, data.mag(4*i+j-4,:), 'LineStyle', linetype{i}, ...
                 'LineWidth', 2, 'Color', colors{j});
    end
end
hold off
% Title
title('Magnitude', 'FontSize', fontsize);
legend();
ax = gca;
ax.XAxis.FontSize = fontsize;
ax.YAxis.FontSize = fontsize;
set(gca, 'XScale', 'log');

legend_values = arrayfun(@(vwc, bd) ...
                sprintf('W:%.2f B%d', vwc, bd), ...
                gt.WC_Prepared, gt.Bending, 'UniformOutput', false);
lgd = legend(legend_values, 'Location', 'eastoutside', ...
                     'FontSize', fontsize);
title(lgd, 'VWC & Bending'); 


figure,
set(gcf, 'Position', [100, 100, 850, 600]);
hold on
for i = 1:length(linetype)
    for j = 1:length(colors)
        semilogx(fre, data.phs(4*i+j-4,:), 'LineStyle', linetype{i}, ...
                 'LineWidth', 2, 'Color', colors{j});
    end
end
hold off
% Title
title('Phase', 'FontSize', fontsize);
legend();
ax = gca;
ax.XAxis.FontSize = fontsize;
ax.YAxis.FontSize = fontsize;
set(gca, 'XScale', 'log');

legend_values = arrayfun(@(vwc, bd) ...
                sprintf('W:%.2f B%d', vwc, bd), ...
                gt.WC_Prepared, gt.Bending, 'UniformOutput', false);
lgd = legend(legend_values, 'Location', 'eastoutside', ...
                     'FontSize', fontsize);
title(lgd, 'VWC & Bending'); 