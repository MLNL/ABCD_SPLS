function cleanup_files(cfg)
% cleanup_files
%
% Cleans up unnecessary duplicate and intermediate files created during
% analysis to save disc space.
%
% # Syntax
%   cleanup_files(cfg)
%
% # Inputs
% cfg:: struct
%
%
% # Examples
%
%   % Example 1
%   load cfg
%   cleanup_files(cfg);
%
% ---
% See also: [cfg_defaults](../cfg_defaults/)

lv = 1;
while exist_file(cfg, fullfile(cfg.dir.frwork, 'res', sprintf('level%d', lv), 'res.mat'))
    % Load res file
    res = loadmat(cfg, fullfile(cfg.dir.frwork, 'res', sprintf('level%d', lv), 'res.mat'), 'res');
    
    % Clean up data folder
    renamemat(cfg, fullfile(res.dir.frwork, 'inmat.mat'));
    renamemat(cfg, fullfile(res.dir.frwork, 'outmat.mat'));
    
    % Clean up grid folder
    if strcmp(cfg.frwork.name, 'holdout')
        renamemat(cfg, fullfile(res.dir.grid, 'allgrid.mat'));
        delete(fullfile(res.dir.grid, 'grid_*.mat'));
    end
    
    % Clean up load folder
    if isdir(cfg.dir.load)
        rmdir(cfg.dir.load, 's');
    end
    
    % Clean up perm folder
    renamemat(cfg, fullfile(res.dir.perm, 'allperm.mat'));
    renamemat(cfg, fullfile(res.dir.frwork, 'perm', sprintf('permmat_%d.mat', cfg.stat.nperm)));
    delete(fullfile(res.dir.perm, 'perm_*.mat'));
    
    % Clean up res folder
    renamemat(cfg, fullfile(res.dir.res, 'model.mat'));
    renamemat(cfg, fullfile(res.dir.res, 'param.mat'));
    renamemat(cfg, fullfile(res.dir.res, 'res.mat'));
    
    % Update fileend field
    res.env.fileend = '_1';
    save(fullfile(res.dir.res, 'res_1.mat'), 'res')
    cfg.env.fileend = '_1';
    renamemat(cfg, fullfile(res.dir.frwork, 'cfg.mat'));
    
    clear res
    lv = lv + 1;
end
