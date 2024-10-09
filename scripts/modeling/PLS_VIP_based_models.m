function [scores_out, score_idx_out, fea_out, comp_out, BETA_out, best_rsquare] = ...
         PLS_VIP_based_models(train_x, train_y, val_x, val_y, max_fea, rg_model)

ncomp = size(train_x, 1);

for cur_ncomp = 1:ncomp-1
    [XL,YL,XS,~,~,~,~,stats] = plsregress(train_x, train_y, cur_ncomp);
    % Calculate normalized PLS weights
    W0 = bsxfun(@rdivide,stats.W,sqrt(sum(stats.W.^2,1)));
    % Calculate the product of summed squares of XS and YL
    sumSq = sum(XS.^2,1).*sum(YL.^2,1);

    % Calculate VIP scores for NCOMP components
    vipScores = sqrt(size(XL,1) * sum(bsxfun(@times,sumSq,W0.^2),2) ./ sum(sumSq,2));

    [scores, score_idx] = sort(vipScores, 'descend');

    best_rsquare = -inf;
    best_rmse = inf;

    if strcmp(rg_model, 'LR')

    elseif strcmp(rg_model, 'SVM')

    elseif strcmp(rg_model, 'PLS')
        for n_fea = 1:max_fea
            for n_comp = 1:n_fea-1
                if n_comp <= ncomp-1
                    trainVIP_x = train_x(:,score_idx(1:n_fea));
                    valVIP_x = val_x(:,score_idx(1:n_fea));

                    [~,~,~,~,BETA,~,~,~] = plsregress(trainVIP_x, train_y, n_comp);

                    yPred_train = [ones(size(trainVIP_x,1),1) trainVIP_x]*BETA;
                    [train_rsquare, ~, ~] = model_evaluation(yPred_train, train_y);

                    yPred_val = [ones(size(valVIP_x,1),1) valVIP_x]*BETA;
                    [val_rsquare, val_rmse, ~] = model_evaluation(yPred_val, val_y);

                    if val_rmse < best_rmse && train_rsquare >= val_rsquare
                        scores_out = scores;
                        score_idx_out = score_idx;
                        fea_out = n_fea;
                        comp_out = n_comp;
                        best_rsquare = val_rsquare;
                        best_rmse = val_rmse;
                        BETA_out = BETA;
                    end

                 end
             end
         end
    end
end



end