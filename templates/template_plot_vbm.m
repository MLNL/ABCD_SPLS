function template_plot_vbm
% template_plot_vbm
%
% This is a template function. Please make a private copy of this file and
% change the necessary paths and specifications.
%
% # Description
% This is a template for plotting brain-behaviour analysis of voxel-wise
% (voxel-based morphometry, VBM) structural MRI and labelled behavioural
% data.
%
% For an application, see figures in [Mihalik et al
% 2020](https://doi.org/10.1016/j.biopsych.2019.12.001).
%
% # Highlights
% - plot hyperparameter surface
% - plot projections
% - plot behavioural weights
% - plot cortical brain weights
%
% # Usage
% Make a copy of this function and change your project folder. You can then
% run this template by calling the function without any input parameters from 
% within the command window.
% Run the function multiple times to plot figures for multiple
% levels. All plots are automatically saved to the results folder of your 
% project ('/PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/res'), separated 
% by different levels (i.e., associative effects).
%
% For detailed instructions of the specific plots, see [plot_paropt](../plot_paropt),
% [plot_proj](../plot_proj) and [plot_weight](../plot_weight)
% under Basic plotting in the navigation bar.
%
%  template_plot_vbm()
%
% ---
% Authors: Agoston Mihalik
%
% Website: [MLNL](http://www.mlnl.cs.ucl.ac.uk/)

clc; close all

% Set path with plotting folder and necessary toolboxes
set_path('plot', 'brainnet', 'spm');

%----- Initialize res and update path to experiment

% Required fields
res.dir.frwork = '/PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/';
res.frwork.level = 1;
res.env.fileend = '_1';

% Optional fields
res.gen.selectfile = 'none';

% Update path if data moved (e.g. from cluster to local computer)
update_dir(res.dir.frwork, res.env.fileend)

% Initialize res
res = res_defaults(res, 'load');

%----- Plot results

% NB: optional res fields can be assigned for each function as varargin
% (see examples using plot_weight below)

% Plot hyperparameter surface for grid search results
for i=1:res.frwork.split.nall
    plot_paropt(res, {'X' 'Y'}, res.frwork.split.all(i), 'correl', 'simwx', 'simwy');
end

% Plot data projections by group (healthy, depressed)
for i=1:res.frwork.split.nall
    plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.all(i), ...
        'healthy+depressed', '2d_group');
end

% Plot behavioural weights as horizontal bar plot
for i=1:res.frwork.split.nall
    plot_weight(res, 'Y', 'behav', res.frwork.split.all(i), 'behav_horz');
end

% Plot cortical brain weights
for i=1:res.frwork.split.nall
    plot_weight(res, 'X', 'vbm', res.frwork.split.all(i), 'brain_cortex', ...
        'vbm.file.mask', fullfile(res.dir.project, 'data', 'gm_binary_mask.nii'));
end