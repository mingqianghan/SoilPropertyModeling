function stat = calculate_data_statistics(data)
% Function to calculate basic statistics for a given dataset
% Input:
%   data - A numeric vector
% Output:
%   stat - A structure containing calculated statistics

% Check if input is valid
if isempty(data)
    error('Input data is empty. Please provide a valid dataset.');
elseif ~isnumeric(data)
    error('Input data must be numeric.');
end

% Remove NaN values
data = data(~isnan(data));

% Calculate statistics
stat.mean = mean(data);
stat.std = std(data);       % Standard deviation
stat.min = min(data);       % Minimum value
stat.max = max(data);       % Maximum value
stat.median = median(data);
stat.validcount = numel(data);

% Calculate quartiles
stat.q1 = quantile(data, 0.25);  % 1st Quartile (25th percentile)
stat.q2 = quantile(data, 0.50);  % 2nd Quartile (50th percentile, which is the median)
stat.q3 = quantile(data, 0.75);  % 3rd Quartile (75th percentile)
stat.q4 = quantile(data, 1.00);  % 4th Quartile (100th percentile, which is the max)

% Display results
% disp('Data Statistics:');
% disp(stat);
end
