function plot_weight(res, mod, modtype, split, func, varargin)
% plot_weight
%
% It plots the model weights in specific figures based on the modality of 
% the data. 
%
% # Syntax
%   plot_weight(res, mod, modtype, split, func, varargin)
%
% # Inputs
% res:: struct 
%   res structure containing information about results and plot specifications
% mod:: 'X', 'Y' 
%   modality of data to be used for plotting
% modtype:: 'behav', 'conn', 'vbm', 'roi', 'simul', 'brainnet'
%   type of data
% split:: int
%   index of data split to be used
% func:: 'behav_horz', 'behav_vert', 'brain_conn_node', 'brain_cortex', 'brain_edge', 'brain_module', 'brain_node', 'brain_schemaball', 'brain_subcortex', 'stem'
%   name of the specific plotting function (after plot_weight_* prefix) to
%   be called
% varargin:: name-value pairs
%   additional options can be passed via name-value pairs with dot notation
%   supported (e.g., 'behav.weight.numtop', 20)
%
% # Examples
%
% ## Behavioural
%   % Plot top behavioural weights as horizontal bar plot
%   res.behav.weight.sorttype = 'sign';
%   res.behav.weight.numtop = 20;
%   res.behav.label.maxchar = 50;
%   plot_weight(res, 'Y', 'behav', res.frwork.split.best, 'behav_horz');
% 
% ## Connectivity
%   % Plot top connectivity weights on glass brain
%   res.conn.file.label = fullfile(res.dir.project, 'data', ...
%                                  'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.csv');
%   res.conn.weight.sorttype = 'sign';
%   res.conn.weight.numtop = 20;
%   res.brainnet.file.surf = 'PATH/TO/BrainMesh_ICBM152_smoothed.nv';
%   res.brainnet.file.options = fullfile(res.dir.project, 'data', 'BrainNet', ...
%                                        'options_edge.mat');
%   plot_weight(res, 'X', 'conn', res.frwork.split.best, 'brain_edge');
%   
%   % Plot top connectivity weights as schemaball
%   plot_weight(res, 'X', 'conn', res.frwork.split.best, 'brain_schemaball');
%
% ---
% See also: [plot_paropt](../plot_paropt), [plot_proj](../plot_proj)

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Parse input and add default settings
res = res_defaults(res, modtype, varargin{:});

% Add SPM if needed
if strcmp(res.gen.selectfile, 'interactive') || strcmp(modtype, 'vbm')
    set_path('spm');
end

%----- Get weight vectors

% Load weights
weight = loadmat(res, fullfile(res.dir.res, 'model.mat'), ['w' mod]);
weight = weight(split,:)';

% Process weights
if strcmp(res.gen.weight.type, 'correlation')
    tic
    if ismember(cfg.machine.name, {'cca' 'rcca'})
        % Load data in feature space
        [trdata, trid, tedata, teid] = load_data(res, {['R' mod]}, 'osplit', split);
        data = concat_data(trdata, tedata, {['R' mod]}, trid, teid);
        
        % Load parameters
        param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
        
        % Define feature index
        featid = get_featid(trdata, param(split), mod);
        
        % Project data in feature space
        weight = trdata.(['V' mod])(:,featid)' * weight;
        P = calc_proj(data.(['R' mod])(:,featid), weight);
    end
    
    % Load data in input space
    [trdata, trid, tedata, teid] = load_data(res, {mod}, 'osplit', split);
    data = concat_data(trdata, tedata, {mod}, trid, teid);
    
    if ismember(cfg.machine.name, {'pls' 'spls'})
        % Project data in input space
        P = calc_proj(data.(mod), weight);
    end
    
    % Compute correlation between input data and projection
    weight = corr(P, data.(mod), 'rows', 'pairwise')';
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
    [weight, iweight] = postproc_weight(res, weight, modtype);
end

%----- Visualize/summarize weights and write to disc

% Specify weight file name
if isfield(res.(modtype), 'weight') && isfield(res.(modtype).weight, 'type') ...
        && strcmp(res.(modtype).weight.type, 'strength')
    wfname = fullfile(res.dir.res, [res.gen.weight.type '_strength' mod]);
else
    wfname = fullfile(res.dir.res, [res.gen.weight.type mod]);
end
if strcmp(modtype, 'conn')
    suffix = strsplit(func, '_');
    wfname = [wfname '_' suffix{end}];
end
if isfield(res.(modtype), 'weight') && ~isinf(res.(modtype).weight.numtop)
    wfname = sprintf('%s_top%s%d', wfname, res.(modtype).weight.sorttype, res.(modtype).weight.numtop);
end
if strcmp(func, 'brain_cortex') && res.vbm.subcortex
    wfname = [wfname '_cort'];
elseif strcmp(func, 'brain_subcortex')
    wfname = [wfname '_subcort'];
end
if isfield(res.(modtype), 'weight') && isfield(res.(modtype).weight, 'sign') ...
        && ~strcmp(res.(modtype).weight.sign, 'all')
    wfname = [wfname '_' res.(modtype).weight.sign(1:3)];
end
if isfield(res.(modtype), 'module') && isfield(res.(modtype).module, 'type') ...
        && ~isempty(strfind(func, 'module'))
    wfname = [wfname '_' res.(modtype).module.type];
end
if isfield(res.(modtype), 'module') && isfield(res.(modtype).module, 'logtrans') ...
        && res.(modtype).module.logtrans
    wfname = [wfname '_log'];
end
wfname = sprintf('%s_split%d', wfname, split);

% Visualize/summarize weights
plottype = strsplit(func, '_');
plottype = plottype{1}; % first substring codes main plot type
func = str2func(['plot_weight_' func]);
if strcmp(plottype, 'behav')
    % Bar plots or text prints
    func(res, weight, iweight, wfname);
    
elseif strcmp(plottype, 'stem')
    % Stem plot
    func(res, weight, iweight, wfname, mod);
    
elseif strcmp(plottype, 'brain')
    % Glass brain plots (and module connectivity plot)
    func(res, weight, wfname);
    
elseif strcmp(plottype, 'corr')
    % Glass brain plots (and module connectivity plot)
    func(res, weight, iweight, wfname);
    
end