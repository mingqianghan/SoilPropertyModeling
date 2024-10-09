function [mdl, val_rsquare, val_rmse, train_rsquare] = train_and_evaluate_model(rg_model, train_x, train_y, val_x, val_y, n_fea)
    % Common train and predict variables
    num_train = size(train_x, 1);
    num_val = size(val_x, 1);

    switch rg_model
        case 'LR'
            % Train Linear Regression model
            mdl = fitlm(train_x, train_y);
            yPred_train = predict(mdl, train_x);
            yPred_val = predict(mdl, val_x);
            [train_rsquare, ~, ~] = model_evaluation(yPred_train, train_y);
            [val_rsquare, val_rmse, ~] = model_evaluation(yPred_val, val_y);
        case 'Dtree'
            hiddenLayerSizes = [3, 5, 7];
            lambdas = [0.01, 0.001];

            val_rmse = inf;

            for numNeurons = hiddenLayerSizes
                for lambda = lambdas

                    mdl_new = fitrnet(train_x, train_y, ...
                        'LayerSizes', numNeurons, ...
                        'Activations', 'relu', ...
                        'Standardize', true, ...
                        'Lambda', lambda);
                    yPred_train = predict(mdl_new, train_x);
                    yPred_val = predict(mdl_new, val_x);
                    [train_rsquare_new, ~, ~] = model_evaluation(yPred_train, train_y);
                    [val_rsquare_new, val_rmse_new, ~] = model_evaluation(yPred_val, val_y);

                    % Update the best PLS model
                    if val_rmse_new < val_rmse && train_rsquare_new >= val_rsquare_new
                        val_rmse = val_rmse_new;
                        train_rsquare = train_rsquare_new;
                        val_rsquare = val_rsquare_new;
                        mdl = mdl_new;
                    end
                end
            end
            
        case 'SVM'
            boxConstraintRange = [0.1, 1, 10];
            epsilonRange = [0.01, 0.1, 1];
            kernelFunctions = {'linear', 'gaussian'};

            val_rmse = inf;
            for boxConstraint = boxConstraintRange
                for epsilon = epsilonRange
                    for kernel = kernelFunctions
                        % Train the SVM model with current parameters
                        svm_mdl = fitrsvm(train_x, train_y, ...
                            'KernelFunction', kernel{1}, ...
                            'BoxConstraint', boxConstraint, ...
                            'Epsilon', epsilon, ...
                            'KernelScale', 'auto');
                        yPred_train = predict(svm_mdl, train_x);
                        yPred_val = predict(svm_mdl, val_x);
                        [train_rsquare_new, ~, ~] = model_evaluation(yPred_train, train_y);
                        [val_rsquare_new, val_rmse_new, ~] = model_evaluation(yPred_val, val_y);

                        % Update the best PLS model
                        if val_rmse_new < val_rmse && train_rsquare_new >= val_rsquare_new
                            val_rmse = val_rmse_new;
                            train_rsquare = train_rsquare_new;
                            val_rsquare = val_rsquare_new;
                            mdl = svm_mdl;
                        end

                    end
                end
            end
          
        case 'PLS'
            % Handle PLS model
            mdl = [];
            val_rmse = inf; train_rsquare = -inf; val_rsquare = -inf;
            for n_comp = 1:n_fea
                % Train and evaluate PLS model for n_comp components
                [~,~,~,~,BETA] = plsregress(train_x, train_y, n_comp);
                yPred_train = [ones(num_train, 1), train_x] * BETA;
                yPred_val = [ones(num_val, 1), val_x] * BETA;

                % Evaluate PLS model
                [train_rsquare_comp, ~, ~] = model_evaluation(yPred_train, train_y);
                [val_rsquare_comp, val_rmse_comp, ~] = model_evaluation(yPred_val, val_y);

                % Update the best PLS model
                if val_rmse_comp < val_rmse && train_rsquare_comp >= val_rsquare_comp
                    val_rmse = val_rmse_comp;
                    train_rsquare = train_rsquare_comp;
                    val_rsquare = val_rsquare_comp;
                    mdl.BETA = BETA;  % Store coefficients
                    mdl.n_comp = n_comp;
                end
            end
            return  % Exit for PLS, since it's fully handled
        otherwise
            error('Unsupported model type');
    end
end