function template_analysis_rcca
% template_analysis1_rcca
%
% This is a template function. Please make a private copy of this file and
% change the necessary paths and specifications.
%
% # Description
% This template uses RCCA with correlation as hyperparameter optimization 
% criterion in a multiple holdout framework. Deflation is done using 
% the best split (based on highest correlation) and CCA projection deflation 
% (applied to all splits). Statistical inference is done at two stages. 
% First, for each outer split permutation test is performed based on 
% holdout correlations and using 1000 permutations. Second, for the 
% inference across splits (i.e. if the associative effect is significant as 
% a whole), 'omnibus' hypothesis is used, which tests if any outer split is 
% significant after adjusting the threshold with Bonferroni correction 
% (e.g. p=0.005 for 10 splits).
% 
% To account for the dependence structure across subjects/examples, 
% exchangeability blocks are used both for restricted partitioning and 
% permutations (for details, see [Winkler et al
% 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the 
% [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM)).
%
% Importantly, due to the efficient implementation of RCCA the code is able 
% to run on local computers in a few hours especially on smaller datasets 
% or on a computer with high specifications.
%
% # Highlights
%
% - __CCA projection__ deflation using the __best split__ and applied to __all splits__ 
% - statistical inference for each __individual split__ and __across splits__
% - hyperparameter optimization criterion: __test correlation__
% - dependency across examples: __exchangeability blocks__
% - computation environment: __local__
%
% # Usage
% Make a copy of this function and change your project folder. You can then
% run this template by calling the function without any input parameters from 
% within the command window.
%
%  template_analysis1_rcca()
%
% # Configuration
%  % Project folder
%  cfg.dir.project = '/PATH/TO/YOUR/PROJECT/';
%
%  % Machine settings
%  cfg.machine.name = 'rcca';
%  cfg.machine.metric = {'correl'};
%  cfg.machine.param.crit = 'correl';
% 
%  % Environment settings
%  cfg.env.comp = 'local';
% 
%  % Framework settings
%  cfg.frwork.name = 'holdout';
%  cfg.frwork.flag = '_corr';
%
%  % Restricted CV and permutation settings
%  cfg.data.block = 1;
%  cfg.frwork.split.EBcol = 2:3;
%
%  % Deflation settings
%  cfg.defl.name = 'generalized';
%  cfg.defl.crit = 'correl';
%  cfg.defl.split = 'all';
% 
%  % Statistical inference
%  cfg.stat.split.crit = 'correl';
%  cfg.stat.overall.crit = 'none';
% 
%  % Number of permutation tests
%  cfg.stat.nperm = 1000;
%
% ---
% Authors: Agoston Mihalik
%
% Website: [MLNL](http://www.mlnl.cs.ucl.ac.uk/)

set_path;

%----- Set configuration

% Project folder
cfg.dir.project = '/PATH/TO/YOUR/PROJECT/';

% Machine settings
cfg.machine.name = 'rcca';
cfg.machine.metric = {'correl'};
cfg.machine.param.crit = 'correl';

% Environment settings
cfg.env.comp = 'local';

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.flag = '_corr';

% Restricted CV and permutation settings
cfg.data.block = 1;
cfg.frwork.split.EBcol = 2:3;

% Deflation settings
cfg.defl.name = 'generalized';
cfg.defl.crit = 'correl';
cfg.defl.split = 'all';

% Statistical inference
cfg.stat.split.crit = 'correl';
cfg.stat.overall.crit = 'none';

% Number of permutation tests
cfg.stat.nperm = 1000;
   
% Update cfg with defaults
cfg = cfg_defaults(cfg);

%----- Run analysis

main(cfg);