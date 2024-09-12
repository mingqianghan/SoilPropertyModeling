clc
clear
close all

year = '24';
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data\UG nodes';
plot_name = 'LP';    % EP (Early Planting) or LP (Late Planting)
subplot_name = 'WN'; % WN (With Nitrogen) or ON (Without Nitrogen)
Cable_Type = 'LC';   % LC (Long Cable) or SC (Short Cable)

[data, gt] = load_field_data(year, mainpath, plot_name, ...
                             subplot_name, Cable_Type);