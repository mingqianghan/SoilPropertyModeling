function load_data(mainpath, lab_exptype, lab_expnum, lab_expcbtype)


% Construct the full path based on the provided inputs
txtfilepath = fullfile(mainpath, 'Lab', lab_exptype, ...
                    lab_expnum, lab_expcbtype);
WC_gt_path = fullfile(mainpath, 'Lab', 'WC_Calibration.xlsx');
N_gt_path = fullfile(mainpath, 'Lab', 'WC_Calibration.xlsx');



end