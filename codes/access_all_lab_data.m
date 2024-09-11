function results = access_all_lab_data(mainpath, lab_exptype, gt_subpath)
% Author: Mingqiang
% Date: September 10, 2024
%
% Description:
% This function processes data from laboratory experiments related to either 
% nitrogen or water content (WC). It loops through all combinations of 
% experiment repeat numbers and cable types, loads the corresponding data 
% using the `load_lab_data` function, and stores the results in a structure 
% array. The structure array contains the experiment number, cable type, 
% magnitude data, phase data, and ground truth data for each combination.
%
% Inputs:
%   mainpath    - (string) The main directory path where the experiment data is stored.
%   lab_exptype - (string) The experiment type, either 'Nitrogen' or 'WC' 
%                          (Water Content).
%   gt_subpath  - (string) The subdirectory path to the ground truth file
%
% Outputs:
%   results - (struct) A structure array containing the following fields for 
%                      each combination of experiment number and cable type:
%       - expnum     : Experiment repeat number (e.g., 'R1', 'R2', 'R3').
%       - cabletype  : Cable type used in the experiment (e.g., 'SC', 'LC').
%       - mag        : Magnitude response data for each sample at different frequencies.
%       - phs        : Phase response data for each sample at different frequencies.
%       - gt         : Ground truth data (e.g., water content, nitrogen measurements).

% Define the list of experiment repeat numbers and cable types
lab_expnum = {'R1', 'R2', 'R3'};     % Experiment numbers (repeats)
lab_expcbtype = {'SC', 'LC'};        % Cable types ('SC' for Short Cable, 'LC' for Long Cable)

% Pre-allocate a structure array to store the results
results = struct('expnum', {}, 'cabletype', {}, 'mag', {}, 'phs', {}, 'gt', {});

% Initialize an index to track the current entry in the structure array
idx = 1;

% Loop through each experiment repeat number (R1, R2, R3)
for i = 1:length(lab_expnum)
    % Loop through each cable type (SC, LC)
    for j = 1:length(lab_expcbtype)
        % Extract the current experiment repeat number and cable type
        current_expnum = lab_expnum{i};        % Current experiment repeat number (e.g., 'R1')
        current_expcbtype = lab_expcbtype{j};  % Current cable type (e.g., 'SC')
        
        % Display the current experiment combination being processed
        fprintf('Processing experiment %s with cable type %s...\n', current_expnum, current_expcbtype);
        
        % Call the load_lab_data function to load magnitude, phase, and ground truth data
        [mag, phs, gt] = load_lab_data(mainpath, lab_exptype, current_expnum, ...
                                       current_expcbtype, gt_subpath);
        
        % Store the results for the current combination in the structure array
        results(idx).expnum = current_expnum;       % Store experiment repeat number
        results(idx).cabletype = current_expcbtype; % Store cable type
        results(idx).mag = mag;                     % Store magnitude data
        results(idx).phs = phs;                     % Store phase data
        results(idx).gt = gt;                       % Store ground truth data
        
        % Increment the index for the next entry in the structure array
        idx = idx + 1;
    end
end
end