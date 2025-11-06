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

[mag_CV_by_level, phs_CV_by_level, VWC] = calcualt_CV_by_VWC(data, 'LC');
plotRepeatability(fre, VWC, mag_CV_by_level, phs_CV_by_level, 12, 'Times New Roman')
fname = sprintf('%s.svg', 'LC_repeat');
print(gcf, '-dsvg', fname);

LC_mag_CV_mu    = mean(mag_CV_by_level, 2);     
LC_mag_CV_sigma = std(mag_CV_by_level, 1, 2);

LC_phs_CV_mu    = mean(phs_CV_by_level, 2);     
LC_phs_CV_sigma = std(phs_CV_by_level, 1, 2); 

[mag_CV_by_level, phs_CV_by_level, VWC] = calcualt_CV_by_VWC(data, 'SC');
plotRepeatability(fre, VWC, mag_CV_by_level, phs_CV_by_level, 12, 'Times New Roman')
fname = sprintf('%s.svg', 'SC_repeat');
print(gcf, '-dsvg', fname);

SC_mag_CV_mu    = mean(mag_CV_by_level, 2);     
SC_mag_CV_sigma = std(mag_CV_by_level, 1, 2);

SC_phs_CV_mu    = mean(phs_CV_by_level, 2);     
SC_phs_CV_sigma = std(phs_CV_by_level, 1, 2); 


plotCVButterfly(VWC, LC_mag_CV_mu, LC_mag_CV_sigma, LC_phs_CV_mu, LC_phs_CV_sigma, ...
            12, 'Times New Roman')
fname = sprintf('%s.svg', 'LC_meanCV');
print(gcf, '-dsvg', fname);


plotCVButterfly(VWC, SC_mag_CV_mu, SC_mag_CV_sigma, SC_phs_CV_mu, SC_phs_CV_sigma, ...
            12, 'Times New Roman')
fname = sprintf('%s.svg', 'SC_meanCV');
print(gcf, '-dsvg', fname);


mainpath = 'data';
gt_subpath = 'Lab\LC_Angle.xlsx';
lab_exptype = 'WC_Bending';
lab_expnum = 'R1';
lab_expcbtype = 'LC';

[data, gt, num_samples] = load_lab_data(mainpath, lab_exptype, ...
                          lab_expnum, lab_expcbtype, gt_subpath);

M = reshape(data.mag, 4, 3, []);      
mag_mean = squeeze(mean(M,1)); 
mag_std  = squeeze(std(M,1,1)); 
mag_CV   = (mag_std ./ mag_mean) * 100; 

M = reshape(data.phs, 4, 3, []);      
phs_mean = squeeze(mean(M,1)); 
phs_std  = squeeze(std(M,1,1)); 
phs_CV   = (phs_std ./ phs_mean) * 100; 


mag_CV_mu    = mean(mag_CV, 2);     
mag_CV_sigma = std(mag_CV, 1, 2);

phs_CV_mu    = mean(phs_CV, 2);     
phs_CV_sigma = std(phs_CV, 1, 2); 

VWC = unique(gt.WC_Prepared, 'stable');

plotCVButterfly1(VWC, mag_CV_mu, mag_CV_sigma, phs_CV_mu, phs_CV_sigma, ...
                12, 'Times New Roman')
fname = sprintf('%s.svg', 'Bending_meanCV');
print(gcf, '-dsvg', fname);



% CV_by_level: [nLevels × nFreq] matrix
% fre:        1×nFreq vector of your actual frequency values

% nLevels = size(mag_CV_by_level,1);

% figure;
% ax = axes;
% % Create a grid: rows = levels, cols = freqs
% [X,Y] = meshgrid(fre, 1:nLevels);
%
% % Plot with pcolor
% pcolor(ax, X, Y, CV_by_level);
% shading flat;                % removes grid lines
% set(ax, 'XScale', 'log', ... % log scale on x
%         'YDir',   'normal'); % so level-1 is at the bottom
%
% % Labels & colorbar
% xlabel(ax, 'Frequency (Hz)');
% ylabel(ax, 'VWC Level');
% title(ax, 'Heatmap of CV (%) by Level and Frequency');
% colorbar(ax);
%


