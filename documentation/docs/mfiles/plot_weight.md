<span style="font-size:2em;">__plot_weight__</span>

It plots the model weights in specific figures based on the modality of 
the data. 

##  Syntax
      plot_weight(res, mod, modtype, split, func, varargin)
    
##  Inputs
*   **res** [*struct*]
    
    res structure containing information about results and plot specifications
    
*   **mod** [*'X', 'Y'*]
    
    modality of data to be used for plotting
    
*   **modtype** [*'behav', 'conn', 'vbm', 'roi', 'simul', 'brainnet'*]
    
    type of data
    
*   **split** [*int*]
    
    index of data split to be used
    
*   **func** [*'behav_horz', 'behav_vert', 'brain_conn_node', 'brain_cortex', 'brain_edge', 'brain_module', 'brain_node', 'brain_schemaball', 'brain_subcortex', 'stem'*]
    
    name of the specific plotting function (after plot_weight_* prefix) to
    be called
    
*   **varargin** [*name-value pairs*]
    
    additional options can be passed via name-value pairs with dot notation
    supported (e.g., 'behav.weight.numtop', 20)
    
##  Examples
###  Behavioural
      % Plot top behavioural weights as horizontal bar plot
      res.behav.weight.sorttype = 'sign';
      res.behav.weight.numtop = 20;
      res.behav.label.maxchar = 50;
      plot_weight(res, 'Y', 'behav', res.frwork.split.best, 'behav_horz');
    
###  Connectivity
      % Plot top connectivity weights on glass brain
      res.conn.file.label = fullfile(res.dir.project, 'data', ...
                                     'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.csv');
      res.conn.weight.sorttype = 'sign';
      res.conn.weight.numtop = 20;
      res.brainnet.file.surf = 'PATH/TO/BrainMesh_ICBM152_smoothed.nv';
      res.brainnet.file.options = fullfile(res.dir.project, 'data', 'BrainNet', ...
                                           'options_edge.mat');
      plot_weight(res, 'X', 'conn', res.frwork.split.best, 'brain_edge');
    
      % Plot top connectivity weights as schemaball
      plot_weight(res, 'X', 'conn', res.frwork.split.best, 'brain_schemaball');
    
---
See also: [plot_paropt](../plot_paropt), [plot_proj](../plot_proj)

