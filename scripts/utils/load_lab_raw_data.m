function [data, gt, num_samples] = load_lab_raw_data(mainpath, ...
                                                     lab_exptype, ...
                                                     lab_expnum, ...
                                                     lab_expcbtype, ...
                                                     gt_subpath)
% -------------------------------------------------------------------------
% The 'load_lab_data' function reads laboratory experimental data related 
% to either nitrogen or water content (WC) experiments. It loads the ground 
% truth data for the specified experiment type and retrieves the 
% corresponding magnitude and phase responses of the dielectric properties 
% from text files. The function handles different experiment repeat numbers 
% and cable types used in the laboratory setup, and returns the magnitude, 
% phase, and ground truth data in structured arrays.
%
% Inputs:
%   mainpath      - (string) The main directory path where data is stored.
%   lab_exptype   - (string) The experiment type, either 'Nitrogen' or 
%                            'WC' (Water Content).
%   lab_expnum    - (string) The experiment repeat number, such as 'R1',
%                            'R2', or 'R3'.
%   lab_expcbtype - (string) The cable type, either 'LC' (Long Cable) or 
%                            'SC' (Short Cable).
%   gt_subpath    - (string) Subdirectory path for ground truth data.
%
% Outputs:
%   mag - (matrix) Magnitude data for each sample at different frequencies.
%   phs - (matrix) Phase data for each sample at different frequencies.
%   gt  - (struct) Ground truth data related to water content or nitrogen 
%                  levels, depending on the experiment type.
%   num_samples - (double) the number of measurements 
%                          in the data structure.
%
% Author: Mingqiang Han
% Date: 09-10-24
% -------------------------------------------------------------------------

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

        % mag(k,:) = (mag(k,:)/4095*3.3/1.8-1.8)/0.06;
        % phs(k,:) = (phs(k,:)/4095*3.3/1.8-0.9)/(-0.01)+90;
        % phs(k,:) = phs(k,:) + abs(min(phs(k,:)));

    else
        % Display a warning if the file is missing.
        warning('File does not exist: %s', txtpath);  
    end
end

data = struct('mag', mag, 'phs', phs);

end
