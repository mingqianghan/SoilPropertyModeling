function [data, gt, data_size] = load_field_data(year, mainpath, ...
    plot_name, ...
    subplot_name, Cable_Type)
% -------------------------------------------------------------------------
% This function reads field data, including sensor data (magnitude, phase,
% etc.) and ground truth data (soil moisture, nitrogen levels, etc.) based
% on the specified plot, subplot, and cable type. The function processes
% raw data files, normalizes the values, and structures the data for
% further analysis.
%
% Parameters:
%   year         - String specifying the year of data collection.
%   mainpath     - String containing the main directory path where
%                         the data is located.
%   plot_name    - String specifying the name of the plot for which
%                         data is being loaded.
%   subplot_name - String specifying the subplot name.
%   Cable_Type   - String ('LC' or 'SC') specifying the type of cable
%                         used for data collection.
%
% Outputs:
%   data - Struct containing magnitude, phase, date, and possibly other
%                 sensor data (parity, RSSI, SNR) based on cable type.
%   gt   - Struct containing ground truth data including
%                 soil moisture (VWC), nitrogen levels (NO3, NH4),
%                 and total nitrogen (totN).
%   data_size - double containing the number of measurements
%                      in the data structure.
%
% Author: Mingqiang Han
% Date: 09-12-24
% -------------------------------------------------------------------------

% Fixed size of frequency points
fre_size = 1110;

% Construct the ground truth file name based on plot and subplot
gt_file_name = [plot_name, '_', subplot_name, '.xlsx'];
gt_full_path = fullfile(mainpath, plot_name, gt_file_name);

% Check if the ground truth file exists before attempting to read
if ~isfile(gt_full_path)
    error('Ground truth file not found: %s', gt_full_path);
end

% Read the ground truth data from the specified Excel sheet
gt_data = readtable(gt_full_path, 'VariableNamingRule', ...
    'preserve', 'Sheet', 'Data');

% Identify relevant data indices based on cable type
if strcmp(Cable_Type, 'LC')
    data_idx = contains(gt_data.("Data Availability"), 'L');
    txtfilepath = [subplot_name, '_LC'];
elseif strcmp(Cable_Type, 'SC')
    data_idx = contains(gt_data.("Data Availability"), 'S');
    txtfilepath = [subplot_name, '_SC'];
else
    error('Invalid Cable_Type. Use "LC" or "SC".');
end

% Extract ground truth data
gt.VWC = gt_data.("VWC (cm^3/cm^3)")(data_idx);
gt.NO3 = gt_data.("NO3 (ppm)")(data_idx);
gt.NH4 = gt_data.("NH4 (ppm)")(data_idx);
gt.totN = gt_data.("Total N (%)")(data_idx);

% Full path to the raw data files
full_txtfilepath = fullfile(mainpath, plot_name, txtfilepath);

% Preallocate arrays based on the data size
data_label = gt_data.("Sample Label")(data_idx);
data_size = length(data_label);

% Initialize arrays for storing the data
mag = zeros(data_size, fre_size);
phs = zeros(data_size, fre_size);
date = NaT(data_size, 1);

if strcmp(Cable_Type, 'SC')
    parity = zeros(data_size, fre_size);
    rssi = zeros(data_size, fre_size);
    snr = zeros(data_size, fre_size);
end

% Loop through each data sample and load the corresponding raw data
for i = 1:data_size
    % Extract month and day from the sample label
    parts = strsplit(data_label{i}, '_');
    month = sprintf('%02d', str2double(parts{1}));
    day = sprintf('%02d', str2double(parts{2}));

    date(i) = datetime(sprintf('20%s-%02d-%02d', year, ...
                       str2double(parts{1}), str2double(parts{2})));

    % Generate file pattern based on cable type and date
    if strcmp(Cable_Type, 'LC')
        filePattern = fullfile(full_txtfilepath, ...
            ['s_', year, month, day, '*.txt']);
    else
        filePattern = fullfile(full_txtfilepath, ...
            ['d*', year, '_', month, '_', day, '*.csv']);
    end

    % Find and load the file
    fileStruct = dir(filePattern);
    if isempty(fileStruct)
        warning('No data file found for %s_%s_%s', year, month, day);
        continue;
    end
    fullFileName = fullfile(full_txtfilepath, fileStruct(1).name);

    % Read data from the file based on cable type
    if strcmp(Cable_Type, 'LC')
        txtfile = readtable(fullFileName, ...
            'VariableNamingRule', 'preserve');
        mag(i,:) = normalize_magnitude(txtfile{:,3});
        phs(i,:) = normalize_phase(txtfile{:,4});
    else
        csvtable = readtable(fullFileName, ...
            'VariableNamingRule', 'preserve');
        mag(i,:) = normalize_magnitude(csvtable.("mag (dig)"));
        phs(i,:) = normalize_phase(csvtable.("phs (dig)"));
        parity(i,:) = csvtable.("parity");
        rssi(i,:) = csvtable.("RSSI(dBm)");
        snr(i,:) = csvtable.("SNR (dB)");
    end
end

% Create a data structure with loaded values, based on cable type
if strcmp(Cable_Type, 'LC')
    data = struct('mag', mag, 'phs', phs, 'date', date);
else
    data = struct('mag', mag, 'phs', phs, 'date', date, ...
                  'parity', parity, 'rssi', rssi, 'snr', snr);
end

end

% Helper function to normalize magnitude
function mag = normalize_magnitude(mag)
mag = (mag / 4095 * 3.3 / 1.8 - 1.8) / 0.06;
end

% Helper function to normalize phase
function phs = normalize_phase(phs)
phs = (phs / 4095 * 3.3 / 1.8 - 0.9) / (-0.01) + 90;
phs = phs + abs(min(phs));
end
