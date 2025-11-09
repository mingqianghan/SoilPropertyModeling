clc
clear
close all

% file paths
mainpath = 'data';
N_gt_subpath = 'Lab\Nitrogen_Calibration_NH4NO3_drawfigure.xlsx';

% Define parameters
lab_exptype = 'NH4NO3';  
data = access_all_lab_data(mainpath, lab_exptype, N_gt_subpath);
fre = calculate_frequencies_Hz();

opts.colors = [
    '#0000FF';
    '#00FF00';  
    '#FF00FF';    
];

opts.markers = {'o','^', 's'};
opts.width = 12;
opts.height = 13;
opts.fontType = 'Times New Roman';
opts.fontSize = 12;
opts.linewidth = 2;

% plot_data_1x2(data(1:2), fre, opts);
plot_data_2x1(data(1:2), fre, opts);


% figure('Position', [100, 100, 850, 600]);
% semilogx(fre, data(7).data.mag,'LineWidth', 2);
% 
% % Title and labels
% title('R4-SC-Mag', 'FontSize', 13);
% xlabel('frequency (Hz)', 'FontSize', 13);
% ylabel('V_{probe}/V_{total} (dB)', 'FontSize', 13);
% 
% % Create legend
% legend_values = arrayfun(@(vwc, urea) ...
%     sprintf('W:%.2f U:%02d', vwc, urea), ...
%     data(7).gt.WC, data(7).gt.Urea, ...
%     'UniformOutput', false);
% lgd = legend(legend_values, 'Location', 'eastoutside', ...
%     'FontSize', 13);
% title(lgd, 'VWC & N');
% 
% 
% figure('Position', [100, 100, 850, 600]);
% semilogx(fre, data(7).data.phs,'LineWidth', 2);
% 
% % Title and labels
% title('R4-SC-Phs', 'FontSize', 13);
% xlabel('frequency (Hz)', 'FontSize', 13);
% ylabel('V_{probe}/V_{total} (dB)', 'FontSize', 13);
% 
% % Create legend
% legend_values = arrayfun(@(vwc, urea) ...
%     sprintf('W:%.2f U:%02d', vwc, urea), ...
%     data(7).gt.WC, data(7).gt.Urea, ...
%     'UniformOutput', false);
% lgd = legend(legend_values, 'Location', 'eastoutside', ...
%     'FontSize', 13);
% title(lgd, 'VWC & N');
% 
% figure('Position', [100, 100, 850, 600]);
% semilogx(fre, data(8).data.mag,'LineWidth', 2);
% 
% % Title and labels
% title('R4-LC-Mag', 'FontSize', 13);
% xlabel('frequency (Hz)', 'FontSize', 13);
% ylabel('V_{probe}/V_{total} (dB)', 'FontSize', 13);
% 
% % Create legend
% legend_values = arrayfun(@(vwc, urea) ...
%     sprintf('W:%.2f U:%02d', vwc, urea), ...
%     data(8).gt.WC, data(8).gt.Urea, ...
%     'UniformOutput', false);
% lgd = legend(legend_values, 'Location', 'eastoutside', ...
%     'FontSize', 13);
% title(lgd, 'VWC & N');
% 
% 
% figure('Position', [100, 100, 850, 600]);
% semilogx(fre, data(8).data.phs,'LineWidth', 2);
% 
% % Title and labels
% title('R4-LC-Phs', 'FontSize', 13);
% xlabel('frequency (Hz)', 'FontSize', 13);
% ylabel('V_{probe}/V_{total} (dB)', 'FontSize', 13);
% 
% % Create legend
% legend_values = arrayfun(@(vwc, urea) ...
%     sprintf('W:%.2f U:%02d', vwc, urea), ...
%     data(8).gt.WC, data(8).gt.Urea, ...
%     'UniformOutput', false);
% lgd = legend(legend_values, 'Location', 'eastoutside', ...
%     'FontSize', 13);
% title(lgd, 'VWC & N');


