function run_model(res, runtype)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');
    
% Update runtype if needed
if strcmp(cfg.frwork.name, 'holdout_perm') && strcmp(runtype, 'gridsearch')
    runtype = 'gridsearch_perm';
end

switch runtype
    case 'gridsearch'
        % Get default parameters and quit if no grid search
        param = get_hyperparam(res, 'default');
        if numel(param) == 1
            return
        end
        
        while ~exist_file(res, fullfile(res.dir.grid, 'allgrid.mat'))
            fprintf('\nRunning hyperparameter optimization\n'); tic
            
            % Create folder for grid search results 
            if ~isdir(res.dir.grid)
                mkdir(res.dir.grid)
            end
            
            % Set seed for reproducibility
            rng(res.env.seed.model);
            
            % Initialize files
            p = reshape(fieldnames(param), 1, []); % make sure it is a row vector
            in = [p; cellfun(@(x) cfg.machine.param.(x), p, 'un', 0)];
            file = cellfun(@(x) fullfile(res.dir.grid, ['grid_' x '.mat']), ...
                ffd_val_str('split', res.frwork.split.all, in{:}), 'un', 0);
            file = reshape(file, res.frwork.split.nall, []);
            
            % Loop over iterations in random order
            iteri = randperm(res.frwork.split.nall);
            for i=1:numel(iteri)

                iterj = randperm(size(file, 2));
                for j=1:numel(iterj)
                    if ~exist_file(res, file{iteri(i),iterj(j)})                       
                        fprintf('\nhyperparameter id: %d (out of %d), split id: %d (out of %d)\n', ...
                            j, numel(param), i, res.frwork.split.nall); tic
                        
                        % Initialize machine outputs
                        fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
                        S = cell2struct(cell(numel(fields), cfg.frwork.split.nin), fields);
                        
                        for m=1:cfg.frwork.split.nin
                            % Load data and split to training and test sets
                            clear trdata tedata
                            [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, ...
                                'isplit', [res.frwork.split.all(iteri(i)), m], param(iterj(j)));
                            
                            % Run machine
                            S(m) = run_machine(cfg, trdata, tedata, featid, param(iterj(j)), 'Pearson');
                        end
                        S = process_metric(cfg, S, 'gridsearch');
                        
                        % Write metric to disk
                        name_value = parse_struct(S, 2);
                        savemat(res, file{iteri(i),iterj(j)}, name_value{:});
                        
                        if exist_file(res, fullfile(res.dir.grid, 'allgrid.mat'))
                            break
                        end
                        
                        fprintf('\nhyperparameter id: %d (out of %d), split id: %d (out of %d) done!\n', ...
                            j, numel(param), i, res.frwork.split.nall); toc
                        
                    end
                end
                
            end

            fprintf('Hyperparameter optimization done!\n'); toc
            
            % Compile files
            compile_files(res, file);
        end
        
                    
    case 'main'
        % Create folder for main results 
        if ~isdir(res.dir.res)
            mkdir(res.dir.res)
        end
        
        % Load and save parameters
        param = get_hyperparam(res, 'default');
        if numel(param) == 1
            param = repmat(param, res.frwork.split.nall, 1);
        elseif isfield(res.dir, 'grid')
            param = get_hyperparam(res, 'grid');
        end
        savemat(res, fullfile(res.dir.res, 'param.mat'), 'param', param);
                
        % Initialize file and machine outputs
        file = fullfile(res.dir.res, 'model.mat');
        fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
        S = cell2struct(cell(numel(fields), res.frwork.split.nall), fields);
                    
        if ~exist_file(res, file)            
            fprintf('\nTraining main models\n\n'); tic
            
            for n=1:res.frwork.split.nall
                % Load data and split to training and test sets
                clear trdata tedata
                [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, 'osplit', ...
                    res.frwork.split.all(n), param(n));
                
                % Run machine
                S(n) = run_machine(cfg, trdata, tedata, featid, param(n), 'Pearson');
            end
            S = process_metric(cfg, S, 'main');
            
            % Save results
            name_value = parse_struct(S, 1);
            savemat(res, file, name_value{:});
        
            fprintf('Training main models done!\n'); toc
        end
                    
    case 'permutation'
        % Quit if no permutations needed or maximum statistics at level > 1
        if res.stat.nperm == 0 || (strcmp(cfg.frwork.name, 'permutation') ...
                && res.frwork.level > 1)
            return
        end
        
        % Create folder for permutation test results 
        if ~isdir(res.dir.perm)
            mkdir(res.dir.perm)
        end
        
        while ~exist_file(res, fullfile(res.dir.perm, 'allperm.mat'))            
            fprintf('\nRunning permutation tests\n\n'); tic
            
            % Load parameters
            param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
            
            % Initialize files
            file = arrayfun(@(x) fullfile(res.dir.perm, sprintf('perm_%05d.mat', x)), ...
                1:cfg.stat.nperm, 'un', 0);
            
            % Set seed for reproducibility
            rng(res.env.seed.model);
            
            % Run permutation test
            iter = randperm(numel(file));
            for it=1:numel(iter)
                if ~exist_file(res, file{iter(it)})                                 
                    fprintf('\npermutation id: %d (out of %d)...\n', it, numel(file)); tic
                    
                    % Initialize machine outputs
                    fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
                    S = cell2struct(cell(numel(fields), res.frwork.split.nall), fields);
                        
                    for n=1:res.frwork.split.nall
                        % Load data and split to training and test sets
                        clear trdata tedata
                        [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, 'osplit', ...
                            res.frwork.split.all(n), param(n));
                        
                        % Permute data
                        [trdata, tedata] = permute_data(res, trdata, tedata, ...
                            res.frwork.split.all(n), iter(it));
                        
                        % Run machine
                        S(n) = run_machine(cfg, trdata, tedata, featid, param(n), 'Pearson');
                    end
                    S = process_metric(cfg, S, 'permutation');
                    
                    % Write metric to disk
                    name_value = parse_struct(S, 1);
                    savemat(res, fullfile(res.dir.perm, sprintf('perm_%05d.mat', iter(it))), name_value{:});
                    
                    % Update missing files
                    if exist_file(res, fullfile(res.dir.perm, 'allperm.mat'))
                        break
                    end
                    
                    fprintf('\npermutation id: %d (out of %d) done!\n', it, numel(file)); toc
                    
                end
            end
            
            fprintf('Permutation test done!\n'); toc
            
            % Compile files
            compile_files(res, file);
        end
end    