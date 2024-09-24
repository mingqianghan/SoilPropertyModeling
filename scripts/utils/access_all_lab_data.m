function results = access_all_lab_data(mainpath, lab_exptype, gt_subpath)
% -------------------------------------------------------------------------
% This function processes data from laboratory experiments related to 
% either nitrogen or water content (WC). It loops through all combinations
% of experiment repeat numbers and cable types, loads the corresponding 
% data using the 'load_lab_data' function, and stores the results in 
% a structure array. The structure array contains the experiment number, 
% cable type, magnitude data, phase data, and ground truth data for each 
% combination.
%
% Inputs:
%   mainpath    - (string) The main directory path where the experiment 
%                          data is stored.
%   lab_exptype - (string) The experiment type, either 'Nitrogen' or 'WC' 
%                          (Water Content).
%   gt_subpath  - (string) The subdirectory path to the ground truth file
%
% Outputs:
%   results - (struct) A structure array containing the following fields 
%                      for each combination of experiment number and cable 
%                      type:
%       - expnum     : Experiment repeat number (R1', 'R2', 'R3').
%       - cabletype  : Cable type used in the experiment ('SC', 'LC').
%       - mag        : Magnitude response data for each sample 
%       - phs        : Phase response data for each sample
%       - gt         : Ground truth data 
%                      (water content, nitrogen measurements).
% Author: Mingqiang Han
% Date: 09-10-24
% -------------------------------------------------------------------------

% Define the list of experiment repeat numbers and cable types
lab_expnum = {'R1', 'R2', 'R3'};     % Experiment numbers 
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
        [data, gt, data_size] = load_lab_data(mainpath, ...
                                                  lab_exptype, ...
                                                  current_expnum, ...
                                                  current_expcbtype, ...
                                                  gt_subpath);
        % Display the number of samples found for this configuration
        fprintf('Found %3d samples.\n', data_size);
        
        % Store the results for the current combination in the structure array
        results(idx).expnum = current_expnum;       % Store exp. number
        results(idx).Cabletype = current_expcbtype; % Store cable type
        results(idx).Numsamples = data_size;        % Number of samples found
        results(idx).data = data;                   % Lab data
        results(idx).gt = gt;                       % Store gt. data
        
        % Increment the index for the next entry in the structure array
        idx = idx + 1;
    end
end
end