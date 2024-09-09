clc
clear 
close all

mag_SC = [];
phs_SC = [];
mag_LC = [];
phs_LC = [];

% Predefined color set (16 distinct colors)
colorSet = [
    [0 0.4470 0.7410];    % Blue
    [0.8500 0.3250 0.0980]; % Red
    [0.9290 0.6940 0.1250]; % Yellow
    [0.4940 0.1840 0.5560]; % Purple
    [0.4660 0.6740 0.1880]; % Green
    [0.3010 0.7450 0.9330]; % Cyan
    [0.6350 0.0780 0.1840]; % Dark Red
    [0.75 0 0.75];         % Magenta
    [0.25 0.25 0.25];      % Dark Gray
    [0.8 0.4 0];           % Orange
    [0 0.75 0.75];         % Turquoise
    [0.75 0.75 0];         % Olive
    [0.5 0.5 0.5];         % Gray
    [0.75 0 0];            % Brown
    [0 0.5 0];             % Dark Green
    [0 0 0.5];             % Navy
];

% Specify the folder where the files live.
myFolder = 'WC\R2\SC'; 
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
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  data = readtable(fullFileName);
  mag_SC = [mag_SC data{:,3}];
  phs_SC = [phs_SC data{:,4}];
end

% calculate back to ratio (dB) and absolute phase angle changes (0-180 degrees)
ratio_dB_SC = (mag_SC/4095*3.3/1.8-1.8)/0.06;
abs_phs_diff_SC = (phs_SC/4095*3.3/1.8-0.9)/(-0.01)+90;
abs_phs_diff_SC = abs_phs_diff_SC + abs(abs_phs_diff_SC);

% Specify the folder where the files live.
myFolder = 'WC\R2\LC';
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
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  data = readtable(fullFileName);
  fre = data{:,2};
  mag_LC = [mag_LC data{:,3}];
  phs_LC = [phs_LC data{:,4}];
end

% calculate back to ratio (dB) and absolute phase angle changes (0-180 degrees)
ratio_dB_LC = (mag_LC/4095*3.3/1.8-1.8)/0.06;
abs_phs_diff_LC = (phs_LC/4095*3.3/1.8-0.9)/(-0.01)+90;
abs_phs_diff_LC = abs_phs_diff_LC + abs(abs_phs_diff_LC);

for i = 1:length(fre)
    if i >= 111
        fre(i) = fre(i) * 1000;
    end
end
fre = fre * 1000;

% Short Cable (Magnitude)
figure(1);
semilogx(fre, ratio_dB_SC, 'LineWidth', 2);
ax = gca;
ax.ColorOrder = colorSet;
set(gca, 'FontSize', 20);
title('Short Cable (Magnitude)', 'FontSize', 20);
legend('0%', '3%', '6%', '9%', '12%', '15%', '18%', ...
       '21%', '24%', '27%', '30%', '33%', '36%', '39%', '42%', '45%', ...
       'Location', 'eastoutside', 'FontSize', 20);
xlabel('frequency (Hz)', 'FontSize', 20);
ylabel(' V_{probe}/V_{total} (dB)', 'FontSize', 20);
set(gcf, 'Position', [100, 100, 1200, 800]);  % Set the size of the figure
print(gcf, 'Short_Cable_Magnitude.png', '-dpng', '-r300');  % Save as PNG with 300 DPI

% Short Cable (Phase)
figure(2);
semilogx(fre, abs_phs_diff_SC, 'LineWidth', 2);
ax = gca;
ax.ColorOrder = colorSet;
set(gca, 'FontSize', 20);
title('Short Cable (Phase)', 'FontSize', 20);
legend('0%', '3%', '6%', '9%', '12%', '15%', '18%', ...
       '21%', '24%', '27%', '30%', '33%', '36%', '39%', '42%', '45%', ...
       'Location', 'eastoutside', 'FontSize', 20);
xlabel('frequency (Hz)', 'FontSize', 20);
ylabel(' Absolute Phase Difference (degrees)', 'FontSize', 20);
set(gcf, 'Position', [100, 100, 1200, 800]);  % Set the size of the figure
print(gcf, 'Short_Cable_Phase.png', '-dpng', '-r300');  % Save as PNG with 300 DPI

% Long Cable (Magnitude)
figure(3);
semilogx(fre, ratio_dB_LC, 'LineWidth', 2);
ax = gca;
ax.ColorOrder = colorSet;
set(gca, 'FontSize', 20);
title('Long Cable (Magnitude)', 'FontSize', 20);
legend('0%', '3%', '6%', '9%', '12%', '15%', '18%', ...
       '21%', '24%', '27%', '30%', '33%', '36%', '39%', ...
       '42%', '45%', ...
       'Location', 'eastoutside', 'FontSize', 20);
xlabel('frequency (Hz)', 'FontSize', 20);
ylabel(' V_{probe}/V_{total} (dB)', 'FontSize', 20);
set(gcf, 'Position', [100, 100, 1200, 800]);  % Set the size of the figure
print(gcf, 'Long_Cable_Magnitude.png', '-dpng', '-r300');  % Save as PNG with 300 DPI

% Long Cable (Phase)
figure(4);
semilogx(fre, abs_phs_diff_LC, 'LineWidth', 2);
ax = gca;
ax.ColorOrder = colorSet;
set(gca, 'FontSize', 20);
title('Long Cable (Phase)', 'FontSize', 20);
legend('0%', '3%', '6%', '9%', '12%', '15%', '18%', ...
       '21%', '24%', '27%', '30%', '33%', '36%', '39%', ...
       '42%', '45%', ...
       'Location', 'eastoutside', 'FontSize', 20);
xlabel('frequency (Hz)', 'FontSize', 20);
ylabel(' Absolute Phase Difference (degrees)', 'FontSize', 20);
set(gcf, 'Position', [100, 100, 1200, 800]);  % Set the size of the figure
print(gcf, 'Long_Cable_Phase.png', '-dpng', '-r300');  % Save as PNG with 300 DPI
