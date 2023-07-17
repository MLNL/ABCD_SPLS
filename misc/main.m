function main(res)

%----- 1. Initialize results

if ~isfield(res.frwork, 'level')
    % Initialize results
    res = res_defaults([], 'init', 'frwork.level', 1, 'dir.frwork', res.dir.frwork, ...
        'env.fileend', res.env.fileend, 'env.seed', res.env.seed);
else
    % Update results
    res = res_defaults(res, 'init');
end

%----- 2. Calculate data splits

% Calculate outer train-test
calc_splits(res, 'out');

% Calculate inner train-test (for hyperparameter optimization)
calc_splits(res, 'in');

%----- 3. Run models

% Calculate grid search over hyper-parameters
run_model(res, 'gridsearch');

% Run main model
run_model(res, 'main');

% Initialize permutations
calc_permid(res, 'perm');
            
% Run permutation tests
run_model(res, 'permutation');

%----- 4. Calculate stats and save results

% Calculate statistical inference
res = stat_inference(res);

% Save results
res = save_results(res);

%----- 5. Run analysis on next level

% Run analysis iteratively if results are significant
% if (res.stat.nperm == 0 && res.frwork.level < res.frwork.nlevel) ...
%     || (isfield(res.frwork, 'split') && isfield(res.frwork.split, 'sig') ...
%         && ~isempty(res.frwork.split.sig))
%     res.frwork.level = res.frwork.level + 1;
%     main(res);
% end
if (res.stat.nperm == 0 && res.frwork.level < 100) || (isfield(res.frwork, 'split'))
    % && ~isempty(res.frwork.split.sig))
    res.frwork.level = res.frwork.level + 1;
    main(res);
end
