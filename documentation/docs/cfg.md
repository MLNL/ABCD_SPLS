Here you can find a description of all possible settings of the fields and subfields of `cfg`. First parameter always indicates the default option.

###  dir
Essential paths to your project, framework and processed data. The project folder should include a 'data' folder where all the input data are stored.

*   **.project** [*path*]
    
    full path to your project, such as 'PATH/TO/YOUR/PROJECT'
    
*   **.frwork** [*path*]
    
    full path to your specific framework, such as
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME'
    
    analysis name is generated from machine name and framework settings (including flag)
    
*   **.load** [*path*]
    
    full path to your processed data, such as 
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/load'
    
    it stores information about data processing for computational efficiency
    including preprocessing (e.g. mean and scale of features, betas for 
    deconfounding) and results of PCA if CCA/RCCA is used
    
###  machine
Algorithm to be used, its settings and information about hyperparameter 
optimization. Please make sure that you are familiar with the
hyperparameter settings of the chosen algorithm, e.g. range and scale of
hyperparameter values for grid search or number of PCA components. We also strongly encourage to use RCCA, SPLS or PCA-CCA as CCA and PLS are likely to overfit the data and/or loose sensitivity unless the number of examples greatly exceed the number of features. 

*   **.name** [*'cca', 'rcca', 'pls', 'spls'*]
    
    name of the algorithm
    
    PCA is implicitly used in CCA/RCCA algorithms, so set machine name to 
    CCA if you want to perform PCA-CCA analysis
    RCCA smooths between CCA and PLS defined by the L2 regularization
    hyperparameter (L2=0 for CCA, L2=1 for PLS)
    
*   **.metric** [*cell array*]
    
    metrics that are used to evaluate the machine including 'correl' 
    (test correlation), 'covar' (test covariance), 'simwx' (similarity of X 
    weights), 'simwy' (similarity of Y weights), 'unsuc' (number of 
    unsuccessful convergence for SPLS)
    
*   **.param.crit** [*'correl', 'correl+simwxy', 'correl+simwx+simwy', 'covar', 'freq'*]
    
    criterion for hyperparameter selection, we recommend using 'correl' or
    'correl+simwxy'
    
    'correl+simwxy' uses a 2D distance metric based on correlation and 
    averaged similarity of weights
    
    'correl+simwx+simwy' uses a 3D distance metric based on correlation and 
    similarity of X weights and Y weights
    
*   **.param.name** [*cell array*]
    
    name of the hyperparameters, including 'L1x' and 'L1y' for L1
    regularization (for sparsity), 'L2x' and 'L2y' for L2 regularization
    (for stability), 'PCAx' and 'PCAy' for number of PCA components
    
    we note that L2 regularization can be used together with PCA
    
*   **.param.type** [*'factorial', 'matched'*]
    
    defines if grid search for hyperparameters should be a factorial
    combination of all hyperparameters or matching correspoding
    hyperparameters (in this case all should have the same length)
    
*   **.param.L1x, .param.L1y** [*int or numeric array*]
    
    amount of L1 regularization for data X, Y when using SPLS
    
    if not provided, the function generates a linearly scaled numeric array
    using the number and range of hyperparameters (see below)
    
*   **.param.nL1x, .param.nL1y** [*int --> 10*]
    
    number of L1 regularization hyperparameters for data X, Y used in grid 
    search
    
*   **.param.rangeL1x, .param.rangeL1y** [*numeric array*]
    
    range of L1 regularization hyperparameters for data X, Y used in grid 
    search
    
    for L1 regularization to be active, range should be between 1 and 
    square root of the number of features, otherwise PLS is used
    
*   **.param.L2x, .param.L2y** [*int*]
    
    amount of L2 regularization for data X, Y when using RCCA
    
    if set to 0 RCCA performs CCA, if set to 1 RCCA performs PLS
    
    use 1 - inverse of the number of features for a decent amount 
    of regularization
    
    if not provided, the function generates a logarithmically scaled 
    numeric array using the number and range of hyperparameters (see below)
    
*   **.param.nL2x, .param.nL2y** [*int*]
    
    number of L2 regularization hyperparameters for data X, Y used in grid 
    search
    
*   **.param.rangeL2x, .param.rangeL2y** [*numeric array --> [0 1]*]
    
    range of L2 regularization hyperparameters for data X used in grid 
    search
    
