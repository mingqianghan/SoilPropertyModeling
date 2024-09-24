function write_data = check_model(results_file_path, ...
                                  full_results_path, ...
                                  model_name)
% -------------------------------------------------------------------------
% This function checks if the model exists in the results file, 
% and appends the model if it's new.
%
% This function performs the following:
% 1. Checks if the specified directory exists. 
%    If not, it creates the directory.
% 2. Checks if the results file exists. 
%    If not, it creates an empty results table.
% 3. Checks if the specified model is already recorded in the results file.
%    If the model is not found, it appends the model name to 
%    the results file.
%
% INPUTS:
%   - results_file_path : Path to the directory where results are stored.
%   - full_results_path : Full path to the results file 
%                         (including the file name).
%   - model_name        : Name of the model to check in the results file.
%
% OUTPUT:
%   - write_data        : Boolean value. 
%                         Returns true if the model is new and should be
%                         written to the results file. 
%                         Returns false if the model already exists 
%                         in the file.
%
% Author: Mingqiang Han
% Date: 09-20-24
% -------------------------------------------------------------------------

% Ensure the results directory exists
if ~isfolder(results_file_path)
    % If directory does not exist, create it
    mkdir(results_file_path);
end

% Check if the results file exists
if isfile(full_results_path)
    % If the file exists, read the table of existing models
    existing_models = readtable(full_results_path, ...
        'ReadVariableNames', true, ...
        'Delimiter', ',', 'TreatAsEmpty', '_', ...
        'TextType', 'string');
else
    % If the file does not exist, 
    % create an empty table with a 'Models' column
    existing_models = table('Size', [0, 1], ...
        'VariableTypes', {'string'}, ...
        'VariableNames', {'Models'});
    % Write the empty table to the file
    writetable(existing_models, full_results_path);
end

% Check if the specified model is already in the file
write_data = ~ismember(model_name, existing_models.Models);

% If the model is new, append it to the results file
if write_data
    writematrix(model_name, full_results_path, 'WriteMode', 'append');
end
end
