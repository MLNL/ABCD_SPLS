In the following paragraph, we will go through a simple example, run an analysis and plot the results. We will be using Sparse Partial Least Squares (SPLS) in a multiple holdout framework. Our settings will be added to structures called `cfg` and `res` that will control the behaviour of the analysis and the results, respectively.

!!! note "Warning"
    We will provide some example data in the future that everyone can use in this example. Until that point, please make sure to have some data ready that you can use here. A more detailed description of how the data should look like will come shortly.

## Basic analysis

First, make sure to run `set_path` to add the necessary paths of the toolkit to your MATLAB path.

```matlab
set_path
```

### Project Folder

Next, we specify the folder to our project. Make sure to specify the correct path. This folder will contain a `data` and a `framework` folder. Unless you run simulations, you should provide your data matrices (`X.mat`, `Y.mat`) in your data folder. In the following, we will assume that mat files and their content always has the same naming convention, i.e. `X` variable in `X.mat`. You can provide a data matrix for confounds (`C.mat`) which will be regressed out from both of your `X` and `Y` data. You can also provide a matrix (`EB.mat`) which defines the exchangeability block structure of your data and will be used for stratified partitioning of the data (i.e., inner/outer splits) and restricted permutations. For instance, you can use this to provide the genetic dependencies of your data (e.g. twins, family structure) or different cohorts (e.g. healthy vs. depressed sample). For details on how to create the `ÈB` matrix, see [Winkler et al 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM).

The `framework` folder will be automatically created by the toolkit in running time and will be filled up with all the results of your specific experiment. You can run different experiments on the same data, each having their own folder within `framework`, but we advise to create a new project folder once you change your data itself.

```matlab
cfg.dir.project = '/PATH/TO/YOUR/PROJECT/';
```

### Algorithm

Now, we configure the algorithm we would like to use. We set the `machine.name` parameter to 'rcca' for Regularized CCA (RCCA). To select the best regularization hyperparameter (i.e. L2 regularization in case of RCCA), we will use test correlation as criterion (measuring the generalizability of the RCCA models across the inner loop splits).

```matlab
% Machine settings
cfg.machine.name = 'rcca';
cfg.machine.param.crit = 'correl';
```

For more information on the machines and the regularization parameter choices, see [here](../mfiles/cfg_defaults/#machine) or the [Home](../) page and consult the references there.

### Environment
Next, we set the computational environment for the toolkit. As RCCA is computationally efficient, often we can run it locally on our computer.

```matlab
% Environment settings
cfg.env.comp = 'local';
```

### Framework

Next, we set the framework to `holdout` to perform a multiple holdout approach. The `frwork.flag` parameter just defines a custom name for this analysis. Make sure to give it a name that will help you organize different analyses you might run on your data.

```matlab
% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.flag = '_corr';
```

For further details on the framework choices, see [here](../mfiles/cfg_defaults/#frwork).

### Deflation

As we are optimizing the L2 regularization parameter of the RCCA model for each associative effect separately, we will need to remove the significant effects already found in the data (called deflation) to be able to find new associative effects. In this example, we will use CCA-projection deflation on all outer splits of the data using the model weight of the best split. For the definition of `best`, the value of the field `cfg.defl.crit` is used as a metric, e.g. highest holdout correlation.

```matlab
% Deflation settings
cfg.defl.name = 'generalized';
cfg.defl.crit = 'correl';
cfg.defl.split = 'all';
```

For more information about the theory behind deflation, see [here](../#introduction-to-iterative-solution-of-ccapls-models), for more about the settings, see [here](../mfiles/cfg_defaults/#defl).

### Statistical Inference

Finally, we will need to define how the statistical significance test is performed. This can either be done separately for each split or combined across splits. In this example, we will do a so-called omnibus test based on the holdout correlations defined by `cfg.stat.split.crit`. For that, a permutation test is performed for each outer split and the p-values are Bonferroni corrected for multiple comparisons. Thus the null hypothesis states that none of the outer splits are significant, thus rejecting this hypothesis means that there is a significant effect in at least on of the outer splits.

```matlab
% Statistical inference
cfg.stat.split.crit = 'correl';
cfg.stat.overall.crit = 'none';

% Number of permutation tests
cfg.stat.nperm = 100;
```

For further details on the statistical inference, see [here](../mfiles/cfg_defaults/#stat).

### Run Analysis

To run the analysis, we simply update our `cfg` structure to add all necessary default values that we didn't explicitly define and then run the `main` function.

```matlab
% Update cfg with defaults
cfg = cfg_defaults(cfg);
main(cfg);
```

### Basic plotting

Now that we've run our first analysis, let's plot some of the results. Most of the times, this is simply done by configuring plotting specific details in the `res` structure and then passing this structure as input to the [plot_weight](../mfiles/plot_weight/) or [plot_proj](../mfiles/plot_proj/) function with some additional parameters the define the plot type.

Before we can do any plotting, we need to make sure that we've called `set_path('plot')` to add the plotting folder.

```matlab
% Set path with plotting folder
set_path('plot');
```

Additionally, we will need to load the `res` structure, which includes some of the results and the paths to the specific results. In general, we advise you to plot your results on a local computer as it is often cumbersome and slow in a cluster environment. In this case `update_dir` should be called just before `res_defaults`. Whenever you call `res_defaults`, all necessary default values will be loaded  to the `res` structure.

```matlab
% Required fields
res.dir.frwork = '/PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/';
res.frwork.level = 1;
res.env.fileend = '_1';

% Initialize res
res = res_defaults(res, 'load');
```
To plot the latent space that has been learnt by the model, simply run `plot_proj`. As first argument, we need to pass the `res` structure that holds all necessary information on where to find the results. Then, we can specify the data modalities as cell array that will be used for the plotting. The next parameter defines the associative effect ('level') that should be used for the plot. In this example, we plot the latent space (projections) of X and Y for the first associative effect. We set the fourth input parameter to 'osplit' so that the training and test data of the outer split will be used for the plot. The following parameter defines which split is used (in this case we use the first split). The second to last input parameter can be used to color code different groups of the data. Please see the documentation of [plot_proj](../mfiles/plot_proj/) for more details. The last parameter defines the plot type. In this example, we will create a simple 2d plot.

```matlab
% Plot data projections
plot_proj(res, {'X' 'Y'}, 1, 'osplit', 1, 'none', '2d')
```

Plotting weights will heavily depend on the kind of data that has been used in the analysis. For that reason, we only provide a very basic weight plot in this example that creates a stem plot.

```matlab
% Plot X weights as stem plot
plot_weight(res, 'Y', 'simul', 1, 'stem');

% Plot Y weights as stem plot
plot_weight(res, 'X', 'simul', 1, 'stem');
```

For further details on plotting weights, see [plot_weight](../mfiles/plot_weight/) and the plotting templates.
