clc
clear
close all

mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
wc_gt_subpath = 'Lab\WC_Calibration.xlsx';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

wc_gt_path = fullfile(mainpath, wc_gt_subpath);
N_gt_path =fullfile(mainpath, N_gt_subpath);

disp(wc_gt_path)
disp(N_gt_path)

data = readtable(wc_gt_path, 'Sheet', 'R3');