*   **.param.PCAx, .param.PCAy** [*int*]
    
    number of PCA components for data X, Y
    
    if not provided, the function uses .eig.tol to deal with rank-deficiency
    
*   **.param.VARx, .param.VARy** [*int --> 0.99*]
    
    retained variance during PCA step of CCA/RCCA
    
*   **.eig.tol** [*int --> 1e-10*]
    
    eigenvalues smaller than tolerance are removed during SVD step of 
    CCA/RCCA 
    
*   **.eig.varex** [*float*]
    
    explained variance kept during the SVD preprocessing step of CCA/RCCA 

*   **.tol** [*int --> 1e-5;*]
    
    tolerance during SPLS convergence
    
*   **.maxiter** [*int --> 100*]
    
    maximum number of iterations during SPLS convergence
    
###  frwork
Details of framework with two main approaches. Divide data to training 
and test sets using single or multiple holdouts (see [Monteiro et al
2016](https://doi.org/10.1016/j.jneumeth.2016.06.011)) by randomly 
subsampling subjects. Otherwise, use a permutation approach without any data splitting (see [Smith et al 2015](https://doi.org/10.1038/nn.4125)). The default values will change depending on the type of the framework.

*   **.name** [*'holdout', 'permutation'*]
    
    type of the framework
    
*   **.flag** [*char*]
    
    a short name/flag to be appended to your analysis name which will then 
    define the framework folder, see cfg.dir.frwork
    
*   **.split.nout** [*int*]
    
    number of outer splits/folds
    
*   **.split.propout** [*float --> 0.2*]
    
    proportion of holdout/test set in 'holdout' framework
    
    higher value is recommended for samples n<500 (e.g. 0.2-0.5), and 
    lower value (e.g. 0.1) should be sufficient for samples n > 1000 
    
    set to 0 for 'permutation' framework
    
*   **.split.nin** [*int*]
    
    number of inner splits/folds
    
*   **.split.propin** [*float --> 0.2*]
    
    proportion of validation set in 'holdout' framework
    
*   **.split.EBcol** [*int or numeric array*]
    
    indexes of columns in EB matrix to use for defining exchangeability
    blocks for data partitioning
    
    if multi-level blocks are provided, most likely you need to provide 2 
    columns here as e.g. no cross-over across different family types 
    (column 2) but shuffling across families (column 3) within same family 
    type are allowed, in other words, families should be in the same data
    split (training or test)
    
###  defl
Deflation methods and strategies. For an in-depth introduction to deflation
(i.e. iterative solution of CCA/PLS) and its different types, see 
[Home](../). As most of the time we use different outer splits/folds of 
the data, it is of interest which split to use as the basis for deflation.
A natural choice is to use the weights of the best data split (e.g. with 
highest holdout correlation and similarity across weights) and deflate 
all other splits with it. Other options are e.g. to deflate significant 
splits either by using the weights of the best split or use all splits 
independently.

*   **.name** [*'generalized', 'pls-projection', 'pls-modeA', 'pls-regression'*]
    
    type of deflation
    
*   **.crit** [*'correl', 'pval+correl', 'correl+simwxy', 'correl+simwx+simwy', 'none'*]
    
    criterion to define best (i.e. most representative) data split to be 
    used for deflation
    
    if 'none' set then each split is deflated by itself (i.e. they are 
    treated independently) 
    
*   **.split** [*'significant', 'all'*]
    
    selection of splits for deflation, i.e. whether all splits are deflated
    or only the significant ones (the latter approach needs significance 
    testing within splits)
    
###  stat
Statistical inference. Our approach is to make inference about the 
multivariate associative effect and not necessarily about specific model
weights unless sparsity is used to select features/variables. Testing the 
generalizability of the models (i.e., using test correlations) is one of 
our key recommendations. Furthermore, we advise to check the robustness 
(i.e., how many data splits are significant) and the stability (i.e.,
similarity of the weights) of the models and not just rely purely on 
p-values. For multiple holdout framework, we support only the statistical inference based on an omnibus hypothesis proposed by [Monteiro et al
2016](https://doi.org/10.1016/j.jneumeth.2016.06.011) which performs
statistical inference both within and across splits.

*   **.nperm** [*int*]
    
    number of permutations
    
*   **.split.crit** [*'correl', 'none'*]
    
    statistical inference within splits (i.e., 1 permutation test for each 
    data split) based on given criterion
    
    if 'none' is set, no inference is performed here
    
    we support only correlation based inference at the moment
    
*   **.overall.crit** [*'none', 'correl', 'correl+simwxy', 'correl+simwx+simwy'*]
    
    statistical inference across splits (i.e. 1 permutation test across all
    data splits) based on given criterion
    
    if 'none' is set, no inference is performed here
    
    we highlight that for omnibus hypothesis (see [Monteiro et al
    2016](https://doi.org/10.1016/j.jneumeth.2016.06.011)) you need to set 
    stat.split.crit = 'correl', stat.overall.crit = 'none' as this approach 
    automatically performs inference across splits using Bonferroni
    correction
    
*   **.EBcol** [*int or numeric array*]
    
    indexes of columns in EB matrix to use for defining exchangeability
    blocks for restricted permutations
    
###  data
Details of the data and its properties including modailities, 
dimensionality, block structure. The preprocessing strategy and the 
filenames with full path are also defined here. We highlight that when
the data comes in a preprocessed format (e.g. imputed, z-scored), 
inference using holdout framework might be invalid (i.e., p-values 
inflated). We also highly recommend to quality check your data before 
entering it into the toolkit to remove data with too many missing values,
outliers or with highly imbalanced reponses (e.g. using qc_data.m).

*   **.block** [*boolean*]
    
    defines if there is a block structure in the data, i.e. examples are not 
    independent of each other 
    
*   **.preproc** [*cell array --> {'impute', 'deconf', 'zscore'}*]
    
    data preprocessing strategy including missing value imputation,
    z-scoring and deconfounding
    
    of note, data preprocessing is calculated on training data and applied
    to test data if 'holdout' framework used 
    
*   **.mod** [*cell array*]
    
    data modalaties to be used (e.g. {'X' 'Y'})
    
*   **.X.fname, .Y.fname, .C.fname** [*filepath --> 'X.mat', 'Y.mat', 'C.mat'*]
    
    file with full path to data X, Y, C
    
*   **.X.impute, .Y.impute, .C.impute** [*'median'*]
    
    strategy to impute missing values
    
    if there are missing values in the data, the proportion of missing
    values is displayed in the command line during data preprocessing
    
*   **.X.deconf, .Y.deconf** [*standard, none*]
    
    type of deconfounding
    
    'none' could be used if deconfounding is needed for the other modality
    but not the one where 'none' is set
    
*   **.X.nfeat, .Y.nfeat** [*int*]
    
    number of features/variables in data X, Y
    
*   **.nsubj** [*int*]
    
    number of subjects/examples
    
###  env
Computation environment can be either local or a cluster. In the latter 
case, we currently support SGE or SLURM scheduling systems. There is an 
important technical issue when runnning experiments on a cluster using 
multiple nodes/jobs. MATLAB is able to load the same file from different 
nodes but not able to save in parallel from different nodes. We developed
a system where each node saves different physical copies of the same file 
when saving exactly at the same time, however, once a file is saved 
completely other nodes are able to access it. The different copies of the 
files are distinguished by the identifier of the nodes which is obtained 
from the scheduling system, saved in 'cfg.env.fileend' then appended to 
the end of the name of the file when saving.

*   **.comp** [*'local', 'cluster'*]
    
    computation environment
    
*   **.commit** [*char*]
    
    SHA hash of the latest commit in git (i.e., toolkit vesion) for
    reproducibility
    
*   **.OS** [*'mac', 'unix', 'pc'*]
    
    operating system (OS)
    
    this information is used when transferring files between OS and
    updating paths (see cfg.dir fields and update_dir.m)
    
*   **.fileend** [*char --> '_1'*]
    
    suffix at the end of each file saved in the framework folder whilst
    running the experiment on a cluster
    
    for file storage efficiency and easier data transfer, we suggest to use
    'cleanup_files.m' after an experiment is completed which deletes the
    unnecessary copies of the same file and replaces the 'fileend' to the
    default value of '_1'
    
*   **.save.compression** [*boolean --> 1*]
    
    defines if files are saved with or without compression
    
    of note, loading an uncompressed file can be faster for very large data
    files