function plotCVButterfly1(VWC, mag_mu, mag_sigma, phs_mu, phs_sigma, fontsize, fontname)
    % create figure
    figure('Units','centimeters','Position',[0 0 25 5]);
    hold on

    % plot bars
    hMag = barh(VWC,  mag_mu, 'FaceColor', '#1b9e77');
    hPhs = barh(VWC, -phs_mu, 'FaceColor', '#d95f02');

    hMag.LineWidth = 1.5;      % e.g. 1.5-point edges
    hPhs.LineWidth = 1.5;

    % compute error-bar lengths, clipped at zero
    % for mag: negative error cannot exceed mag_mu itself
    negMag = min(mag_sigma, mag_mu);
    posMag = mag_sigma;
    % for phase: same logic
    negPhs = min(phs_sigma, phs_mu);
    posPhs = phs_sigma;

    % draw horizontal errorbars
    errorbar( mag_mu, VWC, zeros(size(negMag)), posMag, 'horizontal', ...
              'LineStyle','none','Color','k','LineWidth',1.5);
    errorbar(-phs_mu, VWC, negPhs, zeros(size(posPhs)), 'horizontal', ...
              'LineStyle','none','Color','k','LineWidth',1.5);

    % center line
    xline(0,'k--','LineWidth',1);

    % styling
    maxCV = max([mag_mu + mag_sigma; phs_mu + phs_sigma]);
    xlim([-maxCV, maxCV])

    % custom absolute x-tick labels
    ax = gca;
    N =  ceil(maxCV);
    xt = -N:0.1:N;                   
    ax.XTick      = xt;
    ax.XTickLabel = arrayfun(@(v) sprintf('%.1f',abs(v)), xt, 'Uni', false);
    ax.XLim = [-N N];


    % labels and title
    xlabel('Mean CV (%)',    'FontSize',fontsize, 'FontName',fontname);
    ylabel('VWC (cm^3/cm^3)','FontSize',fontsize, 'FontName',fontname);

    % legend
    legend([hMag,hPhs], {'Magnitude','Phase'}, ...
        'Location','southwest', ...
        'Orientation','horizontal', ...
        'NumColumns', 1, ...  
        'FontSize',fontsize,'FontName',fontname);
    legend boxoff;

    % finalize axes
    ax.FontSize = fontsize;
    ax.FontName = fontname;
    ax.LineWidth = 1.5;
    ax.YDir     = 'normal';

    ax.YTick      = VWC;                             % one tick at each VWC
    ax.YTickLabel = arrayfun(@(v) sprintf('%.3f',v), VWC, 'Uni', false);
    ax.YLim       = [min(VWC)-0.1 max(VWC)+0.1];             % limit exactly to your data

    box(ax,'on');
    grid(ax, 'on');

    ti = ax.TightInset;
    ax.Position = [ti(1) ti(2)-0.01 1-ti(1)-ti(3)-0.001 1-ti(2)-ti(4)];

    hold off
end




