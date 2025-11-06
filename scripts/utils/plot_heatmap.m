function plot_heatmap(filepath, fs_method, rg_model, CableType)
% -------------------------------------------------------------------------
%   This function generates heatmaps showing the mean R-squared values 
%   from training and validation data across various feature selection 
%   methods and regression models.
%
% Inputs:
%   filepath: Path to directory containing performance CSV files
%   fs_method: Cell array of feature selection methods 
%              (e.g., {'MRMR', 'PLS_VIP', 'PCA'})
%   rg_model:  Cell array of regression models 
%              (e.g., {'LR', 'PLS', 'SVM', 'ANN'})
%   CableType: String that defines the filter criteria for selecting rows 
%              in the CSV files (e.g., 'SC' for specific cables)
%
% Outputs:
%   Heatmaps displaying the R-squared mean values for training and 
%            validation.
%
% Author: Mingqiang Han
% Date: 10-10-24
% -------------------------------------------------------------------------

% Initialize empty matrices to store mean R-squared values
train_mean_rsquare = zeros(length(rg_model), length(fs_method)); 
val_mean_rsquare = zeros(length(rg_model), length(fs_method));  

% Loop through each feature selection method and regression model combination
for col = 1:length(fs_method)
    for row = 1:length(rg_model)
        % Construct the filename based on models
        model_name = strcat(fs_method{col}, '_', ...
                            rg_model{row}, '_performance.csv');
        fullfilepath = fullfile(filepath, model_name); 
        
        % Read the CSV file containing performance metrics
        metrics_data = readtable(fullfilepath);
        
        % Find rows in the table where the "Label" column 
        % contains the CableType string
        idx = contains(metrics_data.Label, CableType);
        
        % Calculate the mean R-squared for training and validation data 
        % and store in matrices
        train_mean_rsquare(row, col) = mean(metrics_data.Train_R2(idx));  
        val_mean_rsquare(row, col) = mean(metrics_data.Val_R2(idx));      
    end
end

% Replace underscores with hyphens in feature selection method names 
% for better display
for i = 1:length(fs_method)
    fs_method{i} = strrep(fs_method{i}, '_', '-');
end

fontSize = 14;
cellfontsize = 12;
% Create a 1x2 tiled layout for heatmaps
figure('Position', [400 400 700 320]);
t = tiledlayout(1, 2, 'TileSpacing', 'compact');

% Plot heatmap for training R-squared values
nexttile;
h1 = heatmap(fs_method, rg_model, train_mean_rsquare);  
h1.CellLabelFormat = '%.2f';                           
h1.FontSize = cellfontsize;                                
title('Training');               
h1.ColorLimits = [0 1];                                

% Plot heatmap for validation R-squared values
nexttile;
h2 = heatmap(fs_method, rg_model, val_mean_rsquare);    
h2.CellLabelFormat = '%.2f';                          
h2.FontSize = cellfontsize;                              
title('Validation');             
h2.ColorLimits = [0 1];                     

% Set the color scheme to 'jet' for the figure
colormap(jet);

% Add common x-label and y-label for both heatmaps with specified font size
xlabel(t, 'Feature Selection Method', 'FontSize', fontSize);
ylabel(t, 'Regression Model', 'FontSize', fontSize);

% Add an overall title for the heatmaps based on the CableType
title(t, CableType, 'FontSize', fontSize, 'Interpreter','none');
end
