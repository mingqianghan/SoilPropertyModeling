function load_data(mainpath, lab_exptype, lab_expnum, lab_expcbtype, ...
                   gt_subpath)

% Inputs:
%   mainpath      - (string) The main directory path where data is stored.
%   lab_exptype   - (string) The experiment type, either 'Nitrogen' or 'WC' (Water Content).
%   lab_expnum    - (string) The experiment repeat number, such as 'R1', 'R2', 'R3', or 'All' for all repeats.
%   lab_expcbtype - (string) The cable type, either 'LC' (Long Cable) or 'SC' (Short Cable).


gt_path = fullfile(mainpath, gt_subpath);


gt_data = readtable(gt_path, 'VariableNamingRule', 'preserve', ...
                    'Sheet', lab_expnum);
positions = find(strcmp(data.("Cable Type"), lab_expcbtype));



% Construct the full path based on the provided inputs
txtfilepath = fullfile(mainpath, 'Lab', lab_exptype, ...
                    lab_expnum, lab_expcbtype);
WC_gt_path = fullfile(mainpath, 'Lab', 'WC_Calibration.xlsx');
N_gt_path = fullfile(mainpath, 'Lab', 'WC_Calibration.xlsx');



end