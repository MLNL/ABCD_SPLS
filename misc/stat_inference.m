function [res, metric, permdist] = stat_inference(res)

% Quit if no permutations needed
if res.stat.nperm == 0
    return
end
        
%----- Loading

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load permuted metrics
if strcmp(cfg.frwork.name, 'permutation') % first effect for maximum statistics
    S_perm = loadmat_struct(res, fullfile(res.dir.frwork, 'perm', 'level1', 'allperm.mat'));

else % current effect
    S_perm = loadmat_struct(res, fullfile(res.dir.perm, 'allperm.mat'));
end

% Load true metrics
S = loadmat_struct(res, fullfile(res.dir.res, 'model.mat'));

%----- Hypothesis testing for each split

if strcmp(cfg.frwork.name, 'permutation') || ~strcmp(cfg.stat.split.crit, 'none')
    % Calculate p-value
    res.stat.split.pval = zeros(res.frwork.split.nall, 1);
    for i=1:res.frwork.split.nall
        res.stat.split.pval(i) = calc_pval(S_perm.(cfg.stat.split.crit)(i,:), ...
            S.(cfg.stat.split.crit)(i), 'max');
    end
    metric = S.(cfg.stat.split.crit);
    permdist = S_perm.(cfg.stat.split.crit);
end

%----- Hypothesis testing across splits

% Indexes of splits
isplit = res.frwork.split.all;
res.frwork.split.sig = []; % significant splits

if strcmp(cfg.frwork.name, 'permutation') || ~strcmp(cfg.stat.split.crit, 'none')
    % Bonferroni correction and selecting significant splits
    split_sig = find(res.stat.split.pval < (0.05 / res.frwork.split.nall))';
    
    if ~isempty(split_sig)
        % Save significant splits and their p-values
        if isfield(cfg.defl, 'split') && strcmp(cfg.defl.split, 'significant')
            isplit = split_sig;
        end
        res.frwork.split.sig = res.frwork.split.all(isplit);
    else
        isplit = [];
    end
end

if ~strcmp(cfg.frwork.name, 'permutation') && ~strcmp(cfg.stat.overall.crit, 'none')
    switch cfg.stat.overall.crit
        case 'correl+simwxy'
            metric = calc_stability_distance(nanmean(S.correl(isplit)), ...
                nanmean([S.simwx(isplit) S.simwy(isplit)]));
            permdist = calc_stability_distance(nanmean(S_perm.correl(isplit,:), 1), ...
                nanmean([S_perm.simwx(isplit,:) S_perm.simwy(isplit,:)], 1));
            
        case 'correl+simwx+simwy'
            metric = calc_stability_distance(nanmean(S.correl(isplit)), ...
                nanmean(S.simwx(isplit)), nanmean(S.simwy(isplit)));
            permdist = calc_stability_distance(nanmean(S_perm.correl(isplit,:), 1), ...
                nanmean(S_perm.simwx(isplit,:), 1), nanmean(S_perm.simwy(isplit,:), 1));
            
        otherwise
            metric = nanmean(S.correl(isplit));
            permdist = nanmean(S_perm.correl(isplit,:), 1);
    end
    
    if ~strcmp(cfg.stat.split.crit, 'none')
        % Additional statistics for stability (+generalizability)
        if ~isempty(split_sig) && ~isempty(strfind(cfg.stat.overall.crit, 'sim'))
            res.stat.overall.pval = calc_pval(permdist, metric, 'min');
        end
        
    else
        % Statistics only across data splits
        res.stat.overall.pval = calc_pval(permdist, metric, 'max');
        if strcmp(cfg.defl.split, 'all') && res.stat.overall.pval < 0.05
            % Mark all splits as significant
            res.frwork.split.sig = res.frwork.split.all;
        end
    end
end



% --------------------------- Private functions ---------------------------

function pval = calc_pval(perm_dist, true_val, flag)

if strcmp(flag, 'max')
    pval = (1 + nansum(perm_dist >= true_val)) / (numel(perm_dist) - ...
        numel(find(isnan(perm_dist))) + 1);
    
elseif strcmp(flag, 'min')
    pval = (1 + nansum(perm_dist <= true_val)) / (numel(perm_dist) - ...
        numel(find(isnan(perm_dist))) + 1);
end