clc
clear
close all
VWC_feature_file= "C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Models\SoilAnalysis\scripts\features_mannual\VIP_frequencies_VWC_Combined_new.xlsx";
Predictors = {'Mag', 'Phs', 'MaP'};
fs_param.name  = 'SPA';
split_ratio1 =  0.5;   % adjust for different validation and test ratio
split_ratio2 = 0;

rg_model = 'ANN';
OptParams = true;

SPA_th1 = 4;   
SPA_th2 = 10; 

feature_mag = readtable(VWC_feature_file, 'Sheet','Mag');
feature_mag = sortrows(feature_mag,"Count","descend");
idxMagHigh = feature_mag.Count>SPA_th2;
idxMagMedium = feature_mag.Count>SPA_th1 & feature_mag.Count<=SPA_th2;
idxMagLow = feature_mag.Count <= SPA_th1;

highMagValues = feature_mag.Value(idxMagHigh);
mediumMagValues = feature_mag.Value(idxMagMedium);
lowMagValues = feature_mag.Value(idxMagLow);

feature_phs = readtable(VWC_feature_file, 'Sheet','Phs');
feature_phs = sortrows(feature_phs,"Count","descend");
idxPhsHigh = feature_phs.Count>SPA_th2;
idxPhsMedium = feature_phs.Count>SPA_th1 & feature_phs.Count<=SPA_th2;
idxPhsLow = feature_phs.Count <= SPA_th1;

highPhsValues = feature_phs.Value(idxPhsHigh);
mediumPhsValues = feature_phs.Value(idxPhsMedium);
lowPhsValues = feature_phs.Value(idxPhsLow);


vals = [feature_mag.Value;  feature_phs.Value + 1101];
cnts = [feature_mag.Count;  feature_phs.Count];
feature_map = table( vals, cnts, 'VariableNames', {'Value','Count'} );
feature_map = sortrows(feature_map,"Count","descend");
idxMaPHigh = feature_map.Count>SPA_th2;
idxMaPMedium = feature_map.Count>SPA_th1 & feature_map.Count<=SPA_th2;
idxMaPLow = feature_map.Count <= SPA_th1;

highMaPValues = feature_map.Value(idxMaPHigh);
mediumMaPValues = feature_map.Value(idxMaPMedium);
lowMaPValues = feature_map.Value(idxMaPLow);


% lab data for training 
mainpath = 'data';
WC_gt_subpath = 'Lab\WC_Calibration.xlsx';
lab_data_W_exp = access_all_lab_data(mainpath, 'WC', WC_gt_subpath);

matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), lab_data_W_exp);
lab_data_W_exp = lab_data_W_exp(matches);

N_gt_subpath = 'Lab\Nitrogen_Calibration.xlsx';
lab_data_N_exp = access_all_lab_data(mainpath, 'Nitrogen', N_gt_subpath);

matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), lab_data_N_exp);
lab_data_N_exp = lab_data_N_exp(matches);

% field data for validation and test
year = '24';
mainpath = 'data\UG nodes';
field_data = access_all_field_data(year, mainpath);

output_folderPath = fullfile('VIP_results_new', 'VWC_50_rng1_new');
if ~exist(output_folderPath, 'dir')
    mkdir(output_folderPath);
end


