function compile_files(res, files)
% compile_files
%   Some description here

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Get option
[pathstr, name, ext] = fileparts(files{1});
opt = regexp(name, '^[a-z]+', 'match');
opt = opt{:};

% Initialization
S = cell2struct(cell(numel(cfg.machine.metric), numel(files)), cfg.machine.metric);

% Load files
for i=1:numel(files)
    if ~exist_file(res, fullfile(res.dir.(opt), ['all' opt '.mat']))
        fprintf('%d\n', i);
        try
            S(i) = loadmat_struct(res, files{i});
        catch
            fprintf('hyperparameter %d was not loaded', i);
        end
    else
        break
    end
end

% Compile files if no missing data
if ~any(arrayfun(@(x) isempty(S(x).(cfg.machine.metric{1})), 1:numel(files)))
    if strcmp(opt, 'grid')
        name_value = parse_struct(S, 1);
    elseif strcmp(opt, 'perm')
        name_value = parse_struct(S, 2);
    end
    savemat(res, fullfile(res.dir.(opt), ['all' opt '.mat']), name_value{:});
end
