clc
clear 
close all

mag_SC = [];
phs_SC = [];
mag_LC = [];
phs_LC = [];



% Specify the folder where the files live.
myFolder = 'Nitrogen\R2\SC'; 
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, 'W*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading -> %s\n', fullFileName);
  data = readtable(fullFileName);
  mag_SC = [mag_SC data{:,3}];
  phs_SC = [phs_SC data{:,4}];
end

% calculate back to ratio (dB) and absolute phase angle changes (0-180 degrees)
ratio_dB_SC = (mag_SC/4095*3.3/1.8-1.8)/0.06;
abs_phs_diff_SC = (phs_SC/4095*3.3/1.8-0.9)/(-0.01)+90;
abs_phs_diff_SC = abs_phs_diff_SC + abs(abs_phs_diff_SC);

% Specify the folder where the files live.
myFolder = 'Nitrogen\R2\LC'; 
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, 'W*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading -> %s\n', fullFileName);
  data = readtable(fullFileName);
  fre = data{:,2};
  mag_LC = [mag_LC data{:,3}];
  phs_LC = [phs_LC data{:,4}];
end

% calculate back to ratio (dB) and absolute phase angle changes (0-180 degrees)
ratio_dB_LC = (mag_LC/4095*3.3/1.8-1.8)/0.06;
abs_phs_diff_LC = (phs_LC/4095*3.3/1.8-0.9)/(-0.01)+90;
abs_phs_diff_LC = abs_phs_diff_LC + abs(abs_phs_diff_LC);

for i=1:length(fre)
    if i>=111
        fre(i)=fre(i)*1000;
    end
end
fre = fre*1000;

% Define specific line styles for W09, W18, W27
lineStyles = {'-', '--', '-.'}; % Different line styles for W09, W18, W27

% Custom color palette with distinct and diverse colors
customColors = [
    0.00, 0.45, 0.74;  % Blue
    0.85, 0.33, 0.10;  % Red
    0.93, 0.69, 0.13;  % Yellow
    0.49, 0.18, 0.56;  % Purple
    0.47, 0.67, 0.19;  % Green
    0.30, 0.75, 0.93;  % Cyan
    0.64, 0.08, 0.18;  % Dark Red
    0.50, 0.50, 0.50;  % Gray
    0.76, 0.54, 0.00;  % Orange
    0.78, 0.08, 0.52;  % Magenta
    0.19, 0.63, 0.33;  % Dark Green
    0.58, 0.40, 0.74   % Light Purple
];

% Ensure the color palette is large enough for all lines
numColors = size(customColors, 1);
numLines = max([size(mag_SC, 2), size(mag_LC, 2)]);

