function res = res_defaults(res, mode, varargin)
% res_defaults
%
% Set defaults in your results (`res`) structure including information about
% the results and settings for plotting. Use this function to update and 
% add all necessary defaults to your `res`. If you have defined anything in 
% `res` before calling the function, it won't overwrite those values. The 
% path to the framework folder should be always defined in your `res` or 
% passed as varargin, otherwise the function throws an error. All the other 
% fields are optional and can be filled up by `res_defaults`.
%
% This function can be also called to load an existing `res.mat` file. 
%
% !!! note "Warning"
%     We strongly advise to inspect the output of `res_defaults` to make 
%     sure that the defaults are set as expected.
%
% # Syntax
%   res = res_defaults(res, mode, varargin)
%
% # Inputs
% res:: struct
%   results structure (more information below)
% mode:: 'init', 'load', 'projection', 'simul', 'behav', 'conn', 'vbm', 'roi', 'brainnet'
%   mode of calling res_defaults, either referring to initialization ('init'),
%   loading ('load'), type of plot ('projection', 'simul', 'behav', 'conn', 
%   'vbm', 'roi') or settings for toolbox ('brainnet') 
% varargin:: name-value pairs
%   additional parameters can be set via name-value pairs with dot notation 
%   supported (e.g., 'behav.weight.numtop', 20)
%
% # Outputs
% res:: struct
%   result structure that has been updated with defaults
%
% # Examples
%   % Example 1
%   res.dir.frwork = 'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME';
%   res.frwork.level = 1;
%   res.env.fileend = '_1';
%   res = res_defaults(res, 'load');
%
%   % Example 2
%   res = res_defaults([], 'load', 'dir.frwork', ...
%                      'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
%   
%   % Example 3
%   res = res_defaults([], 'load', 'dir.frwork', ...
%                      'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
%   res = res_defaults(res, 'behav');
%
% ---
% See also: [res](../../res), [cfg_defaults](../cfg_defaults/)

def = parse_input(varargin{:});

% Initialize res
if isempty(res)
    res = struct();
end
res = assign_defaults(res, def);

% Level of results
def.frwork.level = 1;

% Filename suffix
def.env.fileend = '_1';

% Update res
res = assign_defaults(res, def);

% Check that path to framework folder exists
if ~isfield(res, 'dir') || ~isfield(res.dir, 'frwork')
    error('Path to framework folder should be given.')
end

%----- Initialize or load results

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

if strcmp(mode, 'init')
    % Set up folders
    def.dir.project = cfg.dir.project;
    res.dir.frwork = cfg.dir.frwork;
    subdir = {'perm' 'res'};
    if ismember(cfg.frwork.name, {'holdout' 'cv' 'fair'})
        subdir{end+1} = 'grid';
    end
    for i=1:numel(subdir)
        res.dir.(subdir{i}) = fullfile(cfg.dir.frwork, subdir{i}, sprintf('level%d', ...
            res.frwork.level));
    end
    
    % Set up stats
    res.stat = struct('nperm', cfg.stat.nperm);
    if res.stat.nperm == 0
        res.frwork.nlevel = cfg.frwork.nlevel;
    end

    % Initialize/update split details
    if res.frwork.level == 1
        def.frwork.split = struct('all', (1:cfg.frwork.split.nout)', ...
            'nall', cfg.frwork.split.nout);
    elseif res.stat.nperm ~= 0
        res.frwork.split = struct('all', res.frwork.split.sig, ...
            'nall', numel(res.frwork.split.sig));
    end

    % Initialize res
    res = assign_defaults(res, def);
    
    % Inherit compression setting for saving files
    res.env.save = cfg.env.save;
    
    return;
    
else
    % Keep copy of current res
    def = res;
    
    % Load res
    res = loadmat(res, fullfile(res.dir.frwork, 'res', ['level', ...
        num2str(res.frwork.level)], 'res.mat'), 'res');
    
    % Update res with saved copy
    res = assign_defaults(res, def);
end

%----- General settings for plots

% Project folder
def.dir.project = cfg.dir.project;
    
% Update defaults
res = assign_defaults(res, def);

if strcmp(mode, 'load')
    return
end

% File selection
def.gen.selectfile = 'interactive'; % selection for label, mask file etc: 'interactive' or 'none'

% Flip sign of weight
def.gen.weight.flip = 0; % boolean whether flip or not

% Data file names
def.data.X.fname = cfg.data.X.fname;
def.data.Y.fname = cfg.data.Y.fname;
if isfield(cfg.data, 'C')
    def.data.C.fname = cfg.data.C.fname;
end

% Update defaults
res = assign_defaults(res, def);

if strcmp(mode, 'paropt')
    %----- Grid-search plots of hyperparameters
    
    % Axes properties
    def.param.xscale = 'log'; % lin log
    def.param.yscale = 'log'; % lin log

elseif strcmp(mode, 'projection')
    %----- Projection/latent space plots
    
    % Axes properties
    def.proj.xlabel = 'Brain score';
    def.proj.ylabel = 'Behavioural score';
    def.proj.xlim = NaN;
    def.proj.ylim = NaN;
    
    def.proj.font.legend = 14;
    def.proj.font.axis = 14;
%     def.proj.font.label = 32;
    
    % Colormap/group information files
    def.proj.file.label = fullfile(res.dir.project, 'data', 'LabelsY.xlsx');
    def.proj.file.data = fullfile(res.dir.project, 'data', 'Y.mat');
    
    % Flip sign of projections
    def.proj.flip = res.gen.weight.flip; % boolean whether flip or not
    
    % multiple levels (average over modalities)
    def.proj.multi_level = 0;
    
else  
    % Type of weight
    def.gen.weight.type = 'weight'; % 'weight' 'correlation' 
            
    switch mode
        case 'simul'
            %----- Stem plots for simulations
            
            % Weight postprocessing
            def.simul.weight.filtzero = 0; % filter out weights with zero weights
            def.simul.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.simul.weight.sorttype = ''; % sort weights: '', 'sign' or 'abs'
            
            def.simul.weight.file.X = fullfile(res.dir.project, 'data', 'wX.mat');
            def.simul.weight.file.Y = fullfile(res.dir.project, 'data', 'wY.mat');
            
            % Axes properties
            def.simul.xlabel = 'Variables';
            def.simul.ylabel = 'Weights';
%             def.simul.xlim = NaN;
%             def.simul.ylim = NaN;
            
        case 'behav'
            %----- Behavioural bar plots
            
            % Weight postprocessing
            def.behav.weight.filtzero = 1; % filter out weights with zero weights
            def.behav.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.behav.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            def.behav.weight.norm = 0;
            
            % Label settings
            def.behav.file.label = fullfile(res.dir.project, 'data', 'LabelsY.xlsx');
            def.behav.label.maxchar = Inf; % set maximum number of characters for label names
            
            def.behav.xlabel = 'Behavioural variables';
            def.behav.ylabel = 'Normalized weights';
            
            def.behav.font.legend = 28;
            def.behav.font.axis = 24;
            def.behav.font.label = 32;
        case 'conn'
            %----- Connectivity plots
            
            % Mask file
            def.conn.file.mask = fullfile(res.dir.project, 'data', 'mask.mat');
            
            % Weight postprocessing
            def.conn.weight.filtzero = 1; % filter out weights with zero weights
            def.conn.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.conn.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            def.conn.weight.type = 'auto'; % 'auto' 'strength'
            def.conn.weight.sign = 'all'; % select subset of weights: 'all' 'positive' or 'negative'
            
            % Module weight visualization
%             def.conn.module.logtrans = 0; % boolean whether log transform module weights
            def.conn.module.disp = 0;  % display module weights
            def.conn.module.type = 'average'; % average sum
            def.conn.module.norm = 'none'; % normalize module weights: 'global', 'max', 'none'
            
            % Node type in connectivity data
            def.conn.node.type = 'ROI'; % 'ROI' or 'ICA'
            
            % Update res
            res = assign_defaults(res, def);
            
            if strcmp(res.conn.node.type, 'ICA')
               def.conn.file.cifti.scalar = fullfile(res.dir.project, 'data', 'melodic_IC.dscalar.nii');
               def.conn.file.cifti.label = fullfile(res.dir.project, 'data', 'melodic_IC_ftb.dlabel.nii');
            end
            % Data visualization based on projections
%             def.conn.proj.flip = res.gen.weight.flip;
%             def.conn.proj.perctop = 10;
%             def.conn.proj.sign = 'positive'; % 'positive' or 'negative'
            
            % Label file
            def.conn.file.label = fullfile(res.dir.project, 'data', 'LabelsX.xlsx');
            
        case 'vbm'
            %----- VBM (voxel-based morphometry) plots
            
            % Mask file
            def.vbm.file.mask = fullfile(res.dir.project, 'data', 'mask.nii');
            
            % Normalization to MNI space
            def.vbm.file.MNI = 'T1_1mm_brain.nii'; % template/source image for normalization
            def.vbm.transM = eye(4); % transformation matrix
            % transM for ABCD [1 0 0 118.6; 0 1 0 -128.6; 0 0 1 -63.3; 0 0 0 1]
            
            % Atlas for region-based summarization
            def.vbm.file.atlas.img = 'AAL2.nii'; % (should be in the path!)
            def.vbm.file.atlas.label = 'Labels_AAL2.xlsx'; % (should be in the path!)
            
            % Subcortex visualization
            def.vbm.subcortex = 0; % boolean to plot subcortex separately and not include in cortical plot
            
            % Update res
            res = assign_defaults(res, def);
            
            % Nilearn MNI template
            if res.vbm.subcortex
                def.vbm.file.nilearn.MNI = 'MNI152_T1_1mm_brain.nii'; % (should be in the path!)
            end
            
        case 'roi'
            %----- ROI (regions of interest) plots
            
            % Weight postprocessing
            def.roi.weight.filtzero = 1; % filter out weights with zero weights
            def.roi.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.roi.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            
            % ROI index/structure to remove
            def.roi.out = [];
            
            % Label file
            def.roi.file.label = fullfile(res.dir.project, 'data', 'LabelsX.xlsx');
            
        case 'brainnet'
            %----- Brainnet files
            
            % Brainnet files
            def.brainnet.file.surf = 'BrainMesh_ICBM152.nv'; % brain mesh file (should be in the path!)
            def.brainnet.file.options = fullfile(res.dir.project, 'data', 'BrainNet', 'options.mat'); % options file
    end
end

% Update defaults
res = assign_defaults(res, def);

% % Save res
% if ~isdir(res.dir.res)
%     mkdir(res.dir.res)
% end
% savemat(res, fullfile(res.dir.res, 'res.mat'), 'res', res);
