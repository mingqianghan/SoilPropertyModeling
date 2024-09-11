clc
clear
close all

% wc_gt_subpath = 'Lab\WC_Calibration.xlsx';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';
% 
% [mag, phs, gt] = load_lab_data(mainpath, lab_exptype, lab_expnum, lab_expcbtype, ...
%                    N_gt_subpath);
% 
% 
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';

% Define parameters
lab_exptype = 'Nitrogen';  

results = access_all_lab_data(mainpath, lab_exptype, N_gt_subpath);

fre = calculate_frequencies_Hz();