function plotCVButterfly(VWC, mag_mu, mag_sigma, phs_mu, phs_sigma, fontsize, fontname)
    % create figure
    figure('Units','centimeters','Position',[0 0 25 9]);
    hold on

    % plot bars
    hMag = barh(VWC,  mag_mu, 'FaceColor', '#1b9e77');
    hPhs = barh(VWC, -phs_mu, 'FaceColor', '#d95f02');

    hMag.LineWidth = 1.5;      % e.g. 1.5-point edges
    hPhs.LineWidth = 1.5;

    % compute error-bar lengths, clipped at zero
    % for mag: negative error cannot exceed mag_mu itself
    negMag = min(mag_sigma, mag_mu);
    posMag = mag_sigma;
    % for phase: same logic
    negPhs = min(phs_sigma, phs_mu);
    posPhs = phs_sigma;

    % draw horizontal errorbars
    errorbar( mag_mu, VWC, zeros(size(negMag)), posMag, 'horizontal', ...
              'LineStyle','none','Color','k','LineWidth',1.5);
    errorbar(-phs_mu, VWC, negPhs, zeros(size(posPhs)), 'horizontal', ...
              'LineStyle','none','Color','k','LineWidth',1.5);

    % center line
    xline(0,'k--','LineWidth',1);

    % styling
    maxCV = 12; %max([mag_mu + mag_sigma; phs_mu + phs_sigma]);
    xlim([-maxCV, maxCV])

    % custom absolute x-tick labels
    ax = gca;
    N =  ceil(maxCV);
    xt = -N:N;                   
    ax.XTick      = xt;
    ax.XTickLabel = arrayfun(@(v) sprintf('%d',abs(v)), xt, 'Uni', false);
    ax.XLim = [-N N];


    % labels and title
    xlabel('Mean CV (%)',    'FontSize',fontsize, 'FontName',fontname);
    ylabel('VWC (cm^3/cm^3)','FontSize',fontsize, 'FontName',fontname);

    % legend
    legend([hMag,hPhs], {'Magnitude','Phase'}, ...
        'Location','southwest', ...
        'Orientation','horizontal', ...
        'NumColumns', 1, ...  
        'FontSize',fontsize,'FontName',fontname);
    legend boxoff;

    % finalize axes
    ax.FontSize = fontsize;
    ax.FontName = fontname;
    ax.LineWidth = 1.5;
    ax.YDir     = 'normal';

    ax.YTick      = VWC;                             % one tick at each VWC
    ax.YTickLabel = arrayfun(@(v) sprintf('%.3f',v), VWC, 'Uni', false);
    ax.YLim       = [min(VWC)-0.035 max(VWC)+0.035];             % limit exactly to your data

    box(ax,'on');
    grid(ax, 'on');

    ti = ax.TightInset;
    ax.Position = [ti(1) ti(2)-0.01 1-ti(1)-ti(3)-0.001 1-ti(2)-ti(4)];

    hold off
end


function plotRepeatability(fre, VWC, mag_CV, phs_CV, fontsize, fontname)
% Create figure + 2×1 tiled layout
figure('Units','centimeters','Position',[0 0 25 11]);
t = tiledlayout(2,1,'Padding','compact','TileSpacing','compact');

% Color limits
cmin = 0;  
cmax = 20;

% PANEL 1: Magnitude CV
ax1 = nexttile(t,1);
imagesc(ax1, fre, VWC, mag_CV, [cmin cmax]);
ylabel(ax1, 'VWC (cm^3/cm^3)', ...
    'FontSize', fontsize, 'FontName', fontname);
text(ax1, -0.06, 1.10, '(a)', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment',   'top', ...
        'FontSize',    13, ...
        'FontName',    fontname, ...
        'FontWeight',  'bold');

% PANEL 2: Phase CV
ax2 = nexttile(t,2);
imagesc(ax2, fre, VWC, phs_CV, [cmin cmax]);
xlabel(ax2, 'Frequency (Hz)', ...
    'FontSize', fontsize, 'FontName', fontname);
ylabel(ax2, 'VWC (cm^3/cm^3)', ...
    'FontSize', fontsize, 'FontName', fontname);
text(ax2, -0.06, 1.10, '(b)', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment',   'top', ...
        'FontSize',    13, ...
        'FontName',    fontname, ...
        'FontWeight',  'bold');

% Shared colormap
colormap(parula)

% Common styling for both axes
for ax = [ax1, ax2]
    set(ax, ...
        'Box',       'on', ...
        'LineWidth', 1.5, ...
        'XScale',    'log', ...
        'YDir',      'normal', ...
        'FontSize',  fontsize, ...        % tick labels
        'FontName',  fontname ...         % tick labels
    );
    % Force valid log-range
    xlim(ax, [min(fre), max(fre)]);
end

% Hide x-ticks on top panel
set(ax1, 'XTickLabel', []);

% Link x-axes
linkaxes([ax1, ax2], 'x');

% Y-ticks: label every other one
yt = VWC;
ytl = arrayfun(@(v) sprintf('%.3f',v), yt, 'Uni', false);
ytl(2:2:end) = {''};
for ax = [ax1, ax2]
    set(ax, 'YTick', yt, 'YTickLabel', ytl);
end

% Shared colorbar on right
cb = colorbar;
cb.Layout.Tile = 'east';
% colorbar ticks and label
set(cb, ...
    'FontSize', fontsize, ...
    'FontName', fontname);
