function S = process_metric(cfg, S, runtype)
%   Process outputs of machines

for i=1:numel(cfg.data.mod)
    m = cfg.data.mod{i}; % shorthand variable
    
    % Calculate similarity of weights
    if ismember(['simw' lower(m)], cfg.machine.metric)
        if strcmp(cfg.machine.name, 'spls')
            sim = num2cell(calc_stability({S.(['w' m])}, 'overlap', 'corrected'));
        else
            sim = num2cell(calc_stability({S.(['w' m])}, 'correlation'));
        end
        [S(:).(['simw' lower(m)])] = deal(sim{:});
    end
    
    % Calculate occurrence of variables
    if strcmp(runtype, 'gridsearch') && ismember(['freq' lower(m)], cfg.machine.metric) ...
            && strcmp(cfg.machine.name, 'spls')
        freq = num2cell(sum(cat(2, S.(['w' m]))~=0, 2) / numel(S(1).(['w' m])));
        S.(['freqw' lower(m)]) = deal(freq{:});
    end
    
    % Transpose weights for main models
    if strcmp(runtype, 'main')
        for j=1:size(S)
            S(j).(['w' m]) = S(j).(['w' m])';
        end
    end
end

% Remove fields from output
if ~strcmp(runtype, 'main')
    S = rmfield(S, {'wX' 'wY'});
end