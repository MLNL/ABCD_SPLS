function demo_smri
% demo_smri
%
% This is a demo for structural MRI data. We will discuss step by step how to 
% set up and run an analysis as well as how to visualize the results. Copy
% and paste the code chunks into a function to create your own experiment.
%
% ## Analysis
%
% First, run `set_path` to add the necessary paths of the toolkit 
% to your MATLAB path.
%

% ```matlab
% %----- Analysis
%
% % Set path for analysis
% set_path;
% ```
% ### Project Folder
%
% Next, we specify the folder to our project. Since we will use the toolkit
% to generate fake structural MRI data, we do not need to provide input data (`X.mat`
% and `Y.mat`). Make sure to specify the correct path. We recommend to use a 
% full path, but a relative path should also work.
%
% ```matlab
% % Project folder
% cfg.dir.project = fullfile('projects', 'demo_sMRI');
% ```
%
% ### Machine
%
% Now, we configure the CCA/PLS model we would like to use. We set 
% `machine.name` to `rcca` for [Regularized CCA](../../background/#regularized-cca-rcca).
% To select the best hyperparameter (L2 regularization for RCCA), we will use 
% a generalizability (measured as average out-of-sample corretion on the 
% validation sets) criterion. This is set by `machine.param.crit = 'correl'`.
% 
% ```matlab
% % Machine settings
% cfg.machine.name = 'rcca';
% cfg.machine.param.crit = 'correl';
% ```
%
% For more information on the CCA/PLS models and the hyperparameter choices,
% see [here](../../cfg/#machine).
%
% ### Data
%
% As we use the toolkit to generate fake structural MRI data for us, we need 
% to define the number of subjects/examples, and the number of features/variables in
% our `X` and `Y` data.
%
% ```matlab
% % Fake sMRI data dimensionality
% cfg.data.nsubj = 1000;
% cfg.data.X.nfeat = 120;
% cfg.data.Y.nfeat = 100;
% ```
% 
% For further details on the choices of data settings, see [here](../../cfg/#data).
%
% ### Framework
%
% Next, we set the framework name to `holdout` and the number of outer data 
% splits to 1 to perform a single holdout approach. The `frwork.flag` field 
% defines a custom name for this analysis. Make sure to give it a name that 
% will help you organize different analyses you might run on your data.
%
% ```matlab
% % Framework settings
% cfg.frwork.name = 'holdout';
% cfg.frwork.split.nout = 1;
% cfg.frwork.flag = '_test';
% ```
%
% For further details on the framework choices, see [here](../../cfg/#frwork).
%
% ### Deflation
%
% Next, we set the deflation of RCCA. We will use generalized deflation.
%
% ```matlab
% % Deflation settings
% cfg.defl.name = 'generalized';
% ```
%
% For further details on the deflation choices, see [here](../../cfg/#defl).
%
% ### Environment
% Next, we set the computational environment for the toolkit. As our RCCA
% implementation is computationally efficient, most of the times we can run
% it locally on our computer.
%
% ```matlab
% % Environment settings
% cfg.env.comp = 'local';
% ```
%
% For further details on the environmental settings, see [here](../../cfg/#env).
%
% ### Statistical Inference
%
% Finally, we need to define how the significance testing is performed. 
% For quicker results, we wet the number of permutations to 100, however, 
% we recommend using at least 1000 permutations in general. 
% 
% ```matlab
% % Number of permutations
% cfg.stat.nperm = 100;
% ```
%
% For further details on the statistical inference, see [here](../../cfg/#stat).
%
% ### Run Analysis
%
% To run the analysis, we simply update our `cfg` structure to add all 
% necessary default values that we did not explicitly define and then run 
% the `main` function. After the analysis, we clean up all the duplicate
% and intermediate files to save disc space.
%
% ```matlab
% % Update cfg with defaults
% cfg = cfg_defaults(cfg);
% 
% % Run analysis
% main(cfg);
%
% % Clean up analysis files to save disc space
% cleanup_files(cfg);
% ```
%
% # Visualization
%
% Now that we have run our first analysis, let's plot some of the results. 
% Before we can do any plotting, we need to make sure that we have called 
% `set_path('plot')` to add the plotting folder. Then we load the `res`
% structure.
%
% In general, we advise you to plot your results on a local computer as it 
% is often cumbersome and slow in a cluster environment. If you move your 
% results from a cluster to a local computer, you need update the paths in 
% your `cfg*.mat` and `res*.mat` files using `update_dir`. This should be 
% called once the `res` structure is loaded either manually or by `res_defaults`.
%
% ```matlab
% %----- Visualization
%
% % Set path for plotting and the AAL and BrainNet Viewer toolboxes
% set_path('plot', 'aal', 'brainnet');
%
% % Load res
% res.dir.frwork = cfg.dir.frwork;
% res.env.fileend = cfg.env.fileend;
% res.frwork.level = 1;
% res = res_defaults(res, 'load');
% ```
%
% ## Create Labels
%
% As we used fake structural MRI and behavioural data, we need to create 
% labels. For the brain features, we will use the AAL atlas to create 120 
% regions-level labels. For our behavioural features, we will simply use
% indexes as label and 2 domains as category variable.
%
% ```matlab
% % Create AAL labels for fake sMRI data
% BrainNet_GenCoord(which('AAL2.nii'), 'AAL2.txt');
% T = readtable('AAL2.txt');
% T.Properties.VariableNames([1:3 6]) = {'X' 'Y' 'Z' 'Index'}; % we will need only these variables
% T.Label = [1:120]'; % we will just use a numeric label now
% writetable(T(:,[1:3 6:7]), fullfile(cfg.dir.project, 'data', 'LabelsX.xlsx'));
% delete AAL2.txt; % clean up
%
% % Create labels for fake behavioural data
% T = table([1:100]', [repmat({'Domain 1'}, 50, 1); repmat({'Domain 2'}, 50, 1)], 'VariableNames', {'Label' 'Category'});
% writetable(T, fullfile(cfg.dir.project, 'data', 'LabelsY.xlsx'));
% ```
%
% ## Plot Grid Search Results
%
% First, we plot the grid search results of the hyperparameter
% optimization. As first argument, we need to pass the `res` structure. 
% Then we specify the data modality as string. The last argument is a 
% varargin to define an optional number of metrics. Each metric will be 
% plotted as a function of the hyperparameter grid and in a separate
% subplot. In this example, we plot the training (in-sample) and test 
% (out-of-sample) correlations as  metrics.
%
% ```matlab
% % Plot hyperparameter surface for grid search results
% plot_paropt(res, {'X' 'Y'}, 1, 'trcorrel', 'correl');
% ```
%
% ![demo_smri_grid](../figures/demo_smri_grid.png)
%
% ## Plot Data Projections
%
% To plot the data projections (or latent variables) that has been 
% learnt by the model, simply run `plot_proj`. As first argument, we need 
% to pass the `res` structure. Then, we specify the data modalities as cell 
% array and the level of associative effect. In this example, we plot the 
% projections of `X` and `Y` for the first associative effect.
% We set the fourth input parameter to 'osplit' so that the training and 
% test data of the outer split will be used for the plot. The following 
% argument defines the outer data split we want to use (in this demo, we 
% have only one split). We use the second to last argument to specify the 
% colour-coding of the data using the training and test data as groups 
% (`teid`). Finally, we specify the low-level function that will plot the 
% results. In this case it is `plot_proj_2d_group`. Please see the 
% documentation of [plot_proj](../mfiles/plot_proj/) for more details. 
%
% ```matlab
% % Plot data projections
% plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', 1, 'teid', '2d_group')
% ```
%
% ![demo_smri_proj](../figures/demo_smri_proj.png)
%
% ## Plot Weights
%
% Plotting model weights heavily depends on the kind of data that has been 
% used in the analysis. In case of our fake structural MRI data, we will 
% plot the weights as nodes on a glass brain. We will use only the top 20 
% most positive and top 20 most negative weights for the figure. We set 
% this by first sorting the weights by their sign (`roi.weight.sorttype = sign`)
% then taking the top 20 from both ends (`roi.weight.numtop = 20`). In case 
% of our fake behavioural data, we will plot the weights as a vertical bar 
% plot, again using only the top 20 most positive and top 20 most negative
% weights. As first argument, we need to pass the `res` function, in which
% we define our custom processing for the weights. We also add the indexes of 
% cerebellum (based on the label file) to the `res` settings as do not want 
% to include cerebellum weights on the glass brain. Next, we specify the 
% data modality and the type of the modality as strings. In this example, we use 
% region-level brain and behavioural data, so we set these to `X` and `roi`
% for one and `Y` and `behav` for the other. The following argument 
% defines the outer data split we want to use. Finally, we specify 
% the low-level function that will plot the results. In this example, it 
% will be `plot_weight_brain_node` and `plot_weight_behav_vert`. Please 
% see the documentation of [plot_weight](../mfiles/plot_weight) for more details. 
%
% ```matlab
% % Plot ROI weights on a glass brain
% res.roi.weight.sorttype = 'sign';
% res.roi.weight.numtop = 20;
% res.roi.out = 9000 + [reshape([1:10:81; 2:10:82], [], 1); reshape(100:10:170, [], 1)]; % remove cerebellum
% plot_weight(res, 'X', 'roi', 1, 'brain_node');
% ```
%
% ![demo_smri_wx](../figures/demo_smri_weightX.png)
% 
% ```matlab
% % Plot behavioural weights as vertical bar plot
% res.behav.weight.sorttype = 'sign';
% res.behav.weight.numtop = 20;
% plot_weight(res, 'Y', 'behav', 1, 'behav_vert');
% ```
%
% ![demo_smri_wy](../figures/demo_smri_weightY.png)


clc

%----- Analysis

% Set path for analysis
set_path;

% Project folder
cfg.dir.project = fullfile('projects', 'demo_sMRI');

% Machine settings
cfg.machine.name = 'rcca';
cfg.machine.param.crit = 'correl';

% Fake sMRI data dimensionality
cfg.data.nsubj = 1000;
cfg.data.X.nfeat = 120;
cfg.data.Y.nfeat = 100;

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 1;
cfg.frwork.flag = '_test2';

% Deflation settings
cfg.defl.name = 'generalized';

% Environment settings
cfg.env.comp = 'local';

% Number of permutations
cfg.stat.nperm = 100;

% Update cfg with defaults
cfg = cfg_defaults(cfg);

% Run analysis
main(cfg);

% Clean up analysis files to save disc space
cleanup_files(cfg);

%----- Visualization

% Set path for plotting and the AAL and BrainNet Viewer toolboxes
set_path('plot', 'aal', 'brainnet');

% Load res
res.dir.frwork = cfg.dir.frwork;
res.env.fileend = cfg.env.fileend;
res.frwork.level = 1;
res = res_defaults(res, 'load');

% Create AAL labels for fake sMRI data
BrainNet_GenCoord(which('AAL2.nii'), 'AAL2.txt');
T = readtable('AAL2.txt');
T.Properties.VariableNames([1:3 6]) = {'X' 'Y' 'Z' 'Index'}; % we will need only these variables
T.Label = [1:120]'; % we will just use a numberic label now
writetable(T(:,[1:3 6:7]), fullfile(cfg.dir.project, 'data', 'LabelsX.xlsx'));
delete AAL2.txt; % clean up

% Create labels for fake behavioural data
T = table([1:100]', [repmat({'Domain 1'}, 50, 1); repmat({'Domain 2'}, 50, 1)], 'VariableNames', {'Label' 'Category'});
writetable(T, fullfile(cfg.dir.project, 'data', 'LabelsY.xlsx'));

% Plot hyperparameter surface for grid search results
plot_paropt(res, {'X' 'Y'}, 1, 'trcorrel', 'correl');

% Plot data projections
plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', 1, 'teid', '2d_group');

% Plot ROI weights on a glass brain
res.roi.weight.sorttype = 'sign';
res.roi.weight.numtop = 20;
res.roi.out = 9000 + [reshape([1:10:81; 2:10:82], [], 1); reshape(100:10:170, [], 1)]; % remove cerebellum
plot_weight(res, 'X', 'roi', 1, 'brain_node');

% Plot behavioural weights as vertical bar plot
res.behav.weight.sorttype = 'sign';
res.behav.weight.numtop = 20;
plot_weight(res, 'Y', 'behav', 1, 'behav_vert');