cb.Label.String   = 'CV (%)';
cb.Label.FontSize = fontsize;
cb.Label.FontName = fontname;

end





function [mag_CV_by_level, phs_CV_by_level, VWC] = calcualt_CV_by_VWC(data, Cabletype)
Idx = strcmp( {data.Cabletype}, Cabletype) & (1:numel(data) < 7);
lcData = data(Idx);

M          = numel(lcData);
VWC_levels = numel(lcData(1).gt.WC_Prepared);

% fill
for i = 1:M
    for j = 1:VWC_levels
        new_data{j}.VWC = lcData(i).gt.WC_Prepared(j);
        new_data{j}.mag(i,:) = lcData(i).data.mag(j, :);
        new_data{j}.phs(i,:) = lcData(i).data.phs(j, :);
    end
end

VWC_levels = numel(new_data);
mag_CV_by_level = zeros(VWC_levels, 1110);
phs_CV_by_level = zeros(VWC_levels, 1110);

for i = 1:VWC_levels
    mag = new_data{i}.mag;       
    mag_mu   = mean(mag, 1);          
    mag_sigma = std(mag, 1, 1);  

    phs = new_data{i}.phs;       
    phs_mu   = mean(phs, 1);          
    phs_sigma = std(phs, 1, 1);  

    mag_CV_by_level(i,:) = (mag_sigma./ mag_mu) * 100;  
    phs_CV_by_level(i,:) = (phs_sigma./ phs_mu) * 100;
    VWC(i) = new_data{i}.VWC;
end
end


function results = access_all_lab_data(mainpath, lab_exptype, gt_subpath)
% Define the list of experiment repeat numbers and cable types
lab_expnum = {'R1', 'R2', 'R3', 'R4'};     % Experiment numbers 
lab_expcbtype = {'SC', 'LC'};        % Cable types 

% Pre-allocate a structure array to store the results
results = struct('expnum', {}, 'Cabletype', {}, 'Numsamples', {}, ...
                 'data', {}, 'gt', {});

% Initialize an index to track the current entry in the structure array
idx = 1;

% Loop through each experiment repeat number (R1, R2, R3)
for i = 1:length(lab_expnum)
    % Loop through each cable type (SC, LC)
    for j = 1:length(lab_expcbtype)
        % Extract the current experiment repeat number and cable type
        current_expnum = lab_expnum{i};        % Current experiment number
        current_expcbtype = lab_expcbtype{j};  % Current cable type
        
        % Display the current experiment combination being processed
        fprintf('Experiment(%s), Cable type(%s) -> ', ...
                current_expnum, current_expcbtype);

        % Load magnitude, phase, and ground truth data
        [data, gt, data_size] = load_lab_raw_data(mainpath, ...
                                                  lab_exptype, ...
                                                  current_expnum, ...
                                                  current_expcbtype, ...
                                                  gt_subpath);
        % Display the number of samples found for this configuration
        fprintf('Found %3d samples.\n', data_size);
        
        % Store the results in the structure array
        results(idx).expnum = current_expnum;      
        results(idx).Cabletype = current_expcbtype;
        results(idx).Numsamples = data_size;       
        results(idx).data = data;                   
        results(idx).gt = gt;                     
        
        % Increment the index for the next entry in the structure array
        idx = idx + 1;
    end
end
end


function [data, gt, num_samples] = load_lab_data(mainpath, ...
                                                 lab_exptype, ...
                                                 lab_expnum, ...
                                                 lab_expcbtype, ...
                                                 gt_subpath)

% Set the size of frequency data (there are 1110 frequency points).
fre_size = 1110;

% Bulk density]
bulk_density = 1.2;

% Create the full path to the ground truth file using the provided subpath.
gt_path = fullfile(mainpath, gt_subpath);

% Read the ground truth data from an Excel sheet 
% corresponding to the given experiment number.
gt_data = readtable(gt_path, 'VariableNamingRule', 'preserve', ...
                    'Sheet', lab_expnum);

% Find the rows in the GT data that match 
% the specified cable type ('LC' or 'SC').
positions = find(strcmp(gt_data.("Cable Type"), lab_expcbtype));

