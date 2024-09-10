function [mag, phs, gt] = load_lab_data(mainpath, lab_exptype, lab_expnum, lab_expcbtype, ...
                   gt_subpath)

% Inputs:
%   mainpath      - (string) The main directory path where data is stored.
%   lab_exptype   - (string) The experiment type, either 'Nitrogen' or 'WC' (Water Content).
%   lab_expnum    - (string) The experiment repeat number, such as 'R1', 'R2', 'R3', or 'All' for all repeats.
%   lab_expcbtype - (string) The cable type, either 'LC' (Long Cable) or 'SC' (Short Cable).


gt_path = fullfile(mainpath, gt_subpath);


gt_data = readtable(gt_path, 'VariableNamingRule', 'preserve', ...
                    'Sheet', lab_expnum);



positions = find(strcmp(gt_data.("Cable Type"), lab_expcbtype));


GWC_prep = gt_data.("WC_Prepared (g_g)")(positions, :);
txtfilename = arrayfun(@(x) sprintf('W%02d.txt', x), GWC_prep*100, 'UniformOutput', false);

fre_size = 1110;
num_samples = length(txtfilename);

mag = zeros(num_samples, fre_size);
phs = zeros(num_samples, fre_size);

for k = 1:length(txtfilename)
    % Convert each filename in the cell array to a character vector
    current_file = char(txtfilename{k});  
    
    % Construct the full file path for the current file
    txtpath = fullfile(mainpath, 'Lab', lab_exptype, lab_expnum, lab_expcbtype, current_file);
    
    % Check if the file exists before reading
    if isfile(txtpath)
        txt_data = readtable(txtpath);  % Read the file into a table
        mag(k,:) = txt_data{:,3};
        phs(k,:) = txt_data{:,4};
    else
        warning('File does not exist: %s', txtpath);  % Display a warning if the file is missing
    end
end


gt = [gt_data.("WC_Calculated (g_g)")(positions, :) 
       gt_data.("WC_Prepared (g_g)")(positions, :) 
       gt_data.("10HS mositure sensor (cm3_cm3)")(positions, :)];

end