% clc
% clear
% close all
% 
% mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
% wc_gt_subpath = 'Lab\WC_Calibration.xlsx';
% N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';
% 
% wc_gt_path = fullfile(mainpath, wc_gt_subpath);
% N_gt_path =fullfile(mainpath, N_gt_subpath);
% 
% disp(wc_gt_path)
% disp(N_gt_path)
% 
% fre_size = 1110;
% 
% i = 1:fre_size;  % Create a vector for i
% 
% % Preallocate fre array
% fre = zeros(1, fre_size);
% 
% % Use logical indexing to assign values
% fre(i <= 10) = 100 * i(i <= 10);
% fre(i > 10 & i <= 110) = 10.^(0.03 * (i(i > 10 & i <= 110) - 10)) * 1000;
% fre(i > 110) = 10.^(0.003 * (i(i > 110) - 110)) * 1000000;
% 
% gt_data = readtable(wc_gt_path, 'VariableNamingRule', 'preserve', 'Sheet', 'R3');
% positions = find(strcmp(gt_data.("Cable Type"), 'SC'));
% 
% GWC_prep = gt_data.("WC_Prepared (g_g)")(positions, :);
% txtfilename = arrayfun(@(x) sprintf('W%02d.txt', x), GWC_prep*100, 'UniformOutput', false);
% 
% txtpath = fullfile(mainpath, 'Lab', 'WC', 'R3', 'SC', txtfilename);
% 
% txtpath = length(txtpath);
% 
% mag = zeros(txtpath, fre_size);
% phs = zeros(txtpath, fre_size);
% 
% for k = 1:length(txtfilename)
%     % Convert each filename in the cell array to a character vector
%     current_file = char(txtfilename{k});  
% 
%     % Construct the full file path for the current file
%     txtpath = fullfile(mainpath, 'Lab', 'WC', 'R3', 'SC', current_file);
% 
%     % Check if the file exists before reading
%     if isfile(txtpath)
%         txt_data = readtable(txtpath);  % Read the file into a table
%         mag(k,:) = txt_data{:,3};
%         phs(k,:) = txt_data{:,4};
%     else
%         warning('File does not exist: %s', txtpath);  % Display a warning if the file is missing
%     end
% end
% 
% 
% GWC = [gt_data.("WC_Calculated (g_g)")(positions, :) 
%        gt_data.("WC_Prepared (g_g)")(positions, :) 
%        gt_data.("10HS mositure sensor (cm3_cm3)")(positions, :)];
% 
% 
% 

clc
clear
close all

mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
lab_exptype = 'WC';
lab_expnum = 'R3';
lab_expcbtype = 'SC';

wc_gt_subpath = 'Lab\WC_Calibration.xlsx';
N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';

[mag, phs, gt] = load_data(mainpath, lab_exptype, lab_expnum, lab_expcbtype, ...
                   wc_gt_subpath);