% If the experiment type is 'WC' (Water Content):
if strcmp(lab_exptype, 'WC')
    % Get water content data (calculated, prepared, and sensor readings).
    gt.WC_Calculated = gt_data.("WC_Calculated (g_g)")(positions,:);
    gt.WC_Prepared = gt_data.("WC_Prepared (g_g)")(positions,:);
    gt.WC_Sensor = gt_data.("10HS mositure sensor (cm3_cm3)")(positions,:);

    % Generate text filenames based on the prepared water content data.
    txtfilename = arrayfun(@(x) sprintf('W%02d.txt', x), ...
                           gt.WC_Prepared*100, 'UniformOutput', false);

    % Convert to VWC 
    gt.WC_Calculated = gt_data.("WC_Calculated (g_g)")(positions, :) * ...
                       bulk_density;
    gt.WC_Prepared = gt_data.("WC_Prepared (g_g)")(positions, :) * ...
                     bulk_density;
elseif strcmp(lab_exptype, 'Nitrogen')
    % If the experiment type is 'Nitrogen', get the nitrogen-related data.
    gt.WC = gt_data.("WC_Prepared (g_g)")(positions, :);
    gt.Urea = gt_data.("Urea Added (mg)")(positions, :);
    gt.NO3 = gt_data.("NO3 (ppm)")(positions, :);
    gt.NH4 = gt_data.("NH4 (ppm)")(positions, :);
    gt.totN = gt_data.("Total N (%)")(positions, :);
    gt.O_NO3 = gt_data.("O_NO3 (ppm)")(positions, :);
    gt.O_NH4 = gt_data.("O_NH4 (ppm)")(positions, :);
    gt.O_totN = gt_data.("O_Total N (%)")(positions, :);

    % Generate text filenames based on both water content and urea levels.
    txtfilename = arrayfun(@(wc, urea) ...
                           sprintf('W%02dU%02d.txt', wc*100, urea), ...
                           gt.WC, gt.Urea, 'UniformOutput', false);

    gt.WC = gt_data.("WC_Prepared (g_g)")(positions, :) * bulk_density;
elseif strcmp(lab_exptype, 'WC_Bending')
    % Get water content data (calculated, prepared, and sensor readings).
    gt.WC_Calculated = gt_data.("WC_Calculated (g_g)")(positions,:);
    gt.WC_Prepared = gt_data.("WC_Prepared (g_g)")(positions,:);
    gt.Bending = gt_data.("Cable Bending Type")(positions,:);

    % Generate text filenames based on the prepared water content data.
    txtfilename = arrayfun(@(wc, bd) sprintf('W%02dB%d.txt', wc, bd), ...
                           gt.WC_Prepared*100, gt.Bending, ...
                           'UniformOutput', false);

    % Convert to VWC 
    gt.WC_Calculated = gt_data.("WC_Calculated (g_g)")(positions, :) * ...
                       bulk_density;
    gt.WC_Prepared = gt_data.("WC_Prepared (g_g)")(positions, :) * ...
                     bulk_density;

end

% Get the number of samples based on the number of generated filenames.
num_samples = length(txtfilename);

% Pre-allocate matrices to store the magnitude and phase data 
% (for all samples and frequencies).
mag = zeros(num_samples, fre_size);
phs = zeros(num_samples, fre_size);

% Loop through each sample to read the corresponding 
% magnitude and phase data.
for k = 1:length(txtfilename)
    % Convert each filename in the cell array to a character vector.
    current_file = char(txtfilename{k});  
    
    % Construct the full file path for the current file.
    txtpath = fullfile(mainpath, 'Lab', lab_exptype, lab_expnum, ...
                       lab_expcbtype, current_file);
    
    % Check if the file exists before reading.
    if isfile(txtpath)
        % Read the text file into a table.
        txt_data = readtable(txtpath);  
        
        % Store the magnitude and phase data in the pre-allocated matrices.
        mag(k,:) = txt_data{:,3};  % 3rd column corresponds to magnitude.
        phs(k,:) = txt_data{:,4};  % 4th column corresponds to phase.
    else
        % Display a warning if the file is missing.
        warning('File does not exist: %s', txtpath);  
    end
end

data = struct('mag', mag, 'phs', phs);

end
