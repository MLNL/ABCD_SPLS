function template_analysis_rerun
% template_analysis_rerun
%
% This is a template function. Please make a private copy of this file and
% change the necessary paths and specifications.
%
% # Description
% To rerun a specific analysis, simply load the cfg.mat file that has been
% created by the toolbox. You can find the cfg.mat file inside 
% '/PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/' 
%
% # Usage
% Make a copy of this function and change the path to the cfg file. You can 
% then run this template by calling the function without any input 
% parameters from within the command window.
%
%  template_analysis_rerun()
%
% ---
% Authors: Agoston Mihalik
%
% Website: [MLNL](http://www.mlnl.cs.ucl.ac.uk/)

set_path;

%----- Set configuration

% Load cfg file
load('/PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/cfg_1.mat');

%----- Run analysis

main(cfg);