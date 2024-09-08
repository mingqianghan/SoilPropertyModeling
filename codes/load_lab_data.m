function [fre, mag, phs] = load_lab_data(filepath)
mag = [];
phs = [];

% Specify the folder where the files live.
mainPath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data\';
DataPath = [mainPath filepath];
% DataPath = [mainPath 'Lab\WC\R2\LC'];
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(DataPath)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', DataPath);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(DataPath, 'W*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(DataPath, baseFileName);
  fprintf(1, 'Now reading -> %s\n', fullFileName);
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  data = readtable(fullFileName);
  mag = [mag data{:,3}];
  phs = [phs data{:,4}];
end

fre = data{:,2};
fre(111:end) = fre(111:end) * 1000;
fre = fre*1000;     % in Hz
end

% code update 1
