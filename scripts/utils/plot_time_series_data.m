% function plot_time_series_data(W_file_path, N_file_path, data)
% % -------------------------------------------------------------------------
% % This function reads precipitation data, nitrogen data, and soil moisture
% % data to generate multiple subplots showing trends over time with 
% % annotations for fertilizer applications.
% %
% % Inputs:
% %   W_file_path - Path to the weather data file (CSV or Excel).
% %   N_file_path - Path to the nitrogen application data file (Excel).
% %   data        - Struct containing VWC, NO3, NH4, and total nitrogen (TN)
% %                 data for multiple plots.
% % Author: Mingqiang Han
% % Date: 10-18-24
% % -------------------------------------------------------------------------
% 
% % Read Weather Data
% weather_data = readtable(W_file_path);  % Load weather data into a table
% 
% % Extract timestamps and precipitation data, ignoring the first two entries
% timestamps = weather_data.("Timestamp")(3:end);
% precipitation = weather_data.("Precipitation")(3:end);
% 
% % Get the field names from the input data struct (e.g., 'VWC', 'NO3', etc.)
% fields = fieldnames(data);
% 
% % Loop Through Data Fields and Plot Names
% for f = 1:length(fields)
%     % Extract plot names for each field
%     plot_names = fieldnames(data.(fields{f}));  
% 
%     for p = 1:length(plot_names)
%         % Read nitrogen data for each plot from the respective sheet
%         fertilizer_data = readtable(N_file_path, ...
%                                    'Sheet', plot_names{p}, ...
%                                    'VariableNamingRule', 'preserve');
% 
%         % Store fertilizer data and field-specific data in plot_data struct
%         plot_data.(plot_names{p}).fertilizer = fertilizer_data;
%         plot_data.(plot_names{p}).(fields{f}) = ...
%             data.(fields{f}).(plot_names{p});
%     end
% end
% 
% % Extract the plot names from plot_data struct
% plot_names = fieldnames(plot_data);
% 
% % Generate Subplots for Each Plot
% for i = 1:length(plot_names)
%     plot_name = plot_names{i};  % Current plot name
% 
%     % Determine the minimum and maximum dates across all data for alignment
%     datemin = min(min(plot_data.(plot_name).VWC{1}), ...
%         min(plot_data.(plot_name).fertilizer.Date));
%     datemax = max(max(plot_data.(plot_name).VWC{1}), ...
%         max(plot_data.(plot_name).fertilizer.Date));
% 
%     % Filter timestamps and precipitation within the data range
%     date_filter = timestamps >= datemin & timestamps <= datemax;
%     rain = {timestamps(date_filter), precipitation(date_filter)};
% 
%     % Create a new figure window with specified size and position
%     figure('Position', [100, 100, 1000, 700]);
%     % Replace underscores with hyphens in plot title
%     tname = strrep(plot_name, '_', '-'); 
%     sgtitle(tname, 'Interpreter', 'none');  % Set figure title
% 
%     % Adjust subplot position and width
%     left_adjust = 0.07;
%     widthratio = 0.91;
% 
%     % Subplot 1: Precipitation
%     axw = subplot(5, 1, 1);
%     set(axw, 'Position', [left_adjust, 0.77, widthratio, 0.16]);
% 
%     % Adjust bar width and y-axis limits based on plot index
%     if i <= 2
%         % ylim([0 45]);
%         barwidth = 0.5;
%     else
%         % ylim([0 30]);
%         barwidth = 0.3;
%     end
% 
%     % Plot precipitation as a bar chart
%     bar(rain{1}, rain{2}, 'FaceColor', 'b', 'EdgeColor', 'none', ...
%         'BarWidth', barwidth);
%     ylabel('Rain (mm)', 'FontSize', 11);
%     set(axw, 'YDir', 'reverse', 'YColor', 'k', ...
%         'box', 'on', 'FontSize', 10, ...
%         'LineWidth', 1.3);
%     grid(axw, 'on');
%     axw.GridLineStyle = '--';
%     axw.GridColor     = [0.3 0.3 0.3];
%     axw.GridAlpha     = 0.6;
% 
%     % Subplot 2: Volumetric Soil Moisture (VWC)
%     ax1 = subplot(5, 1, 2);
%     set(ax1, 'Position', [left_adjust, 0.595, widthratio, 0.16]);
% 
%     % Plot VWC data
%     plot(plot_data.(plot_name).VWC{1}, ...
%          plot_data.(plot_name).VWC{2} * 100, ...
%         'LineWidth', 1.5, 'Color', '#1f78b4', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#1f78b4');
%     ylabel('VWC (%)', 'FontSize', 11);
%     set(ax1, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(ax1, 'on');
%     ax1.GridLineStyle = '--';
%     ax1.GridColor     = [0.3 0.3 0.3];
%     ax1.GridAlpha     = 0.6;
% 
% 
%     % Subplot 3: NO3-N Concentration
%     ax2 = subplot(5, 1, 3);
%     set(ax2, 'Position', [left_adjust, 0.42, widthratio, 0.16]);
% 
%     % Plot NO3 data
%     plot(plot_data.(plot_name).NO3{1}, plot_data.(plot_name).NO3{2}, ...
%         'LineWidth', 1.5, 'Color', '#33a02c', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#33a02c');
%     ylabel('NO_3 (ppm)', 'FontSize', 11);
%     set(ax2, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(ax2, 'on');
%     ax2.GridLineStyle = '--';
%     ax2.GridColor     = [0.3 0.3 0.3];
%     ax2.GridAlpha     = 0.6;
% 
%     % Subplot 4: NH4-N Concentration
%     ax3 = subplot(5, 1, 4);
%     set(ax3, 'Position', [left_adjust, 0.245, widthratio, 0.16]);
% 
%     % Plot NH4 data
%     plot(plot_data.(plot_name).NH4{1}, plot_data.(plot_name).NH4{2}, ...
%         'LineWidth', 1.5, 'Color', '#ff7f00', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#ff7f00');
%     ylabel('NH_4 (ppm)', 'FontSize', 11);
%     set(ax3, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(ax3, 'on');
%     ax3.GridLineStyle = '--';
%     ax3.GridColor     = [0.3 0.3 0.3];
%     ax3.GridAlpha     = 0.6;
% 
%     % Subplot 5: Total Nitrogen (TN)
%     ax4 = subplot(5, 1, 5);
%     set(ax4, 'Position', [left_adjust, 0.07, widthratio, 0.16]);
% 
%     % Plot total nitrogen data
%     plot(plot_data.(plot_name).totN{1}, plot_data.(plot_name).totN{2}, ...
%         'LineWidth', 1.5, 'Color', '#984ea3', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#984ea3');
%     ylabel('TN (%)', 'FontSize', 11);
%     set(ax4, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(ax4, 'on');
%     ax4.GridLineStyle = '--';
%     ax4.GridColor     = [0.3 0.3 0.3];
%     ax4.GridAlpha     = 0.6;
% 
%     % Link X-Axes of All Subplots
%     linkaxes([axw, ax1, ax2, ax3, ax4], 'x');
%     xlim([datemin - days(2), datemax]);  % Set x-axis limits with padding
%     xlabel(ax4, 'Date', 'FontSize', 11);
%     ax4.XTickLabelRotation = 45;
%     datetick(ax4, 'x', 'dd-mmm', 'keeplimits');
% 
% 
%     % Plot Fertilizer Application Lines
%     numline = length(plot_data.(plot_name).fertilizer.Date);
%     for j = 1:numline
%         x_value_date = plot_data.(plot_name).fertilizer.Date(j);
% 
%         % Plot vertical lines in all subplots
%         for ax = [axw, ax1, ax2, ax3, ax4]
%             xline(ax, x_value_date, '--', 'Color', 'r', ...
%                 'LineWidth', 1.5);
%         end
% 
%         % Annotate fertilizer application amount
%         amount = plot_data.(plot_name).fertilizer.('Amount (lbs/acre)')(j);
%         annotation = sprintf("Urea:\n%d lbs/acre", amount);
%         y_lim1 = get(ax2, 'YLim');
%         text(x_value_date + days(0.5), y_lim1(2) * 0.75, annotation, ...
%             'Color', 'r', 'FontSize', 11, 'Parent', ax2, ...
%             'HorizontalAlignment', 'left');
%     end
%     hold off;
% end

% function plot_time_series_data(W_file_path, N_file_path, data)
% % -------------------------------------------------------------------------
% % This function reads precipitation data, nitrogen data, and soil moisture
% % data to generate multiple subplots showing trends over time with 
% % annotations for fertilizer applications.
% %
% % Inputs:
% %   W_file_path - Path to the weather data file (CSV or Excel).
% %   N_file_path - Path to the nitrogen application data file (Excel).
% %   data        - Struct containing VWC, NO3, NH4, and total nitrogen (TN)
% %                 data for multiple plots.
% % Author: Mingqiang Han
% % Date: 10-18-24
% % -------------------------------------------------------------------------
% 
% % Read Weather Data
% weather_data = readtable(W_file_path);  % Load weather data into a table
% % disp(weather_data)
% 
% % Extract timestamps and precipitation data, ignoring the first two entries
% timestamps = weather_data.("Timestamp")(3:end);
% precipitation = weather_data.("Precipitation")(3:end);
% temperatureave = (weather_data.("AirTemperature")(3:end) + weather_data.("AirTemperature_1")(3:end))/2;
% 
% % Get the field names from the input data struct (e.g., 'VWC', 'NO3', etc.)
% fields = fieldnames(data);
% 
% % Loop Through Data Fields and Plot Names
% for f = 1:length(fields)
%     % Extract plot names for each field
%     plot_names = fieldnames(data.(fields{f}));  
% 
%     for p = 1:length(plot_names)
%         % Read nitrogen data for each plot from the respective sheet
%         fertilizer_data = readtable(N_file_path, ...
%                                    'Sheet', plot_names{p}, ...
%                                    'VariableNamingRule', 'preserve');
% 
%         % Store fertilizer data and field-specific data in plot_data struct
%         plot_data.(plot_names{p}).fertilizer = fertilizer_data;
%         plot_data.(plot_names{p}).(fields{f}) = ...
%             data.(fields{f}).(plot_names{p});
%     end
% end
% 
% % Extract the plot names from plot_data struct
% plot_names = fieldnames(plot_data);
% 
% % Generate Subplots for Each Plot
% for i = 1:length(plot_names)
%     plot_name = plot_names{i};  % Current plot name
% 
%     % Determine the minimum and maximum dates across all data for alignment
%     datemin = min(min(plot_data.(plot_name).VWC{1}), ...
%         min(plot_data.(plot_name).fertilizer.Date));
%     datemax = max(max(plot_data.(plot_name).VWC{1}), ...
%         max(plot_data.(plot_name).fertilizer.Date));
% 
%     % Filter timestamps and precipitation within the data range
%     date_filter = timestamps >= datemin & timestamps <= datemax;
%     rain = {timestamps(date_filter), precipitation(date_filter)};
%     temp = {timestamps(date_filter), temperatureave(date_filter)};
% 
%     % Create a new figure window with specified size and position
%     figure('Position', [100, 100, 1200, 500]);
%     % Replace underscores with hyphens in plot title
%     tname = strrep(plot_name, '_', '-'); 
%     sgtitle(tname, 'Interpreter', 'none');  % Set figure title
% 
%     % Adjust subplot position and width
%     left_adjust = 0.07;
%     widthratio = 0.85;
% 
%     % Subplot 1: Precipitation
%     axw = subplot(5, 1, 1);
%     set(axw, 'Position', [left_adjust, 0.77, widthratio, 0.16]);
% 
%     % Adjust bar width and y-axis limits based on plot index
%     if i <= 2
%         % ylim([0 45]);
%         barwidth = 0.5;
%     else
%         % ylim([0 30]);
%         barwidth = 0.3;
%     end
% 
%     % Plot precipitation as a bar chart
%     yyaxis(axw, "left")
%     bar(rain{1}, rain{2}, 'FaceColor', 'b', 'EdgeColor', 'none', ...
%         'BarWidth', barwidth);
%     ylabel('Rain (mm)', 'FontSize', 11);
%     set(axw, 'YDir', 'reverse', ...
%         'box', 'on', 'FontSize', 10, ...
%         'LineWidth', 1.3);
%     axw.YAxis(1).Color = 'b';
%     axw.YAxis(1).FontSize = 11;
%     grid(axw, 'on');
%     axw.GridLineStyle = '--';
%     axw.GridColor     = [0.3 0.3 0.3];
%     axw.GridAlpha     = 0.6;
% 
%     yyaxis(axw, "right")
%     plot(temp{1}, temp{2}, ...
%         'LineWidth', 1.5, 'Color', '#f781bf', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#f781bf');
%     ylabel('Temp (°C)', 'FontSize', 11);
%     axw.YAxis(2).Color = '#f781bf';
%     axw.YAxis(2).FontSize = 11;
%     axw.YGrid      = 'on';
% 
%     set(axw, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(axw, 'on');
%     axw.GridLineStyle = '--';
%     axw.GridColor     = [0.3 0.3 0.3];
%     axw.GridAlpha     = 0.6;
% 
% 
% 
%     % Subplot 2: Volumetric Soil Moisture (VWC)
%     ax1 = subplot(5, 1, 2);
%     set(ax1, 'Position', [left_adjust, 0.595, widthratio, 0.16]);
% 
%     % Plot VWC data
%     yyaxis(ax1, "left")
%     plot(plot_data.(plot_name).VWC{1}, ...
%          plot_data.(plot_name).VWC{2} * 100, ...
%         'LineWidth', 1.5, 'Color', '#1f78b4', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#1f78b4');
%     ylabel('VWC (%)', 'FontSize', 11);
%     ax1.YAxis(1).Color = '#1f78b4';  % match line color
%     ax1.YAxis(1).FontSize = 11;
%     ax1.YGrid      = 'on';
%     % set(ax1, 'Box', 'on', 'FontSize', 10, ...
%     %     'XMinorTick','on', ...
%     %     'YMinorTick', 'on', ...
%     %     'LineWidth', 1.3);
%     % hold on;
%     % grid(ax1, 'on');
%     % ax1.GridLineStyle = '--';
%     % ax1.GridColor     = [0.3 0.3 0.3];
%     % ax1.GridAlpha     = 0.6;
% 
%     yyaxis(ax1, "right")
%     plot(plot_data.(plot_name).totN{1}, plot_data.(plot_name).totN{2}, ...
%         'LineWidth', 1.5, 'Color', '#984ea3', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#984ea3');
%     ylabel('TN (%)', 'FontSize', 11);
%     ax1.YAxis(2).Color = '#984ea3';
%     ax1.YAxis(2).FontSize = 11;
%     ax1.YGrid      = 'on';
% 
%     set(ax1, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     grid(ax1, 'on');
%     ax1.GridLineStyle = '--';
%     ax1.GridColor     = [0.3 0.3 0.3];
%     ax1.GridAlpha     = 0.6;
% 
% 
%     % Subplot 3: NO3-N Concentration
%     ax2 = subplot(5, 1, 3);
%     set(ax2, 'Position', [left_adjust, 0.42, widthratio, 0.16]);
% 
%     % Plot NO3 data
%     yyaxis(ax2, "left")
%     plot(plot_data.(plot_name).NO3{1}, plot_data.(plot_name).NO3{2}, ...
%         'LineWidth', 1.5, 'Color', '#33a02c', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#33a02c');
%     ylabel('NO_3 (ppm)', 'FontSize', 11);
%     set(ax2, 'Box', 'on', 'FontSize', 10, ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     ax2.YAxis(1).Color = '#33a02c';
%     ax2.YAxis(1).FontSize = 10;
%     grid(ax2, 'on');
%     ax2.GridLineStyle = '--';
%     ax2.GridColor     = [0.3 0.3 0.3];
%     ax2.GridAlpha     = 0.6;
% 
%     yyaxis(ax2, "right")
%     % Plot NH4 data
%     plot(plot_data.(plot_name).NH4{1}, plot_data.(plot_name).NH4{2}, ...
%         'LineWidth', 1.5, 'Color', '#ff7f00', 'Marker', 'o', ...
%         'MarkerSize', 3, 'MarkerFaceColor', '#ff7f00');
%     ylabel('NH_4 (ppm)', 'FontSize', 11);
%     set(ax2, 'Box', 'on', ...
%         'XMinorTick','on', ...
%         'YMinorTick', 'on', ...
%         'LineWidth', 1.3);
%     hold on;
%     ax2.YAxis(2).Color = '#ff7f00';
%     ax2.YAxis(2).FontSize = 10;
%     grid(ax2, 'on');
%     ax3.GridLineStyle = '--';
%     ax3.GridColor     = [0.3 0.3 0.3];
%     ax3.GridAlpha     = 0.6;
% 
% 
%     % Link X-Axes of All Subplots
%     linkaxes([axw, ax1, ax2], 'x');
%     xlim([datemin - days(2), datemax]);  % Set x-axis limits with padding
%     %xlabel(ax2, 'Date', 'FontSize', 11);
%     set(axw, 'XTickLabel', []);
%     set(ax1, 'XTickLabel', []);
%     ax2.XTickLabelRotation = 45;
%     datetick(ax2, 'x', 'dd-mmm', 'keeplimits');
% 
% 
%     % Plot Fertilizer Application Lines
%     numline = length(plot_data.(plot_name).fertilizer.Date);
%     for j = 1:numline
%         x_value_date = plot_data.(plot_name).fertilizer.Date(j);
% 
%         % Plot vertical lines in all subplots
%         for ax = [axw, ax1, ax2]
%             xline(ax, x_value_date, '--', 'Color', 'r', ...
%                 'LineWidth', 1.5);
%         end
% 
%         % Annotate fertilizer application amount
%         amount = plot_data.(plot_name).fertilizer.('Amount (lbs/acre)')(j);
%         annotation = sprintf("Urea:\n%d lbs/acre", amount);
%         y_lim1 = get(ax2, 'YLim');
%         text(x_value_date + days(0.5), y_lim1(2) * 0.75, annotation, ...
%             'Color', 'r', 'FontSize', 11, 'Parent', ax2, ...
%             'HorizontalAlignment', 'left');
%     end
%     hold off;
% end
% 

function plot_time_series_data(W_file_path, N_file_path, data)
% -------------------------------------------------------------------------
% This function reads precipitation data, nitrogen data, and soil moisture
% data to generate multiple subplots showing trends over time with 
% annotations for fertilizer applications.
%
% Inputs:
%   W_file_path - Path to the weather data file (CSV or Excel).
%   N_file_path - Path to the nitrogen application data file (Excel).
%   data        - Struct containing VWC, NO3, NH4, and total nitrogen (TN)
%                 data for multiple plots.
% Author: Mingqiang Han
% Date: 10-18-24
% -------------------------------------------------------------------------

% Read Weather Data
weather_data    = readtable(W_file_path);
timestamps      = weather_data.Timestamp(3:end);
precipitation   = weather_data.Precipitation(3:end);
temperatureave  = (weather_data.AirTemperature(3:end) + ...
                   weather_data.AirTemperature_1(3:end)) / 2;

% Build plot_data struct by reading each sheet of N_file_path
fields = fieldnames(data);
for f = 1:numel(fields)
    plot_names = fieldnames(data.(fields{f}));
    for p = 1:numel(plot_names)
        fert = readtable(N_file_path, ...
                         'Sheet', plot_names{p}, ...
                         'VariableNamingRule', 'preserve');
        plot_data.(plot_names{p}).fertilizer = fert;
        plot_data.(plot_names{p}).(fields{f}) = ...
            data.(fields{f}).(plot_names{p});
    end
end
plot_names = fieldnames(plot_data);
textsize = 10;

% Loop over each plot
for i = 1:numel(plot_names)
    name = plot_names{i};
    pd   = plot_data.(name);
    
    % Compute overall date range
    datemin     = min([pd.VWC{1}; pd.fertilizer.Date]);
    datemax     = max([pd.VWC{1}; pd.fertilizer.Date]);
    date_filter = timestamps >= datemin & timestamps <= datemax;
    
    rain = { timestamps(date_filter), precipitation(date_filter) };
    temp = { timestamps(date_filter), temperatureave(date_filter)  };
    
    % New figure & title
    figure('Units', 'centimeters', ...
            'Position', [5,5,16,11]);
    sgtitle(strrep(name, '_', '-'), 'Interpreter','none');
    
    t = tiledlayout(3,1, ...
       'Padding','none', ...
       'TileSpacing','compact');

    
    % Subplot 1: Rain & Temperature
    axw = nexttile(t,1);
    
    % choose bar width based on i
    if i <= 2
        barWidth = 0.5;
    else
        barWidth = 0.3;
    end
    
    yyaxis(axw, 'left');
      bar(rain{1}, rain{2}, ...
          'BarWidth',    barWidth, ...
          'FaceColor',  'b', ...
          'EdgeColor',  'none');
      ylabel('Precipitation (mm)', 'FontSize', textsize);
      set(axw, 'YDir', 'reverse');
      axw.YAxis(1).Color    = 'b';
      axw.YAxis(1).FontSize = textsize;
    
    yyaxis(axw, 'right');
      plot(temp{1}, temp{2}, ...
           'LineWidth',     1.5, ...
           'Color',         '#f781bf', ...
           'Marker',        'o', ...
           'MarkerSize',    3, ...
           'MarkerFaceColor','#f781bf');
      ylabel('Temperature (°C)', 'FontSize', textsize);
      axw.YAxis(2).Color    = '#f781bf';
      axw.YAxis(2).FontSize = textsize;
    
    % Subplot 2: VWC & TN
    ax1 = nexttile(t,2);
    
    yyaxis(ax1, 'left');
      plot(pd.VWC{1}, pd.VWC{2}, ...
           'LineWidth',     1.5, ...
           'Color',         '#1f78b4', ...
           'Marker',        'o', ...
           'MarkerSize',    3, ...
           'MarkerFaceColor','#1f78b4');
      ylabel('VWC (cm^3/cm^3)', 'FontSize', textsize);
      ax1.YAxis(1).Color    = '#1f78b4';
      ax1.YAxis(1).FontSize = textsize;
    
    yyaxis(ax1, 'right');
      plot(pd.totN{1}, pd.totN{2}, ...
           'LineWidth',     1.5, ...
           'Color',         '#984ea3', ...
           'Marker',        'o', ...
           'MarkerSize',    3, ...
           'MarkerFaceColor','#984ea3');
      ylabel('Total Nitrogen (%)', 'FontSize', textsize);
      ax1.YAxis(2).Color    = '#984ea3';
      ax1.YAxis(2).FontSize = textsize;
    
    % Subplot 3: NO3 & NH4
    ax2 = nexttile(t,3);
    
    yyaxis(ax2, 'left');
      plot(pd.NO3{1}, pd.NO3{2}, ...
           'LineWidth',     1.5, ...
           'Color',         '#33a02c', ...
           'Marker',        'o', ...
           'MarkerSize',    3, ...
           'MarkerFaceColor','#33a02c');
      ylabel('NO_3-N (ppm)', 'FontSize', textsize);
      ax2.YAxis(1).Color    = '#33a02c';
      ax2.YAxis(1).FontSize = textsize;
    
    yyaxis(ax2, 'right');
      plot(pd.NH4{1}, pd.NH4{2}, ...
           'LineWidth',     1.5, ...
           'Color',         '#ff7f00', ...
           'Marker',        'o', ...
           'MarkerSize',    3, ...
           'MarkerFaceColor','#ff7f00');
      ylabel('NH_4-N (ppm)', 'FontSize', textsize);
      ax2.YAxis(2).Color    = '#ff7f00';
      ax2.YAxis(2).FontSize = textsize;
    
      % Link all three axes
      linkaxes([axw, ax1, ax2], 'x');
      % Define the full range (you already have datemin, datemax)
      xstart = datemin - days(2);
      xend   = datemax;
      xlim([xstart, xend]);

      % Compute 7 evenly spaced datetime ticks
      numTicks = 7;
      commonTicks = xstart + (0:numTicks-1)'*(xend - xstart)/(numTicks-1);

      % Apply to all axes so they line up
      set([axw, ax1, ax2], 'XTick', commonTicks);

      % Format tick labels as dates
      xtickformat([axw, ax1, ax2], 'MM/dd/yy');

      % Hide the labels on the top two, leave only the bottom showing
      set([axw, ax1], 'XTickLabel', []);

      set([axw, ax1, ax2], 'FontSize', textsize);

    
    % Plot fertilizer lines & annotations
    for j = 1:height(pd.fertilizer)
        d   = pd.fertilizer.Date(j);
        amt = pd.fertilizer.("Amount (lbs/acre)")(j);
        
        % draw the vertical line on each axes individually
        for ax = [axw, ax1, ax2]
            xline(ax, d, 'Color','r', 'LineWidth',1.5);
        end
        
        % annotate on the bottom plot
        yL = ax2.YLim;
        text(d + days(0.5), yL(2)*0.75, ...
             sprintf("Urea:\n%d lb/ac", amt), ...
             'Color','r', 'FontSize',textsize, ...
             'Parent', ax2, ...
             'HorizontalAlignment','left');
    end
    
    % Apply common styling
    axs = [axw, ax1, ax2];
    for ax = axs
        applyStyle(ax);
    end
    
    hold off;

    fname = sprintf('%s.svg', name);
    print(gcf, '-dsvg', fname);
end
end

function applyStyle(ax)
    % basic styling
    set(ax, ...
        'Box',        'on', ...
        'XMinorTick', 'on', ...
        'YMinorTick', 'on', ...
        'LineWidth',  1.3);
    grid(ax, 'on');
    ax.GridLineStyle = '--';
    ax.GridColor     = [0.3 0.3 0.3];
    ax.GridAlpha     = 0.6;

    % enforce at least 3 major ticks on BOTH y-axes
    for k = 1:2
        yAx = ax.YAxis(k);            % 1=left, 2=right
        yL  = yAx.Limits;             % current [min max]
        nT  = numel(yAx.TickValues);  % how many ticks are already there
        if nT < 3
            yAx.TickValues = linspace(yL(1), yL(2), 3);
        end
    end
end