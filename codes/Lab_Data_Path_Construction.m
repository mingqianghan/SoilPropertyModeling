function datapath = Lab_Data_Path_Construction(mainpath, lab_exptype, ...
                                               lab_expnum, lab_expcbtype)
%
% Description:
%   This function constructs and returns the complete path to the lab 
%   data folder based on the input parameters, including the main 
%   directory path, experiment type, repeat number, and cable type. 
%   The function handles different values for these parameters to create 
%   the correct folder structure.
%
% Inputs:
%   mainpath      - (string) The main directory path where data is stored.
%   lab_exptype   - (string) The experiment type, either 'Nitrogen' or 'WC' (Water Content).
%   lab_expnum    - (string) The experiment repeat number, such as 'R1', 'R2', 'R3', or 'All' for all repeats.
%   lab_expcbtype - (string) The cable type, either 'LC' (Long Cable) or 'SC' (Short Cable).
%
% Output:
%   datapath      - (string) The complete path to the lab data folder specified by the inputs.
%
% Example:
%   mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data';
%   lab_exptype = 'Nitrogen';
%   lab_expnum = 'R1';
%   lab_expcbtype = 'LC';
%   datapath = Lab_Data_Path_Construction(mainpath, lab_exptype, lab_expnum, lab_expcbtype);
%   % The resulting datapath would be:
%   % 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data\Lab\Nitrogen\R1\LC'
%
% Author:
%   Mingqiang (9/9/2024)
%

% Construct the full path based on the provided inputs
datapath = fullfile(mainpath, 'Lab', lab_exptype, lab_expnum, lab_expcbtype);

end