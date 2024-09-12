clc
clear
close all

year = '24';
mainpath = 'C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Data\UG nodes';
results = access_all_field_data(year, mainpath);