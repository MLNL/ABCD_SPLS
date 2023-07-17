<span style="font-size:2em;">__cfg_defaults__</span>

Set defaults in your configuration (`cfg`) structure which will define 
the settings of your analysis (e.g. machine, framework, significance 
testing). Use this function to update and add all necessary defaults to 
your `cfg`. If you defined anything in your `cfg` before calling the 
function, it won't overwrite those values. The path to the project folder 
should be always defined in your `cfg` or passed as varargin, otherwise 
the function throws an error. All the other fields are optional and can 
be filled up by `cfg_defaults`.

No results will be stored in the cfg structure. See [res_defaults](../res_defaults) 
for more information on results.

!!! note "Warning"

        We strongly advise to inspect the output of `cfg_defaults` to make 
        sure that the defaults are set as expected.
    
##  Syntax
      cfg = cfg_defaults(cfg, varargin)
    
##  Inputs
*   **cfg** [*struct*]
    
*   **varargin** [*name-value pairs*]
    
    additional parameters can be set via name-value pairs with dot notation 
    supported (e.g., 'frwork.split.nout', 5)
    
##  Outputs
*   **cfg** [*struct*]
    
    configuration structure that has been updated with defaults
    
##  Examples
      % Example 1
      cfg.dir.project = 'PATH/TO/YOUR/PROJECT1'
      cfg = cfg_defaults(cfg)
    
      % Example 2
      cfg.dir.project = 'PATH/TO/YOUR/PROJECT2'
      cfg = cfg_defaults(cfg, 'machine.name', 'spls', ...
                         'machine.metric', {'correl' 'simwx' 'simwy'},
                         'machine.param.crit', 'correl+simwxy')
    
      % Example 3
      cfg = cfg_defaults([], 'dir.project', 'PATH/TO/YOUR/PROJECT3', ...
                         'machine.name', 'rcca', ...
                         'machine.metric', {'correl'},
                         'machine.param.crit', 'correl',
                         'frwork.split.nout', 5)
    
---
See also: [cfg](../../cfg), [res_defaults](../res_defaults/)