function plot_data_1x2(data, fre, opts)
    nC = size(opts.colors,1);
    nM = numel(opts.markers);
    
    for i = 1:length(data)
        fig = figure('Units','centimeters', ...
                     'Position',[0,0,opts.width*2,opts.height]);
        clf
        
        t = tiledlayout(1,2,'Padding','tight','TileSpacing','compact');
        ax = gobjects(1,2);
        
        types   = {'Mag','Phs'};
        fields  = {'mag','phs'};
        ylabels = {'Magnitude ratio (dB)','Absolute phase difference (°)'};
        
        for k = 1:2
            ax(k) = nexttile;

            ti = get(ax(k),'TightInset');
            set(ax(k), 'LooseInset', ti);

            hold(ax(k),'on');
            for j = 1:numel(data(i).gt.WC)
                cIdx = mod(j-1, nC) + 1;
                mIdx = mod(floor((j-1)/nC), nM) + 1;

                y    = data(i).data.(fields{k})(j,:);
                semilogx(ax(k), fre, y, ...
                    'Color', opts.colors(cIdx,:), ...
                    'Marker', opts.markers{mIdx}, ...
                    'MarkerSize', 5, ...
                    'MarkerIndices', 10:300:length(y), ...
                    'LineWidth', opts.linewidth, ...
                    'MarkerEdgeColor', opts.colors(cIdx,:), ...
                    'MarkerFaceColor', opts.colors(cIdx,:));
            end
            hold(ax(k),'off');
            axis(ax(k),'tight');
            % if k== 1
            %      ylim(ax(k), [-29 0]);
            % else
            %      ylim(ax(k), [0 80]);
            % end
            set(ax(k), ...
                'XScale', 'log', ...
                'XMinorTick','on', ...
                'YMinorTick', 'on', ...
                'Box', 'on', ...
                'Layer', 'top', ...
                'LineWidth',    1.3, ...
                'FontName', opts.fontType, ...
                'FontSize', opts.fontSize);
            ax(k).XTick = [1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9];
            xlabel(ax(k),'Frequency (Hz)');
            ylabel(ax(k), ylabels{k});
            % title(ax(k), types{k});
            grid(ax(k), 'on');
        end
        
        % Build legend entries
        legEntries = arrayfun(@(vwc, urea) ...
            sprintf('W: %.3f N: %02d', vwc, urea), ...
            data(i).gt.WC, data(i).gt.NH4NO3, ...
            'UniformOutput', false);

        
        % Grab only the lines from the first panel
        hLines = findobj(ax(1), 'Type','Line');
        hLines = flipud(hLines);  % ensure plotted order
        

        % Create shared legend on that axes
        lgd = legend(ax(1), hLines, legEntries, ...
            'Orientation','horizontal', ...
            'Units','normalized', ...
            'FontSize', opts.fontSize, ...
            'NumColumns', 3);

        lgd.Box = 'off';
        lgd.Title.String = 'VWC levels (W: cm^3/cm^3) & Ammonium nitrate added (N: mg)';
        lgd.Layout.Tile = 'south';

        fname = sprintf('%d.svg', i);
        %print(gcf, '-dsvg', fname);
    end
end


function plot_data_2x1(data, fre, opts)
    nC = size(opts.colors,1);
    nM = numel(opts.markers);
    
    for i = 1:length(data)
        fig = figure('Units','centimeters', ...
                     'Position',[0,0,opts.width*2,opts.height*2]);
        clf
        
        t = tiledlayout(2,1,'Padding','tight','TileSpacing','tight');
        ax = gobjects(2,1);
        
        types   = {'Mag','Phs'};
        fields  = {'mag','phs'};
        ylabels = {'Magnitude ratio (dB)','Absolute phase difference (°)'};
        
        for k = 1:2
            ax(k) = nexttile;

            ti = get(ax(k),'TightInset');
            set(ax(k), 'LooseInset', ti);

            hold(ax(k),'on');
            for j = 1:numel(data(i).gt.WC)
                cIdx = mod(j-1, nC) + 1;
                mIdx = mod(floor((j-1)/nC), nM) + 1;

                y    = data(i).data.(fields{k})(j,:);
                semilogx(ax(k), fre, y, ...
                    'Color', opts.colors(cIdx,:), ...
                    'Marker', opts.markers{mIdx}, ...
                    'MarkerSize', 5, ...
                    'MarkerIndices', 10:300:length(y), ...
                    'LineWidth', opts.linewidth, ...
                    'MarkerEdgeColor', opts.colors(cIdx,:), ...
                    'MarkerFaceColor', opts.colors(cIdx,:));
            end
            hold(ax(k),'off');
            axis(ax(k),'tight');
            if k== 1
                 ylim(ax(k), [-21 0]);
            else
                 ylim(ax(k), [0 70]);
            end
            set(ax(k), ...
                'XScale', 'log', ...
                'XMinorTick','on', ...
                'YMinorTick', 'on', ...
                'Box', 'on', ...
                'Layer', 'top', ...
                'LineWidth',    1.3, ...
                'FontName', opts.fontType, ...
                'FontSize', opts.fontSize);
            ax(k).XTick = [1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9];
            xlabel(ax(k),'Frequency (Hz)');
            ylabel(ax(k), ylabels{k});
            % title(ax(k), types{k});
            grid(ax(k), 'on');

            if k == 1
                ax(k).XLabel.String = '';
                ax(k).XTickLabel = [];
            else
                xlabel(ax(k),'Frequency (Hz)');
            end

        end
        
        % Build legend entries
        legEntries = arrayfun(@(vwc, urea) ...
            sprintf('W: %.3f N: %02d', vwc, urea), ...
            data(i).gt.WC, data(i).gt.NH4NO3, ...
            'UniformOutput', false);

        
        % Grab only the lines from the first panel
        hLines = findobj(ax(1), 'Type','Line');
        hLines = flipud(hLines);  % ensure plotted order
        

        % Create shared legend on that axes
        lgd = legend(ax(1), hLines, legEntries, ...
            'Orientation','horizontal', ...
            'Units','normalized', ...
            'FontSize', opts.fontSize, ...
            'NumColumns', 3);

        lgd.Box = 'off';
        lgd.Title.String = 'VWC levels (W: cm^3/cm^3) & Ammonium nitrate added (N: mg)';
        lgd.Layout.Tile = 'south';

        fname = sprintf('N%d.svg', i);
        print(gcf, '-dsvg', fname);
    end
end







