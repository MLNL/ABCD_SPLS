function [param, S, bestid] = get_hyperparam(res, opt)

% Load cfg
if isfield(res.dir, 'frwork')
    cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');
else
    cfg = res;
end

% Number of hyperparameter levels
p = cfg.machine.param.name; % shorthand variable
num = zeros(1, numel(p));
for i=1:numel(p)
    num(i) = numel(cfg.machine.param.(p{i}));
end

% Compute design for hyperparameter combinations
if strcmp(cfg.machine.param.type, 'factorial')
    design = fullfact(num);
elseif strcmp(cfg.machine.param.type, 'matched')
    design = repmat(1:num(1), numel(p), 1)';
end
        
switch opt
    case 'default'
        % Assign hyperparameters
        for i=1:size(design, 1)
            for j=1:size(design, 2)
                param(i).(p{j}) = cfg.machine.param.(p{j})(design(i,j));
            end
        end
        
    case 'grid'
        % Load default params
        param = get_hyperparam(res, 'default');
        nparams = numel(param);
        
        % Load compiled grid search file and format data
        if exist_file(cfg, fullfile(res.dir.grid, 'allgrid.mat'))
            S = loadmat_struct(res, fullfile(res.dir.grid, 'allgrid.mat'));
            for i=1:numel(cfg.machine.metric)
               S.(cfg.machine.metric{i}) = reshape(S.(cfg.machine.metric{i}), ...
                   res.frwork.split.nall, nparams, []); 
            end
        else
            error('allgrid.mat not available');
        end

        % Calculate mean metric across subsamples
        fields = fieldnames(S);
        for i=1:numel(fields)
            S.(fields{i}) = real(nanmean(S.(fields{i}), 3));
        end
        
        % Find best hyperparameter                                          % deal with multiple values!!!
        bestid = zeros(1, res.frwork.split.nall);
        switch cfg.machine.param.crit
            case 'correl+simwx+simwy' % minimum distance
                for i=1:res.frwork.split.nall
                    [minval, bestid(i)] = min(calc_stability_distance(S.correl(i,:), ...
                        S.simwx(i,:), S.simwy(i,:)));
                end
                
            case 'correl+simwxy' % minimum distance
                for i=1:res.frwork.split.nall
                    [minval, bestid(i)] = min(calc_stability_distance(S.correl(i,:), ...
                        nanmean([S.simwx(i,:); S.simwy(i,:)], 1)));
                end
                
            case 'correl' % maximum test correlation
                mx_crr = max(S.(cfg.machine.param.crit), [], 2);
                for i=1:res.frwork.split.nall
                    id = find(S.(cfg.machine.param.crit)(i,:) == mx_crr(i), 1); % sparsest solution if multiple values
                    bestid(i) = id;
                end
        end
        param = param(bestid);
end
