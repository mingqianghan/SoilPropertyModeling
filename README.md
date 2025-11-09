# 🌱 Soil Property Modeling

This repository contains **MATLAB code for variable selection and prediction models** used for soil property modeling. The project focuses on analyzing soil data, selecting key variables, and building prediction models for soil properties using various statistical and machine learning techniques.

## 🔍 Overview

The code provides:

- Variable selection methods: CARS, MRMR, SPA  
- Prediction models: neural networks (used for final analysis); other models such as linear regression and SVM are available but not used for the final analysis  
- Scripts for preprocessing and analyzing soil property datasets  
- Applications for soil moisture and nitrogen prediction

The workflow includes **two stages**:  

1. **Stage 1:** Use multiple datasets from lab and field experiments for variable selection.  
2. **Stage 2:** Use information from Stage 1 for soil property estimation and testing on field data.

## 📂 Folders

- `scripts/VIPfeatures` — run Stage 2 models and obtain final results  
- `scripts/data_preprocessing` — dataset splitting and outlier removal  
- `scripts/feature_selection` — implement feature selection methods  
- `scripts/feature_mannual` — Implement models with manually refined spectral variables 
- `scripts/modeling` — train models and evaluate results  
- `scripts/tests` — train and test different datasets (run Stage 1 from here)  
- `scripts/utils` — miscellaneous code for loading data, evaluation metrics, etc.  
- `scripts/visualization` — generate figures and visualizations
