clc; clear; close all

rsq_th = 0.5;
main_path = "C:\Users\mingqiang\OneDrive - Kansas State University\K-state Research\Soil sensor\Models\SoilAnalysis";


folders = { ...
  "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R2\NO3",         {'_'},         true;
  "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R3\NO3",         {'_'},         true;
  "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R2_R3\NO3",         {'_'},         true; 
  "results_final\Field_inter_sensor\NO3_80_no_outliers",   {'EP_ON','EP_WN','LP_WN','LP_ON'},         false;
  "results_final\Field_accross_sensor\NO3_80_no_outliers", {'__'},                    false;
  "results_final\Field_accross_sensor\NO3_no_outliers (no EP_WN)", {'__'},                    false
};

% folders = { ...
%   "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R2\NH4",         {'_'},         true;
%   "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R3\NH4",         {'_'},         true;
%   "results_final\Lab_N_inter_repeat_NH4NO3_Urea_R2_R3\NH4",         {'_'},         true; 
%   "results_final\Field_inter_sensor\NH4_80_no_outliers",   {'EP_ON','EP_WN','LP_WN','LP_ON'},         false;
%   "results_final\Field_accross_sensor\NH4_80_no_outliers", {'__'},                    false;
%   "results_final\Field_accross_sensor\NH4_no_outliers (no EP_WN)", {'__'},                    false
% };


methods    = {'CARS','MRMR','SPA'};
Predictors = {'Mag','Phs','MaP'};

% init data struct
data = struct();
for mi = 1:numel(methods)
  m = methods{mi};
  for pi = 1:numel(Predictors)
    p = Predictors{pi};
    data.(m).(p) = [];
  end
end

fprintf("Aggregating f_idx across all folders:\n\n");
for rf = 1:size(folders,1)
  sub   = folders{rf,1};
  exps  = folders{rf,2};
  useLC = folders{rf,3};
  fullpath = fullfile(main_path, sub);
  fprintf("Scanning %s (LC? %d)\n", sub, useLC);

  for mi = 1:numel(methods)
    m = methods{mi};
    for pi = 1:numel(Predictors)
      pd = Predictors{pi};
      for ei = 1:numel(exps)
        ex = exps{ei};

        % choose pattern based on useLC flag
        if useLC
          patt = sprintf("*%s*%s*LC*%s*.mat", m, pd, ex);
        else
          patt = sprintf("*%s*%s*%s*.mat",  m, pd, ex);
        end

        files = dir(fullfile(fullpath, patt));
        if isempty(files)
          warning("   no match for %s in %s", patt, sub);
          continue
        end

        S    = load(fullfile(fullpath, files(1).name));
        vals = S.mdl.f_idx(:);
        rsq  = S.mdl.val_scores.rsquare;

        if rsq >= rsq_th
          vals_new = filter_long_runs(vals, 5);
          fprintf("   [%s] %s (Val R2=%.2f): +%d\n", m, files(1).name, rsq, numel(vals_new));
          data.(m).(pd) = [ data.(m).(pd); vals_new ];
        else
          fprintf("   [%s] %s (Val R2=%.2f): skipped\n", m, files(1).name, rsq);
        end
      end
    end
  end
  fprintf("\n");
end

% summary
fprintf("Final counts:\n");
for mi = 1:numel(methods)
  m = methods{mi};
  fprintf("--- %s ---\n", m);
  for pi = 1:numel(Predictors)
    p = Predictors{pi};
    fprintf("  %s: %d elements\n", p, numel(data.(m).(p)));
  end
end
data_new = distributeMaPtoMagPhs(data, methods);

% Initialize empty
combined.mag = [];
combined.phs = [];

% Loop over each method, concatenate
for k = 1:numel(methods)
    m = methods{k};
    combined.mag = [ combined.mag; data_new.(m).Mag(:) ];
    combined.phs = [ combined.phs; data_new.(m).Phs(:) ];
end

freqData = countValueFrequencies(data_new, methods, {'Mag','Phs'});


% 1) Mag frequencies
magV = combined.mag(:);          % ensure column
[magVals, ~, ic_mag] = unique(magV);      % distinct values + indices
magCounts = accumarray(ic_mag, 1);        % count each
freqMag = table(magVals, magCounts, ...   % build table
    'VariableNames', {'Value','Count'});

% 2) Phs frequencies
phsV = combined.phs(:);
[phsVals, ~, ic_phs] = unique(phsV);
phsCounts = accumarray(ic_phs, 1);
freqPhs = table(phsVals, phsCounts, ...
    'VariableNames', {'Value','Count'});

% Display or export
% disp('Mag frequencies:');
% disp(freqMag);
% 
% disp('Phs frequencies:');
% disp(freqPhs);

freqCombined.mag = freqMag;
freqCombined.phs = freqPhs;






function v_filtered = filter_long_runs(v, minLen)
    % v          - input column vector of integers
    % minLen     - minimum run length to trigger filtering 
    % v_filtered - output vector with only the first element of any run > minLen
    
    if isempty(v)
        v_filtered = v;
        return;
    end
    
    % find boundaries where the run of +1 breaks
    breaks = [0; find(diff(v)~=1); numel(v)];
    
    keep = true(size(v));  % logical mask of elements to keep
    for k = 1:length(breaks)-1
        startIdx = breaks(k) + 1;
        endIdx   = breaks(k+1);
        runLength = endIdx - breaks(k);
        
        if runLength > minLen
            % drop everything except the first in this run
            dropIdx = (startIdx+1):endIdx;
            keep(dropIdx) = false;
        end
    end
    
    v_filtered = v(keep);
end


function freqData = countValueFrequencies(data, methods, predictors)
    % Preallocate output struct
    freqData = struct();

    for mi = 1:numel(methods)
        m = methods{mi};
        for pi = 1:numel(predictors)
            p = predictors{pi};

            v = data.(m).(p);  % your numeric vector

            if isempty(v)
                % empty table if no data
                freqData.(m).(p) = table([], [], ...
                    'VariableNames', {'Value','Count'});
            else
                % find unique values and map each element to an index
                [vals, ~, ic] = unique(v);
                % count how many times each index occurs
                counts = accumarray(ic, 1);
                % store as a table
                freqData.(m).(p) = table(vals, counts, ...
                    'VariableNames', {'Value','Count'});
            end
        end
    end
end


function data = distributeMaPtoMagPhs(data, methods)
    for mi = 1:numel(methods)
        m = methods{mi};

        % 1) extract and clear MaP
        mapVals = data.(m).MaP;
        data.(m).MaP = [];

        if isempty(mapVals)
            continue;
        end

        % 2) [1,1101] mag
        idxLow = mapVals >= 1 & mapVals <= 1101;
        if any(idxLow)
            data.(m).Mag = [ data.(m).Mag; mapVals(idxLow) ];
        end

        % 3) (1101,2202] → Phs (after subtracting 1110)
        idxHigh = mapVals > 1101 & mapVals <= 2202;
        if any(idxHigh)
            adjusted = mapVals(idxHigh) - 1101;
            data.(m).Phs = [ data.(m).Phs; adjusted ];
        end

        % 4) report any out‐of‐range
        idxOut = ~(idxLow | idxHigh);
        if any(idxOut)
            warning('[%s] %d MaP values outside 1–2200 were ignored.', ...
                    m, sum(idxOut));
        end
        data.(m) = rmfield(data.(m), 'MaP');
    end
end