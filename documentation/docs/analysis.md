## Dependencies

The only dependency the analysis has is the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM), which is needed for permutation testing.

In short, the PALM toolbox allows to use restricted permutations based on the exchangeability block structure of the data (i.e., which examples are allowed to be exchanged or not). The exchangeability block structure is also used for stratified partitioning of the data (i.e., some examples are kept in the same data splits). For further information on exchangeability blocks, see [Winkler et al 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM). 

## Inputs

The main inputs of the analysis:

- a `cfg` variable including all the settings of your analysis,
- the input data matrices in `.mat` files.

Use the `cfg_defaults` function to initialize and update all necessary settings to your `cfg`. `cfg` is a MATLAB structure that contains the following fields:

- `dir`: paths to your project, analysis and the outputs of preprocessing,
- `machine`: name and other details of the CCA/PLS model, e.g., hyperparameter settings,
- `frwork`: details of the framework, e.g., number of data splits,
- `defl`: name and details of the deflation method,
- `stat`: details of the statistical inference, e.g., number of permutations,
- `data`: details of the data e.g., dimensionality,
- `env`: details of the computation environment, e.g., local computer or cluster.

To get a more detailed description of the fields and subfields of `cfg`, please see [here](../cfg).

The data matrices should be stored in a specific format:

- variable `X` in `X.mat` storing one of the data modalities,
- variable `Y` in `Y.mat` storing the other data modality,
- in both cases, rows correspond to examples/samples and columns correspond to variables/features.

In addition, you can provide two other data matrices, which should be in a similar format:

- variable `C` in `C.mat` for confounds with  rows corresponding to examples/samples and columns corresponding to confounds,
- variable `EB` in `EB.mat` for defining exchangeability block structure of the data with rows corresponding to examples/samples and columns corresponding to exchangeability blocks.

The `EB` matrix can be used for stratified partitioning of the data and/or using restricted permutations. For instance, you can use this to provide the genetic dependencies of your data (e.g., twins, family structure) or different cohorts (e.g., healthy vs. depressed sample). For details on how to create the `ÈB` matrix, see [Winkler et al 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM).

All the `.mat` files above should be stored in a dedicated `data` folder discusses [here](../getting_started/#overview).

## Outputs

As illustrated in the figure below, the analysis can be divided into eight operations.

<p align="center">
   <img src="../figures/flowchart.png" width="415" height="284">
</p>

Here we describe these operations and the output files they create:

1. Initialization: setting and saving the analysis configuration into `cfg*.mat`.
2. Data splitting: creating training and test sets of the data and saving outputs into `outmat*.mat` (for outer data splits) and `inmat*.mat` (for inner data splits).
3. Preprocessing:
    - imputing, z-scoring and deconfounding the data and saving outputs into `preproc*.mat`,
    - Singular Value Decomposition (SVD) of the data and saving outputs into `svd*.mat`.  
4. Grid search: hyperparameter optimization using a grid search and saving outputs into `grid*.mat`.
5. Training/testing:
    - setting hyperparameters and saving these into `param*.mat`,
    - fitting models on training sets, assessing the model weights on test sets and saving outputs into `model*.mat`.
6. Permutation test: permutation testing and saving outputs into `perm*.mat`.
7. Saving results: evaluating significance of results and saving outputs into `res*.mat` as well as the summary of results into `results_table.txt`.
8. Deflation: deflation of the data and repeating steps 4-8. for each associative effect. This operation doesn't save any output files.


