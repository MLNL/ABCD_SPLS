## Dependencies

The visualization functions can have several dependencies.

In general, if you want to use an interactive file selection, (i.e., pop-up dialog box to choose input files when neeed), you need [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/download/). You also need SPM if you work with a mask or an atlas. For details on these, please see below.

If you want to plot brain weights on a glass brain, you need [BrainNet Viewer](https://www.nitrc.org/projects/bnv/). We use BrainNet Viewer in the toolkit for plotting structural MRI weights either at the voxel or ROI level as well as fMRI connectivity weights either at the edge level or summarized by nodes. If you provide an `options.mat` file for BrainNet Viewer then the toolkit automatically sets your configurations for the BrainNet figure. Otherwise, you need to do it manually on the BrainNet Viewer GUI.

We use [AAL](https://www.gin.cnrs.fr/en/tools/aal/) as our default atlas but feel free to use your own atlas if you wish so. In any case, be careful to have your data and atlas in the same space and with the same image dimensions.

## Inputs

The main input of the visualization is the `res` variable including all settings for your visualization. `res` has all the necessary paths to the outputs from  the analysis, so these `.mat` files will be automatically loaded according to the visualization needs and they will not be discussed any more.

Most likely you will also need 1-4 additional input files:

- label files: `.xlsx` files holding information about the features of your input data (or other features of additional data files for visualization),
- mask file: `.nii` file for structural MRI data and `.mat` file for functional MRI data defining the features that are present in your brain data,
- atlas file: `.nii` file defining the regions in your structural brain data,
- template files: `.nv` surface mesh file in BrainNet Viewer for overlaying your brain weights or `.nii` file to use as a source for normalization if your structural MRI data is not in MNI space,
- `.mat` files: additional data or other files for visualization.

Use the `res_defaults` function to add all necessary settings to your `res`. `res` is a MATLAB structure initialized during your analysis. Some of its fields are inherited from `cfg`, others contain information about the outputs and results of the analysis. For each associative effect in your analysis, one `res` structure is saved on the disc in a `res*.mat` file. During the visualization of your results, `res` stores the settings for the visualization, however, these are only temporarily added to `res` and not saved in the `res*.mat` file.

`res` ocontains the following fields obtained during the analysis:

- `dir`: paths to your project, analysis and main outputs,
- `frwork`: results oriented details of the framework,
- `stat`: detailed results of significance testing,
- `env`: details of the computation environment.

`res` contains the following fields for data visualization:

- `gen`: general options,
- `data`: full paths to the data,
- `param`: figure options for plotting the grid search results, 
- `proj`: options for plotting the projections of data,
- `behav`: options for plotting behavioural weights,
- `conn`: options for plotting fMRI connectivity weights,
- `vbm`: options for plotting voxel-level structural MRI weights,
- `roi`: options for plotting region-level structural MRI weights,
- `simul`: options for plotting weights of simulated data,
- `brainnet`: options for using [BrainNet Viewer](https://www.nitrc.org/projects/bnv/).

To get a more detailed description of the fields and subfields of `res`, please see [here](../res).

Before turning to the description of the other input files, we introduce the plotting functions. The figure below illustrates all the high- and low-level plotting functions of the toolkit. Most users will use only the high-level functions, however, it is important to introduce the low-level functions as they are the ones defining the specific inputs.

<p align="center">
   <img src="../figures/functions.png" width="425" height="378">
</p>

The low-level functions are specified by the `func` argument of the high-level functions. For instance:

- to use the `plot_proj_2d_group` function, you need to call `plot_proj` with a `2d_group` argument,
- to use the `plot_weight_behav_horz` function, you need to call `plot_weight` with a `behav_horz` argument.

For a more detailed description of the high- and low-level functions, see the [outputs section](#outputs) below.

The label files hold information about the features in your input data or other data you might want to use for visualization. To be able to use label files, they need to contain certain variables. The first row of the label file should define the name of these variables, which then would be followed by its values in the corresponding columns. It is vital that you have the same order of values in your label file as your features in your corresponding data file to be able to match each feature with its label.

The mask files include a 2D matrix or a 3D image of booleans that define which features are included in your input data. For instance, you might have only grey matter voxels or a subset of all possible connections in your `X.mat` file. These mask files also allow to reshape your data into their original format, for instance, writing your structural MRI brain weights as a `.nii` file.

The atlas file includes a 3D image of integers that define regions in the brain. You might want to use it to select certain parts of the brain to visualize or to summarize your voxel-level weights at the regional level. To be able to use an atlas, it needs to be in the same space as your brain mask. By default, the toolkit uses the [AAL](https://www.gin.cnrs.fr/en/tools/aal/) atlas, which is in MNI space.

There are two template files in the toolkit. One is a surface mesh file that BrainNet Viewer uses for overlaying your brain weights onto. The other includes a 3D image, which is needed as a source image to normalize your structural brain weights to MNI space in case your input data is not already in MNI space.

There are some cases of using `.mat` files as inputs for visualization. These include additional data files, `options.mat` for BrainNet Viewer, `mask.mat` for fMRI connectivity data and the true model weights for simulated data. 
 
Now we go through of each low-level function and describe their inputs:

- `plot_proj_2d`: it does not requie any input file.
- `plot_proj_2d_cmap` and `plot_proj_2d_group`: it might require a data file and a label file to colour-code your plot by a continuous variable (`plot_proj_2d_cmap`) or groups (`plot_proj_2d_group`). However, you can also use `outmat*.mat` or `Y.mat` and its label file for these purposes. 
- `plot_weight_stem`: it does not require an input file by default. However, if you use simulated data and the true model weights are available as `.mat` files, you can overlay them on your stem plot.
- `plot_weight_behav_horz` and `plot_weight_behav_vert`: it requires a label file input, which should contain the following variables:
    - `Label`: name or label of your data features,
    - `Category`: category of your data features, e.g., quesitonnaire of item or domain of cognition.
- `plot_weight_behav_text`: it requires a label file, which should contain the following variable:
    - `Label`: name or label of your data features.
- `plot_weight_brain_cortex`: it requires a mask file in `.nii` format to define the voxels used as features in your input data. You might want to provide a template source file if your structural MRI data is not in MNI space. Alternatively, choose a BrainNet Viewer surface mesh that is in the same space as your data. 
- `plot_weight_brain_node`: it requires a label file, which should contain the following variables:
    - `X`, `Y` and `Z` coordinates of your regions (MNI coordinates by default),
    - `Label`: name or label of the regions,
    - `Index` (optional): index of the regions.
    - `Color` (optional): color of the region in the figure,
- `plot_weight_brain_conn_node`: it requires a mask file in `.mat` format and a label file. The mask should include a 2D connectivity matrix (each row/column representing a nodes) of booleans to define the connections used as features in your input data. The label file should contain the following variables:
    - `X`, `Y` and `Z` coordinates of your regions (MNI coordinates by default)
    - `Label`: name or label of region,
    - `Region`: network, module, lobe or any other large structure the region belongs to.
    - `Color` (optional): color of the region in the figure,
- `plot_weight_brain_edge`: it requires a mask file in `.mat` format and a label file. The mask should include a 2D connectivity matrix (each row/column representing a nodes) of booleans to define the connections used as features in your input data. The label file should contain the following variables:
    - `X`, `Y` and `Z` coordinates of your regions (MNI coordinates by default),
    - `Label`: name or label of the regions,
    - `Index`: index of the regions.
    - `Color` (optional): color of the region in the figure,
    - `Size` (optional): size of the region in the figure.
- `plot_weight_brain_module`: it requires a mask and label file inputs. The mask should include a 2D connectivity matrix (each row/column representing a nodes) of booleans to define the connections used as features in your input data. The label file should contain the following variable:
    - `Region`: module the region belongs to.

## Outputs

There are three high-level functions to visualize your results:

1. `plot_paropt`: it plots the grid search results of the hyperparameter optimization and it is a useful tool for diagnostics. It can visualize each metric in `cfg.machine.metric` as a function of hyperparameters irrespectively whether the requested metric was used as criterion for hyperparameter selection or not. Each metric is plotted in a separate subplot. For more details, see [here](../mfiles/plot_paropt).
2. `plot_proj`: it plots the projections (or latent variables) of the data for an associative effect in a [simple plot](../mfiles/plot_proj/#simple-plots) or for multiple associative effects in a [multi-level plot](../mflies/plot_proj/#multi-level-plots). It can plot training and test sets of specific data splits. You can colour-code the subjects in the figure by groups or a continuous variable. For more details, see [here](../mfiles/plot_proj).
3. `plot_weight`: it plots the model weights in specific formats. You can plot behaioural weights using text, vertical or horizontal bar plots. The brain weights can be plotted on a glass brain using [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) either as a map for voxel-level weights, as nodes for region-level weights and summarized connectivity weights or as edges for connectivity weights. You can also plot summarized connectivity weights as modules in an image of matrix data. For more details, see [here](../mfiles/plot_weight).

As discussed above, these functions call low-level functions to create specific figures, which then will be saved as `.png` files.

The low-level functions of `plot_proj` are the following:

- `plot_proj_2d`: it creates a 2D scatter plot with no colour-coding,
- `plot_proj_2d_cmap`: it creates a 2D scatter plot colour-coded by a continuous variable. The continuous variable can be provided as a pair of data and label file,
- `plot_proj_2d_group`: it creates a 2D scatter plot colour-coded by groups. The group information can be provided by a `group.mat` file or a pair of data and label files in the `data` folder.

The low-level functions of `plot_weight` are the following:

- `plot_weight_stem`: it creates a stem plot,
- `plot_weight_behav_horz`: it creates a horizontal bar plot,
- `plot_weight_behav_vert`: it creates a vertical bar plot,
- `plot_weight_behav_text`: it plots the label of features corresponding to the ordered weights as text, separately for the positive and negative weights.
- `plot_weight_brain_cortex`: it plots the voxel-level brain weights as a map overlaid on a glass brain using BrainNet Viewer,
- `plot_weight_brain_node`: it plots the region-level brain weights as nodes overlaid on a glass brain using BrainNet Viewer,
- `plot_weight_brain_conn_node`: it plots the summarized connectivity weights as nodes overlaid on a glass brain using BrainNet Viewer,
- `plot_weight_brain_edge`: it plots the connectivity weights as edges overlaid on a glass brain using BrainNet Viewer,
- `plot_weight_brain_module`: it plots the summarized connectivity weights as an image of matrix.
