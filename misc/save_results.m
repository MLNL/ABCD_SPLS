function res = save_results(res)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load true metrics
S = loadmat_struct(res, fullfile(res.dir.res, 'model.mat'));

% Compute distance metric
if isfield(cfg, 'defl')
    switch cfg.defl.crit
        case 'correl+simwxy'
            distance = calc_stability_distance(S.correl, nanmean([S.simwx S.simwy], 2));
            
        case 'correl+simwx+simwy'
            distance = calc_stability_distance(S.correl, S.simwx, S.simwy);
    end
end

% Save res
if ~isfield(cfg.stat, 'split')
    % No significance testing
    save_res_neg(res);
    
elseif strcmp(cfg.frwork.name, 'permutation') || ~strcmp(cfg.stat.split.crit, 'none')
    if isfield(res.frwork.split, 'sig') && ~isempty(res.frwork.split.sig) ...
            && ~strcmp(cfg.stat.overall.crit, 'none') && res.stat.overall.pval < 0.05
        % Significant both within and across splits
        save_res_pos(res, distance, {'min'});
        
    else
        % Significant omnibus hypothesis or skip statistical test
        switch cfg.defl.crit
            case 'correl'
                save_res_pos(res, S.correl, {'max'});
                
            case 'pval+correl'
                save_res_pos(res, [res.stat.split.pval S.correl], {'min' 'max'});
                
            case {'correl+simwxy' 'correl+simwx+simwy'}
                save_res_pos(res, distance, {'min'});
                
            case 'none'
                save_res_pos(res);
        end
    end
    
elseif strcmp(cfg.stat.split.crit, 'none') ...
        && ~strcmp(cfg.stat.overall.crit, 'none') && res.stat.overall.pval < 0.05
    % Significant only across data splits
    save_res_pos(res, S.(cfg.stat.overall.crit), {'max'}, res.stat.overall.pval);
       
else
    % No significant results
    save_res_neg(res);
end

% Write results table
output = {'split', res.frwork.split.all, 'correl', S.correl};
if cfg.stat.nperm > 0 && (strcmp(cfg.frwork.name, 'permutation') ...
        || ~strcmp(cfg.stat.split.crit, 'none'))
    output = [output {'pval', res.stat.split.pval}];
end
if strcmp(cfg.machine.name, 'spls')
    output = [output {'nfeatx', S.wX, 'nfeaty', S.wY}];
    
else
    param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
    if isfield(param, 'L2x') && isfield(param, 'L2y')
        output = [output {'l2x', cat(1, param.L2x), 'l2y', cat(1, param.L2y)}];
    end
    if isfield(param, 'PCAx') && isfield(param, 'PCAy')
        output = [output {'npcax', cat(1, param.PCAx), 'npcay', cat(1, param.PCAy)}];
    end
    if isfield(param, 'VARx') && isfield(param, 'VARy')
        output = [output {'varx', cat(1, param.VARx), 'vary', cat(1, param.VARy)}];
    end
end
if isfield(cfg, 'defl') && ~isempty(strfind(cfg.defl.crit, 'sim'))
    output = [output {'dist', distance}];
end
write_results(res, 'results_table', output{:});


% --------------------------- Private functions ---------------------------

function write_results(res, fname, varargin)

% Create table
T = table();
for i=1:numel(varargin)
    if ~mod(i, 2)
        switch varargin{i-1}
            case {'split' 'npcax' 'npcay'} % 'set' 'ncca' 
                T.(varargin{i-1}) = varargin{i};
                
            case {'nfeatx' 'nfeaty'}
                T.(varargin{i-1}) = sum(varargin{i}~=0, 2);
                
            case {'dist' 'l2x' 'l2y' 'pval' 'correl' 'covar' 'varx' 'vary'}
                T.(varargin{i-1}) = arrayfun(@(x) sprintf('%.4f', x), ...
                    varargin{i}, 'un', 0);           
        end
    end
end

% Write results
writetable(T, fullfile(res.dir.res, [fname '.txt']), 'Delimiter', '\t');


function res = save_res_pos(res, varargin)

if nargin > 1
    % Assign input
    [metric, fun] = varargin{1:2};
    num = size(metric, 2);
    if num ~= numel(fun)
        error('number of elements in metric and fun should match')
    end
    
    % Best split using criterions in specific order
    bestid = (1:res.frwork.split.nall)';
    for i=1:num
        fh = str2func(fun{i});
        met = cat(1, metric(bestid,i));
        [M, I] = fh(met);
        bestid = bestid(met == M); % we want all solutions
    end
    if numel(bestid) ~= 1
        warning('multiple best splits, first index chosen');
    end
    res.frwork.split.best = res.frwork.split.all(bestid);
end
savemat(res, fullfile(res.dir.res, 'res.mat'), 'res', res);
if nargin == 4
    fprintf('Results saved! (p=%.4f)\n', varargin{3});
else
    fprintf('Results saved!\n');
end


function save_res_neg(res)

savemat(res, fullfile(res.dir.res, 'res.mat'), 'res', res);
% fprintf('No significant splits found!\n');
