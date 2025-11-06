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


% Define figure properties

% Define a set of colors
% opts.colors = [
%     0.0000 0.4470 0.7410;  % Blue
%     0.8500 0.3250 0.0980;  % Red
%     0.9290 0.6940 0.1250;  % Yellow
%     0.4940 0.1840 0.5560;  % Purple
%     0.4660 0.6740 0.1880;  % Green
%     0.3010 0.7450 0.9330;  % Light Blue
%     0.6350 0.0780 0.1840;  % Dark Red
%     0.0000 0.0000 0.0000;  % Black
%     1.0000 0.5490 0.0000;  % Orange
%     0.2500 0.8784 0.8157;  % Turquoise
%     0.5410 0.1686 0.8863;  % Medium Purple
%     0.0000 0.5020 0.0000;  % Dark Green
%     0.9412 0.5020 0.5020;  % Rosy Brown
%     0.6784 1.0000 0.1843;  % Lime Green
%     1.0000 0.8431 0.0000;  % Gold
%     0.8039 0.3608 0.3608;  % Light Red
% ];

% opts.colors = [
%     '#800080';
%     '#4b0082';  
%     '#0000ff';  
%     '#00ced1'; 
%     '#008000';
%     '#ffff00';  
%     '#ff5a00';  
%     '#ff0000';  
% ];

opts.colors = [
    '#003a7d';
    '#008dff';  
    '#ff73b6';  
    '#c701ff'; 
    '#4ecb8d';
    '#ff9d3a';  
    '#f9e858';  
    '#d83034';  
];

opts.markers = {'o','^'};
opts.width = 12;
opts.height = 13;
opts.fontType = 'Times New Roman';
opts.fontSize = 12;
opts.linewidth = 2;


% Plot Magnitude and Phase by calling the function
% plot_data(data, fre, opts, 'Mag');  % For Magnitude
% plot_data(data, fre, opts, 'Phs');  % For Phase

%plot_data_1x2(data, fre, opts);
plot_data_2x1(data, fre, opts);


% % Function to plot either Magnitude or Phase
% function plot_data(data, fre, opts, plot_type)
%     for i = 1:length(data)
%         fig = figure; clf
% 
%         % Choose between magnitude or phase
%         if strcmp(plot_type, 'Mag')
%             data_to_plot = data(i).data.mag;
%             ylabel_text = ' Magnitude ratio (dB)';
%         else
%             data_to_plot = data(i).data.phs;
%             ylabel_text = 'Absolute phase difference (degrees)';
%         end
% 
%         % Create the semilogx plot
%         hold on;
%         for j = 1:length(data(i).gt.WC_Prepared)
%             color_idx = mod(j-1, size(opts.colors, 1)) + 1;
%             semilogx(fre, data_to_plot(j, :), 'LineWidth', opts.linewidth, ...
%                      'Color', opts.colors(color_idx, :));
%         end
%         hold off;
% 
%         % Title
%         % title([data(i).expnum '-' data(i).Cabletype '-' plot_type]);
% 
%         % Create the legend once
%         legend_values = arrayfun(@(x) sprintf('%.3f', x), ...
%                         data(i).gt.WC_Prepared, 'UniformOutput', false);
%         lgd = legend(legend_values, 'Location', 'southoutside');
%         lgd.NumColumns = 4;
%         title(lgd, 'VWC');  % Add title to the legend
% 
%         % Axis labels
%         axis tight
%         xlabel('Frequency (Hz)');
%         ylabel(ylabel_text);
% 
%         set(gca, 'XScale', 'log');  % Ensure X-axis is logarithmic
% 
%         % scaling
%         fig.Units               = 'centimeters';
%         fig.Position(3)         = opts.width;
%         fig.Position(4)         = opts.height; 
%         set(fig.Children, 'FontName', opts.fontType, 'FontSize', opts.fontSize)
%     end
% end

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
            for j = 1:numel(data(i).gt.WC_Prepared)
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
                 ylim(ax(k), [-29 0]);
            else
                 ylim(ax(k), [0 80]);
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
        end
        
        % Build legend entries
        legEntries = arrayfun(@(x) sprintf('%.3f',x), ...
                              data(i).gt.WC_Prepared, ...
                              'UniformOutput', false);
        
        % Grab only the lines from the first panel
        hLines = findobj(ax(1), 'Type','Line');
        hLines = flipud(hLines);  % ensure plotted order
        

        % Create shared legend on that axes
        lgd = legend(ax(1), hLines, legEntries, ...
            'Orientation','horizontal', ...
            'Units','normalized', ...
            'FontSize', opts.fontSize, ...
            'NumColumns', 8);

        lgd.Box = 'off';
        lgd.Title.String = 'VWC levels (cm^3/cm^3)';
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
                     'Position',[0,0,opts.width*2,opts.height*2]); % <-- switched width/height ratio
        clf
        
        % Change tiledlayout from 1x2 to 2x1
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
            for j = 1:numel(data(i).gt.WC_Prepared)
                cIdx = mod(j-1, nC) + 1;
                mIdx = mod(floor((j-1)/nC), nM) + 1;

                y = data(i).data.(fields{k})(j,:);
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
            if k == 1
                 ylim(ax(k), [-29 0]);
            else
                 ylim(ax(k), [0 80]);
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
        legEntries = arrayfun(@(x) sprintf('%.3f',x), ...
                              data(i).gt.WC_Prepared, ...
                              'UniformOutput', false);
        
        % Grab only the lines from the first panel
        hLines = findobj(ax(1), 'Type','Line');
        hLines = flipud(hLines);  % ensure plotted order

        % Create shared legend at bottom
        lgd = legend(ax(1), hLines, legEntries, ...
            'Orientation','horizontal', ...
            'Units','normalized', ...
            'FontSize', opts.fontSize, ...
            'NumColumns', 8);

        lgd.Box = 'off';
        lgd.Title.String = 'VWC levels (cm^3/cm^3)';
        lgd.Layout.Tile = 'south'; % attach legend under the tiled layout

        fname = sprintf('%d.svg', i);
        print(gcf, '-dsvg', fname);
    end
end


