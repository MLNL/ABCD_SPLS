Here you can find a description of all possible settings of the fields and subfields of `res`. First patameter always indicates the default option.

## Analysis

These fields are obtained during analysis and saved into `res.mat`. Some of the fields are inherited from `cfg`. 

###  dir
Essential paths to your project, framework (subfields inherited from 
`cfg`, see [here](../cfg_defaults/#dir)) and the output folders of the
experiment such as grid search, permutations and main results. The results 
folder by default contains a summary results table and three mat files, one 
for the `res` file, one for the hyperparameters used for the models on 
the training set (or combined training and validation set when using grid 
search), and one for the outputs of these models (including e.g. weights 
and holdout/test correlations).

*   **.project** [*path*]
    
    full path to your project, such as 'PATH/TO/YOUR/PROJECT'
    
*   **.frwork** [*path*]
    
    full path to your framework, such as
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME'
    
*   **.grid** [*path*]
    
    full path to your grid search results, such as
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/grid/level<id>'
    
*   **.perm** [*path*]
    
    full path to your permutation testing results, such as
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/perm/level<id>'
    
*   **.res** [*path*]
    
    full path to your main results, such as
    'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/grid/level<id>'
    
###  frwork
Results-orinted details of framework with different subfields as in `cfg`.

*   **.level** [*int*]
    
    level of the multivariate associative effect in the iterative
    calculation process (often called 'mode' in the CCA literature)
    
*   **.split.all** [*int or numeric array*]
    
    all splits at the current level
    
*   **.split.nall** [*int*]
    
    number of all splits at the current level
    
*   **.split.sig** [*int or numeric array*]
    
    all splits at the current level that passed significance
    
*   **.split.best**
    
    best split based on the criterion defined by cfg.defl.crit (for details,
    see [here](../cfg_defaults/#defl))
    
###  stat
Results of statistical inference with some subfields inherited from `cfg`.
For further details on the type of statistical inferences, see the 
description [here](../cfg_defaults/#stat).

*   **.nperm** [*int*]
    
    number of permutations
    
*   **.split.pval** [*int or numeric array*]
    
    uncorrected p-values of the statistical inference within splits (one 
    p-value per split)
    
    of note, in case of 'omnibus' hypothesis the associative effect is
    significant if any of the p-values are smaller than 0.05 / number of
    splits
    
*   **.overall.pval** [*int*]
    
    p-value of the statistical inference across splits
    
    of note, this is not provided for the statistical inference with
    'omnibus' hypothesis as that requires only a Bonferroni correction but
    no p-values are calculated across splits
    
###  env
Computation environment with the 'fileend' and 'save' subfields inherited
from `cfg`. For further details see [here](../cfg_defaults/#env).

*   **.fileend** [*char --> '_1'*]
    
    suffix at the end of each file saved in the framework folder whilst
    running the experiment on a cluster
    
    for file storage efficiency and easier data transfer, we suggest to use
    'cleanup_files.m' after an experiment is completed which deletes the
    unnecessary copies of the same file and replaces the 'fileend' to the
    default value of '_1'
    
*   **.save.compression** [*boolean --> 0*]
    
    defines if files are saved with or without compression
    
    of note, loading an uncompressed file can be faster for very large data
    files
    
##  Visualization

These fields are for visualization. They are added to res only temporarily and they are not saved to `res.mat`.

###  gen
General options for plotting. We recommend using 'interactive' file 
selection when new to plotting results to be able to understand what 
files are needed for the specific plots. Later, especially when wishing 
to automatize plots, it might be convenient to use 'none' file selection 
to avoid the interactive pop-up window and the files can be easily 
controlled/provided by setting the appropriate fields (e.g. 'file.label').

*   **.selectfile** [*'none', 'interactive'*]
    
    file selection using a wrapper function over the select_file function
    of [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/download/)
    
*   **.weight.flip** [*boolean --> false*]
    
    choice of flipping the weights, i.e. changing their sign
    
*   **.weight.type** [*'weight', 'correlation'*]
    
    type/interpretation of weight, i.e. how much each feature/variable
    contributes to the associative effect
    
    'weight' refers to the model weights read from `model.mat`, which is
    most often used in the PLS literature
    
    'correlation' refers to the correlation between the input
    features/variables and the latent variables/projections (i.e., brain
    and behavioural scores), which is most often used in the CCA literature
    
###  data
Subfields of 'fname' inherited from `cfg`. For further details see
[here](../cfg_defaults/#data).

*   **.X.fname, .Y.fname, .C.fname** [*filepath --> 'X.mat', 'Y.mat', 'C.mat'*]
    
    file with full path to data X, Y, C
    
###  param
Options for plotting hyperparameter optimization results from grid 
search. For the plotting function, see [plot_paropt](../plot_paropt).

*   **.xscale, .yscale** [*'lin', 'log'*]
    
    scale for x, y axis
    
    for RCCA, a logarithmic scale is recommended
    
    for SPLS, a linear scale is recommended
    
###  proj
Options for plotting projections of data (i.e. scores/latent variables).
For the plotting function, see [plot_proj](../plot_proj).
In this scatter plot each dot is a subject and as the axes are latent
variables, it is also called as latent space plot. Most often, we plot 
brain score vs. behaviour score for a specific level (i.e., associative 
effect). However, it is possible to plot the latent space across multiple 
levels (and averaged over modalities in a given level after 
standardization). The latent space can be colour-coded by a continuous
variable used as a colormap or a discrete variable with different colours
for the different groups of data. In this case, a label file and a
corresponding data file should be provided.

*   **.xlabel, .ylabel** [*char --> 'Brain score', 'Behavioural score'*]
    
    label for x, y axis
    
*   **.xlim, y.lim** [*numeric array --> NaN*]
    
    limit for x, y axis similar to MATLAB's built-in 'xlim', 'ylim'
    
*   **.file.label** [*filepath --> 'LabelsY.xlsx'*]
    
    label file with full path for additional colormap/group information
    
    label file and data file (see below) should be corresponding to each
    other, i.e. row i in label file (without header) corresponds to column
    i in data file
    
*   **.file.data** [*filepath --> 'Y.mat';*]
    
    data file with full path for additional colormap/group information
    
    label file and data file (see above) should be corresponding to each
    other, i.e. row i in label file (without header) corresponds to column
    i in data file
    
*   **.flip** [*boolean --> false*]
    
    choice of flipping the weights, i.e. changing their sign
    
*   **.multi_level** [*boolean --> 0*]
    
    choice for multi-level projection plots, i.e. averaging across
    modalities
    
###  behav
Weight postprocessing options, label file and figure settings for 
plotting weights of labelled behavioural data as horizontal or vertical 
bar plots. For the general plotting function, see
[plot_weight](../plot_weight).

*   **.weight.filtzero** [*boolean --> 1*]
    
    postprocess weights removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
    
    postprocess weights by number of top weights
    
    'Inf' refers to including all weights
    
*   **.weight.sorttype** [*'sign', ' ', 'abs'*]
    
    postprocess weights by sorting them in descending order
    
    'sign' sorts both positive and negative weights in descending order 
    (i.e., as if they were two independent lists)
    
    'abs' sorts weights based on absolute value
    
    '' refers to no sorting
    
*   **.weight.cutlabels** [*boolean --> 1*]
    
    shorten labels that are too long
    
*   **.file.label** [*filepath --> 'LabelsY.xlsx'*]
    
    label file with full path for Y data
    
*   **.label.maxchar** [*int --> Inf*]
    
    maximum number of characters for label names in figure
    
    of note, use it when some of the labels are too long to display on the
    figure setting it to e.g. 50
    
###  conn
Options for plotting connectivity data e.g. from resting-state fMRI. For 
the general plotting function, see [plot_weight](../plot_weight) and for 
a template plotting connectivity data, see [here](../template_plot_conn).
As brain data is in concatenated format (subject x feature matrix) and it 
might not include all pairwise connections, a mask file is necessary to 
be able to reshape the data to node x node format. A node can be an
anatomical or functional Region of Interest (ROI) or an Independent 
Component Analyis (ICA) component. In the previous cases we recommend 
using [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) to plot 
weights on a glass brain as edges or summarized as nodes (for settings, 
see [here](#brainnet)). In the latter case, we recommend using a 
schemaball plot (see plot_weight_brain_schemaball.m). It is also possible 
to summarize the weights as connections within/between modules and we use 
MATLAB's built-in imagesc function to plot the results.

*   **.file.mask** [*filepath --> 'mask.mat'*]
    
    mask file with full path for connectivity data
    
    'mask' variable is a matrix with booleans for the connections that are
    selected for brain data after concatenation (e.g. lower triangular part) 
    
*   **.weight.filtzero** [*boolean --> 1*]
    
    postprocess weights removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
    
    postprocess weights by number of top weights
    
    'Inf' refers to including all weights
    
*   **.weight.sorttype** [*'sign', ' ', 'abs'*]
    
    postprocess weights by sorting them in descending order
    
    'sign' sorts both positive and negative weights in descending order 
    (i.e., as if they were two independent lists)
    
    'abs' sorts weights based on absolute value
    
    '' refers to no sorting
    
*   **.weight.type** [*'auto', 'strength'*]
    
    postprocess weights by multiplying them by the sign of the population
    mean in the original data
    
    'auto' does no postprocessing
    
    'strength' does postprocessing
    
*   **.weight.sign** [*'all', 'positive', 'negative'*]
    
    postprocess weights by selecting a subset of them (e.g. with positive
    or negative sign)
    
    'all' does no postprocessing
    
*   **.module.disp** [*boolean --> 0*]
    
    choice to display module weights in command line
    
*   **.module.type** [*'average', 'sum'*]
    
    calculate the average or sum of weights within/between modules
    
*   **.module.norm** [*'none', 'global', 'max'*]
    
    normalize module weights...
    
    'none' does no normalization
    
*   **.file.label** [*filepath --> 'LabelsX.xlsx'*]
    
    label file with full path for connectivity data
    
###  vbm
Options for plotting Voxel Based Morphometry (VBM), i.e. voxel-wise data.
For the general plotting function, see [plot_weight](../plot_weight) and 
for a template plotting VBM data, see [here](../template_plot_vbm).
As brain data is in concatenated format (subject x feature matrix), a
mask file is necessary to be able to write the weights in nii format.
By default, the brain weights are assumed to be in MNI space, however, 
normalization is possible if given a template/source image and a rigid
body transformation matrix to reorient the image to approximately match 
the MNI template space (otherwise, if the weight image is way out of MNI 
space, the normalization fails). We use [BrainNet
Viewer](https://www.nitrc.org/projects/bnv/) to plot the cortical weights
on a glass brain (for settings, see [here](#brainnet)). It is also possible to plot the 
brain weights separately for cortex and subcortex, in which case a nii 
atlas with a 
corresponding label file (in tabulated format with a column defining 
cortex/subcortex) is needed (see e.g.
[AAL](https://www.gin.cnrs.fr/en/tools/aal/)) to be able to obtain 
information about the cortical/subcortical position of each voxel. For 
plotting subcortical regions, [Nilearn](https://nilearn.github.io/) 
should be installed on the machine.

*   **.file.mask** [*filepath --> 'mask.nii'*]
    
    mask file with full path for VBM data
    
    nii file includes an image with booleans for the voxels that are
    selected for brain data after concatenation
    
*   **.file.MNI** [*filepath --> 'T1_1mm_brain.nii'*]
    
    template/source image with full path for normalization
    
*   **.transM** [*numeric array --> eye(4)*]
    
    rigid body transformation matrix to reorient the weight image to MNI 
    space before normalization occurs
    
    of note, for the current ABCD analyses it is 
    [1 0 0 118.6; 0 1 0 -128.6; 0 0 1 -63.3; 0 0 0 1]
    
*   **.file.atlas.img** [*filepath --> 'AAL2.nii'*]
    
    atlas nii file in MNI space for definition of cortex/subcortex
    
    of note, full path is not necessary if file is in path or 'aal' folder 
    in the `external` folder
    
*   **.file.atlas.label** [*filepath --> 'Labels_AAL2.xlsx'*]
    
    atlas label file for for definition of cortex/subcortex
    
    of note, full path is not necessary if file is in path or 'aal' folder 
    in the `external` folder
    
*   **.subcortex** [*boolean --> 0*]
    
    choice to plot subcortical volume separately and remove it from 
    cortical plot
    
*   **.file.nilearn.MNI** [*filepath --> 'MNI152_T1_1mm_brain.nii'*]
    
    MNI template file with full path for background image in Nilearn
    
    of note, only relevant if 'res.vbm.subcortex' is 1
    
###  roi
Weight postprocessing options and label file for plotting weights of 
Region Of Interest (ROI) data. For the general plotting function, see 
[plot_weight](../plot_weight) and for a template plotting ROI data, see 
[here](../template_plot_roi). The settings here refer to genuine 
ROI data entered into the experiment. Post-hoc ROI summarization will be 
added as a feature to VBM data later.

*   **.weight.filtzero** [*boolean --> 1*]
    
    postprocess weights removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
    
    postprocess weights by number of top weights
    
    'Inf' refers to including all weights
    
*   **.weight.sorttype** [*'sign', ' ', 'abs'*]
    
    postprocess weights by sorting them in descending order
    
    'sign' sorts both positive and negative weights in descending order 
    (i.e., as if they were two independent lists)
    
    'abs' sorts weights based on absolute value
    
    '' refers to no sorting
    
*   **.file.label** [*filepath --> 'LabelsX.xlsx'*]
    
    label file with full path for ROI data
    
###  simul
Weight postprocessing options for plotting simulation results. For the 
general plotting function, see [plot_weight](../plot_weight) and 
for an example plot, see [here](../../example/#weights).

*   **.weight.filtzero** [*boolean --> 0*]
    
    postprocess weights removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
    
    postprocess weights by number of top weights
    
    'Inf' refers to including all weights
    
*   **.weight.sorttype** [*' ', 'sign', 'abs'*]
    
    postprocess weights by sorting them in descending order
    
    '' refers to no sorting
    
    'sign' sorts both positive and negative weights in descending order 
    (i.e., as if they were two independent lists)
    
    'abs' sorts weights based on absolute value       
    
###  brainnet
Settings for [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) for 
automatic plotting of brain weights on a glass brain and saving it as 
bitmap image in file. Make sure that your data and the glass brain are in 
the same space, by default BrainNet Viewer uses MNI space. The options 
file  includes configurations for BrainNet Viewer to use your preferred 
styling. In case such file does not exist BrainNet Viewer uses its 
default settings. The BrainNet Viewer GUI is not closed after the 
visualization is completed, so at first usage you can manually edit your 
preferred settings and save them as options file for future usage.

*   **.file.surf** [*filepath --> 'BrainMesh_ICBM152.nv'*]
    
    brain mesh (glass brain) file with full path in external folder
    
    of note, full path is not necessary if file is in path or 'brainnet' 
    folder in `external` folder
    
*   **.file.options** [*filepath --> 'options.mat'*]
    
    options file with full path for BrainNet configuration
    

