function [r_square, rmse, mae] = model_evaluation(ypred, ytrue)
    % Calculate residuals
    residuals = ytrue - ypred;
    
    % Calculate R-squared (coefficient of determination)
    ss_res = sum(residuals .^ 2);  % Sum of squares of residuals
    ss_tot = sum((ytrue - mean(ytrue)) .^ 2);  % Total sum of squares
    r_square = 1 - (ss_res / ss_tot);
    
    % Calculate RMSE (Root Mean Squared Error)
    rmse = sqrt(mean(residuals .^ 2));
    
    % Calculate MAE (Mean Absolute Error)
    mae = mean(abs(residuals));
end
