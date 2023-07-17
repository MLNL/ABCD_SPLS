function template_analysis_spls
% template_spls_analysis1
%
% This is a template function. Please make a private copy of this file and
% change the necessary paths and specifications.
%
% # Description
% This template uses SPLS with correlation and weight similarity as 
% hyperparameter optimization criteria in a multiple holdout framework. 
% Deflation is done using the best split (based on lowest p-value and highest
% correlation if tie) and PLS-mode A deflation (applied to all splits).
% Statistical inference is done at two stages. First, for each outer split 
% permutation test is performed based on holdout correlations and using
% 1000 permutations. Second, for the inference across splits (i.e.
% if the associative effect is significant as a whole), 'omnibus' hypothesis 
% is used, which tests if any outer split is significant after adjusting the 
% threshold with Bonferroni correction (e.g. p=0.005 for 10 splits).
%
% For a similar application, see [Monteiro et al
% 2016](http://www.sciencedirect.com/science/article/pii/S0165027016301327).
%
% # Highlights
% - __PLS-mode A__ deflation using the __best split__ and applied to __all splits__ 
% - statistical inference for each __individual split__ and __across splits__
% - hyperparameter optimization criterion: __test correlation__ and __similarity of weights__
%
% # Usage
% Make a copy of this function and change your project folder. You can then
% run this template by calling the function without any input parameters from 
% within the command window.
%
%  template_analysis1_spls()
%
% # Configuration
%  % Project folder
%  cfg.dir.project = '/PATH/TO/YOUR/PROJECT/';
%  
%  % Machine settings
%  cfg.machine.metric = {'correl' 'simwx' 'simwy'};
%  cfg.machine.param.crit = 'correl+simwxy';
% 
%  % Environment settings
%  cfg.env.comp = 'cluster';
% 
%  % Framework settings
%  cfg.frwork.name = 'holdout';
%  cfg.frwork.flag = '_modeA_corr-simwxy';
% 
%  % Deflation settings
%  cfg.defl.name = 'pls-modeA';
%  cfg.defl.crit = 'pval+correl';
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
cfg.machine.name = 'spls';
cfg.machine.metric = {'correl' 'simwx' 'simwy'};
cfg.machine.param.crit = 'correl+simwxy';

% Environment settings
cfg.env.comp = 'cluster';

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.flag = '_modeA_corr-simwxy';

% Deflation settings
cfg.defl.name = 'pls-modeA';
cfg.defl.crit = 'pval+correl';
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