figure(1),
hold on
colorIndex_W09 = 1;
colorIndex_W18 = 1;
colorIndex_W27 = 1;
for i = 1:size(mag_SC, 2)
    if contains(theFiles(i).name, 'W09')
        semilogx(fre, ratio_dB_SC(:, i), 'LineStyle', lineStyles{1}, 'Color', customColors(mod(colorIndex_W09-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W09 = colorIndex_W09 + 1;
    elseif contains(theFiles(i).name, 'W18')
        semilogx(fre, ratio_dB_SC(:, i), 'LineStyle', lineStyles{2}, 'Color', customColors(mod(colorIndex_W18-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W18 = colorIndex_W18 + 1;
    elseif contains(theFiles(i).name, 'W27')
        semilogx(fre, ratio_dB_SC(:, i), 'LineStyle', lineStyles{3}, 'Color', customColors(mod(colorIndex_W27-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W27 = colorIndex_W27 + 1;
    end
end
set(gca,'XScale','log')  % Ensure X-axis is logarithmic
set(gca,'FontSize',15)
title('Short Cable (Magnitude)', 'Fontsize', 15);
xlabel('frequency (Hz)', 'Fontsize', 15);
ylabel('V_{probe}/V_{total} (dB)', 'Fontsize', 15);
legend('W09U06', 'W09U09', 'W09U12', 'W09U15', 'W09U18', 'W09U21', ...
       'W09U24', 'W09U27', 'W09U30', 'W09U36', 'W18U06', 'W18U09', ...
       'W18U12', 'W18U15', 'W18U18', 'W18U21', 'W18U24', 'W18U27', ...
       'W18U30', 'W18U36', 'W27U06', 'W27U09', 'W27U12', 'W27U15', ...
       'W27U18', 'W27U21', 'W27U24', 'W27U27', 'W27U30', 'W27U36', ...
       'Location','eastoutside', 'Fontsize', 15);
hold off

% % Set the figure size to a large size, for example 16x9 inches
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0 0 16 9]); % [left, bottom, width, height]
% 
% % Save the figure as a PNG with high resolution (e.g., 600 DPI)
% print('Short_Cable_Magnitude', '-dpng', '-r600');

figure(2),
hold on
colorIndex_W09 = 1;
colorIndex_W18 = 1;
colorIndex_W27 = 1;
for i = 1:size(abs_phs_diff_SC, 2)
    if contains(theFiles(i).name, 'W09')
        semilogx(fre, abs_phs_diff_SC(:, i), 'LineStyle', lineStyles{1}, 'Color', customColors(mod(colorIndex_W09-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W09 = colorIndex_W09 + 1;
    elseif contains(theFiles(i).name, 'W18')
        semilogx(fre, abs_phs_diff_SC(:, i), 'LineStyle', lineStyles{2}, 'Color', customColors(mod(colorIndex_W18-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W18 = colorIndex_W18 + 1;
    elseif contains(theFiles(i).name, 'W27')
        semilogx(fre, abs_phs_diff_SC(:, i), 'LineStyle', lineStyles{3}, 'Color', customColors(mod(colorIndex_W27-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W27 = colorIndex_W27 + 1;
    end
end
set(gca,'XScale','log')  % Ensure X-axis is logarithmic
set(gca,'FontSize',15)
title('Short Cable (Phase)', 'Fontsize', 15);
xlabel('frequency (Hz)', 'Fontsize', 15);
ylabel('Absolute Phase Difference (degrees)', 'Fontsize', 15);
legend('W09U06', 'W09U09', 'W09U12', 'W09U15', 'W09U18', 'W09U21', ...
       'W09U24', 'W09U27', 'W09U30', 'W09U36', 'W18U06', 'W18U09', ...
       'W18U12', 'W18U15', 'W18U18', 'W18U21', 'W18U24', 'W18U27', ...
       'W18U30', 'W18U36', 'W27U06', 'W27U09', 'W27U12', 'W27U15', ...
       'W27U18', 'W27U21', 'W27U24', 'W27U27', 'W27U30', 'W27U36', ...
       'Location','eastoutside', 'Fontsize', 15);
hold off
% % Set the figure size to a large size, for example 16x9 inches
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0 0 16 9]); % [left, bottom, width, height]
% 
% % Save the figure as a PNG with high resolution (e.g., 600 DPI)
% print('Short_Cable_Phase', '-dpng', '-r600');

figure(3),
hold on
colorIndex_W09 = 1;
colorIndex_W18 = 1;
colorIndex_W27 = 1;
for i = 1:size(mag_LC, 2)
    if contains(theFiles(i).name, 'W09')
        semilogx(fre, ratio_dB_LC(:, i), 'LineStyle', lineStyles{1}, 'Color', customColors(mod(colorIndex_W09-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W09 = colorIndex_W09 + 1;
    elseif contains(theFiles(i).name, 'W18')
        semilogx(fre, ratio_dB_LC(:, i), 'LineStyle', lineStyles{2}, 'Color', customColors(mod(colorIndex_W18-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W18 = colorIndex_W18 + 1;
    elseif contains(theFiles(i).name, 'W27')
        semilogx(fre, ratio_dB_LC(:, i), 'LineStyle', lineStyles{3}, 'Color', customColors(mod(colorIndex_W27-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W27 = colorIndex_W27 + 1;
    end
end
set(gca,'XScale','log')  % Ensure X-axis is logarithmic
set(gca,'FontSize',15)
title('Long Cable (Magnitude)', 'Fontsize', 15);
xlabel('frequency (Hz)', 'Fontsize', 15);
ylabel('V_{probe}/V_{total} (dB)', 'Fontsize', 15);
legend('W09U06', 'W09U09', 'W09U12', 'W09U15', 'W09U18', 'W09U21', ...
       'W09U24', 'W09U27', 'W09U30', 'W09U36', 'W18U06', 'W18U09', ...
       'W18U12', 'W18U15', 'W18U18', 'W18U21', 'W18U24', 'W18U27', ...
       'W18U30', 'W18U36', 'W27U06', 'W27U09', 'W27U12', 'W27U15', ...
       'W27U18', 'W27U21', 'W27U24', 'W27U27', 'W27U30', 'W27U36', ...
       'Location','eastoutside', 'Fontsize', 15);
hold off
% % Set the figure size to a large size, for example 16x9 inches
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0 0 16 9]); % [left, bottom, width, height]
% 
% % Save the figure as a PNG with high resolution (e.g., 600 DPI)
% print('Long_Cable_Magnitude', '-dpng', '-r600');


figure(4),
hold on
colorIndex_W09 = 1;
colorIndex_W18 = 1;
colorIndex_W27 = 1;
for i = 1:size(abs_phs_diff_LC, 2)
    if contains(theFiles(i).name, 'W09')
        semilogx(fre, abs_phs_diff_LC(:, i), 'LineStyle', lineStyles{1}, 'Color', customColors(mod(colorIndex_W09-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W09 = colorIndex_W09 + 1;
    elseif contains(theFiles(i).name, 'W18')
        semilogx(fre, abs_phs_diff_LC(:, i), 'LineStyle', lineStyles{2}, 'Color', customColors(mod(colorIndex_W18-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W18 = colorIndex_W18 + 1;
    elseif contains(theFiles(i).name, 'W27')
        semilogx(fre, abs_phs_diff_LC(:, i), 'LineStyle', lineStyles{3}, 'Color', customColors(mod(colorIndex_W27-1,numColors)+1, :), 'LineWidth', 2);
        colorIndex_W27 = colorIndex_W27 + 1;
    end
end
set(gca,'XScale','log')  % Ensure X-axis is logarithmic
set(gca,'FontSize',15)
title('Long Cable (Phase)', 'Fontsize', 15);
xlabel('frequency (Hz)', 'Fontsize', 15);
ylabel('Absolute Phase Difference (degrees)', 'Fontsize', 15);
legend('W09U06', 'W09U09', 'W09U12', 'W09U15', 'W09U18', 'W09U21', ...
       'W09U24', 'W09U27', 'W09U30', 'W09U36', 'W18U06', 'W18U09', ...
       'W18U12', 'W18U15', 'W18U18', 'W18U21', 'W18U24', 'W18U27', ...
       'W18U30', 'W18U36', 'W27U06', 'W27U09', 'W27U12', 'W27U15', ...
       'W27U18', 'W27U21', 'W27U24', 'W27U27', 'W27U30', 'W27U36', ...
       'Location','eastoutside', 'Fontsize', 15);
hold off
% % Set the figure size to a large size, for example 16x9 inches
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0 0 16 9]); % [left, bottom, width, height]
% 
% % Save the figure as a PNG with high resolution (e.g., 600 DPI)
% print('Long_Cable_Phase', '-dpng', '-r600');
