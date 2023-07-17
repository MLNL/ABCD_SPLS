function plot_corr(res, mod, modtype, split, func, corrVal, varargin)
%WARNING: THIS FUNCTION *DOES NOT* TAKE SPLIT INFORMATION INTO ACCOUNT - IS
%ONLY FOR THE "FAIR" FRAMEWORK. CHANGE ACCORDINGLY FOR OTHER FRAMEWORKS.

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Parse input and add default settings
res = res_defaults(res, modtype, varargin{:});

% Add SPM if needed
if strcmp(res.gen.selectfile, 'interactive') || strcmp(modtype, 'vbm')
    set_path('spm');
end

%----- Get weight vectors

% Load weights
% weight = loadmat(res, fullfile(res.dir.res, 'model.mat'), ['w' mod]);
weight = load(fullfile(res.dir.res, 'corrCell.mat'));
if contains(modtype, 'behav')
    weight = (weight.corrCell{1,2})';
else if contains(modtype, 'vbm')
        weight = (weight.corrCell{1,1})';
    end
end

% Compute strength by modifying weight by population mean data
if isfield(res.(modtype), 'weight') && isfield(res.(modtype).weight, 'type') ...
        && strcmp(res.(modtype).weight.type, 'strength')
    data = load(res.data.(mod).fname); % load original data
    weight = weight .* reshape(sign(nanmean(data.(mod))), [], 1);
end
weight(isnan(weight)) = 0;

% Flip weights
if res.gen.weight.flip
    weight = -weight;
end
if strcmp(modtype, 'behav') % workaround for reversed-scored questionnaires
    labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
        'Select delimited label file for behaviour...', 'any', res.behav.file.label);
    T = readtable(labelfname);
    if ismember('Flip', T.Properties.VariableNames)
        weight(T.Flip==1) = -weight(T.Flip==1);
    end
end

% Postprocess weights (sorting, filtering etc.)
if isfield(res.(modtype), 'weight') 
    [weight, iweight] = postproc_corr(res, weight, modtype, corrVal);
end

if contains(modtype, 'behav')
    wfname = fullfile(res.dir.res, 'behav_corr');
    func = str2func(['plot_weight_behav_horz']);
    func(res, weight, iweight, wfname);
else if contains(modtype, 'vbm')
          wfname = fullfile(res.dir.res, 'brain_corr');
          func = str2func(['plot_weight_brain_cortex']);
          func(res, weight, wfname);
    end
end