for i = 1:length(Predictors)
    p = Predictors{i};

    [data_x_W_exp, data_y_W_exp, label_W] = extract_and_clean_data(lab_data_W_exp, 'lab', p, 'WC_Calculated');
    [data_x_N_exp, data_y_N_exp, label_N] = extract_and_clean_data(lab_data_N_exp, 'lab', p, 'WC');

    label_W = categorical( strcat( string(label_W), "_W" ) );
    label_N = categorical( strcat( string(label_N), "_N" ) );

    train_x = [data_x_W_exp; data_x_N_exp];
    train_y = [data_y_W_exp; data_y_N_exp];
    train_label = [label_W; label_N];

    matches = arrayfun(@(x) strcmp(x.Cabletype, 'LC'), field_data);
    [data_x_field, data_y_field, label] = extract_and_clean_data(field_data(matches), 'field', p, 'VWC');
    [val_x, val_y, val_label, test_x, test_y, test_label, ~, ~, ~] = split_data(data_x_field, data_y_field, split_ratio1, split_ratio2, label, true);

    if strcmp(p, 'Mag')

        train_x_t1 = train_x(:, lowMagValues);
        fs_param.max_var = length(lowMagValues);
        score_idx1 = feature_selection(train_x_t1, train_y, fs_param);

        train_x_t2 = train_x(:, mediumMagValues);
        fs_param.max_var = length(mediumMagValues);
        score_idx2 = feature_selection(train_x_t2, train_y, fs_param);

        fea_seq = [highMagValues; mediumMagValues(score_idx2); lowMagValues(score_idx1)];

    elseif strcmp(p, 'Phs')
        train_x_t1 = train_x(:, lowPhsValues);
        fs_param.max_var = length(lowPhsValues);
        score_idx1 = feature_selection(train_x_t1, train_y, fs_param);

        train_x_t2 = train_x(:, mediumPhsValues);
        fs_param.max_var = length(mediumPhsValues);
        score_idx2 = feature_selection(train_x_t2, train_y, fs_param);

        fea_seq = [highPhsValues; mediumPhsValues(score_idx2); lowPhsValues(score_idx1)];
    else
        train_x_t1 = train_x(:, lowMaPValues);
        fs_param.max_var = length(lowMaPValues);
        score_idx1 = feature_selection(train_x_t1, train_y, fs_param);

        train_x_t2 = train_x(:, mediumMaPValues);
        fs_param.max_var = length(mediumMaPValues);
        score_idx2 = feature_selection(train_x_t2, train_y, fs_param);

        fea_seq = [highMaPValues; mediumMaPValues(score_idx2); lowMaPValues(score_idx1)];
    end

    fprintf('\n-- Running model using (%s)--\n', p);

    model_folderPath = fullfile('VIP_results_new', 'VWC_50_rng1_new', p);
    if ~exist(model_folderPath, 'dir')
        mkdir(model_folderPath);
    end

    nFeat = numel(fea_seq);
    %–– preallocate arrays for logging ––
    FeatureCount = (1:nFeat)';
    Train_R2   = nan(nFeat,1);
    Train_RMSE = nan(nFeat,1);
    Train_MAE  = nan(nFeat,1);
    Val_R2     = nan(nFeat,1);
    Val_RMSE   = nan(nFeat,1);
    Val_MAE    = nan(nFeat,1);
    Test_R2    = nan(nFeat,1);
    Test_RMSE  = nan(nFeat,1);
    Test_MAE   = nan(nFeat,1);
    SelectedArr = repmat("", nFeat, 1);


    best_val_rmse = inf;
    best_train_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
    best_val_scores = struct('rmse', inf, 'mae', inf, 'rsquare', -inf);
    best_mdl = [];


    for j = 1:nFeat
        Selected = 'N';

        train_x_c = train_x(:, fea_seq(1:j));
        val_x_c = val_x(:, fea_seq(1:j));
        test_x_c = test_x(:, fea_seq(1:j));
        [mdl, train_scores, val_scores] = train_and_evaluate_model(rg_model, train_x_c, train_y, val_x_c, val_y, length(fea_seq), OptParams);

        %–– saveraw model ––
        modelFile = fullfile(model_folderPath, sprintf('model_%s_%03d.mat', p, j));
        save(modelFile, 'mdl');


        % Prediction
        yPred_test = predict(mdl, test_x_c);
        test_scores = model_evaluation(yPred_test, test_y);

        if val_scores.rmse < best_val_rmse && ...
                train_scores.rsquare >= val_scores.rsquare
            best_val_rmse = val_scores.rmse;
            best_train_scores = train_scores;
            best_val_scores = val_scores;
            best_mdl.mdl = mdl;
            best_mdl.feature = fea_seq(1:j);
            best_mdl.idx = j;
            best_mdl.train_scores = train_scores;
            best_mdl.val_scores = val_scores;
            best_mdl.test_scores = test_scores;
            Selected = 'Y';
        end

        fprintf([...
        'Progress: %d/%d | ' ...
        'Train: R2=%.2f, RMSE=%.2f, MAE=%.2f | ' ...
        'Val:   R2=%.2f, RMSE=%.2f, MAE=%.2f | ' ...
        'Test:  R2=%.2f, RMSE=%.2f, MAE=%.2f | ' ...
        'Selected: %s\n'], ...
        j, nFeat, ...
        train_scores.rsquare, train_scores.rmse, train_scores.mae, ...
        val_scores.rsquare,   val_scores.rmse,   val_scores.mae, ...
        test_scores.rsquare,  test_scores.rmse,  test_scores.mae, ...
        Selected ...
    );

        %–– record this iteration’s metrics ––
        FeatureCount(j) = j;
        Train_R2(j)     = train_scores.rsquare;
        Train_RMSE(j)   = train_scores.rmse;
        Train_MAE(j)    = train_scores.mae;
        Val_R2(j)       = val_scores.rsquare;
        Val_RMSE(j)     = val_scores.rmse;
        Val_MAE(j)      = val_scores.mae;
        Test_R2(j)      = test_scores.rsquare;
        Test_RMSE(j)    = test_scores.rmse;
        Test_MAE(j)     = test_scores.mae;
        SelectedArr(j)  = Selected;
    end

    fprintf('\n-- Selected best result (%s)--\n', p);
    fprintf([...
        'Index: %d| ' ...
        'Train: R2=%.2f, RMSE=%.2f, MAE=%.2f | ' ...
        'Val:   R2=%.2f, RMSE=%.2f, MAE=%.2f | ' ...
        'Test:  R2=%.2f, RMSE=%.2f, MAE=%.2f \n'], ...
        best_mdl.idx, ...
        best_mdl.train_scores.rsquare, best_mdl.train_scores.rmse, best_mdl.train_scores.mae, ...
        best_mdl.val_scores.rsquare,   best_mdl.val_scores.rmse,   best_mdl.val_scores.mae, ...
        best_mdl.test_scores.rsquare,  best_mdl.test_scores.rmse,  best_mdl.test_scores.mae);

    %–– assemble into a table and write to Excel ––
    T = table( ...
        FeatureCount, Train_R2, Train_RMSE, Train_MAE, ...
        Val_R2,       Val_RMSE,   Val_MAE, ...
        Test_R2,      Test_RMSE,  Test_MAE, ...
        SelectedArr, ...
        'VariableNames', { ...
        'FeatureCount', 'Train_R2', 'Train_RMSE', 'Train_MAE', ...
        'Val_R2',       'Val_RMSE',   'Val_MAE',   ...
        'Test_R2',      'Test_RMSE',  'Test_MAE',  ...
        'Selected' } ...
        );
    outFile = fullfile(output_folderPath, sprintf('progress_%s.xlsx', p));
    writetable(T, outFile);

    % save best model
    bestFile = fullfile(output_folderPath, sprintf('best_model_%s.mat', p));
    save(bestFile, 'best_mdl');

    yPred_train = predict(best_mdl.mdl, train_x(:, best_mdl.feature));
    yPred_val = predict(best_mdl.mdl, val_x(:, best_mdl.feature));
    yPred_test = predict(best_mdl.mdl, test_x(:, best_mdl.feature));

    nT = numel(train_y);
    nV = numel(val_y);
    nE = numel(test_y);

    GroundTruth  = [train_y;      val_y;      test_y];
    Predictions  = [yPred_train;  yPred_val;  yPred_test];
    ClassLabel   = [train_label;  val_label;  test_label];
    SubsetClass  = [ repmat("train", nT,1);
                     repmat("val",   nV,1);
                     repmat("test",  nE,1) ];

    T = table( GroundTruth, Predictions, ClassLabel, SubsetClass, ...
               'VariableNames', {'ground_truth','pred','class_label','subset_class'} );

    outFile = fullfile(output_folderPath, sprintf('predictions_%s.xlsx', p));
    writetable(T, outFile);

end


