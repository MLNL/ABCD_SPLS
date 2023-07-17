function plot_spls(level,res,varargin)


if (~isempty(varargin))
    boolABCD=varargin{1};
else
    boolABCD=0;
end

clc; close all
corrVal = 0.25;

% Set path with plotting folder and necessary toolboxes
set_path('plot', 'brainnet', 'spm');

%----- Initialize res and update path to experiment
res.frwork.level = level;
res.env.fileend = '_1';

% Optional fields
res.gen.selectfile = 'none';

% Update path if data moved (e.g. from cluster to local computer)
update_dir(res.dir.frwork, res.env.fileend)

% Initialize res
res = res_defaults(res, 'load');


% %----- Plot results


% % % % Plot hyperparameter surface for grid search results
for i=1:res.frwork.split.nall
    plot_paropt(res, {'X' 'Y'}, res.frwork.split.all(i), 'correl', 'simwx', 'simwy');
end


% % % % Plot data projections by group (healthy, depressed)
for i=1:res.frwork.split.nall
    display('Plotting projections')
    plot_proj_tr_test(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.all(i),'none','2d');    
end
        

% % % % Plot behavioural weights as horizontal bar plot
for i=1:res.frwork.split.nall
    res.behav.weight.numtop=40;
    plot_weight(res, 'Y', 'behav', res.frwork.split.all(i), 'behav_horz');
    %%%PLOTTING THE LOADINGS
    plot_corr(res, 'Y', 'behav', res.frwork.split.all(i), 'corr_behav', corrVal);
    xlabel('Loadings', 'FontSize', 16)
    saveas(gcf, [res.dir.res filesep 'behav_corr.png']);
end


% % % Plot cortical brain weights
for i=1:numel(res.frwork.split.all)
    if boolABCD == 1
        plot_weight(res, 'X', 'vbm', res.frwork.split.all(i), 'brain_cortex', ...
            'vbm.transM', [0.99 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], ...
            'vbm.file.MNI', fullfile(res.dir.project, 'data', 'subject.nii'));
                
                %PLOTTING THE LOADINGS
                plot_corr(res, 'X', 'vbm', res.frwork.split.all(i), 'brain_cortex', corrVal, ...
                    'vbm.transM', [0.99 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], ...
                    'vbm.file.MNI', fullfile(res.dir.project, 'data', 'subject.nii'));
        
    else if boolABCD == 0
            plot_weight(res, 'X', 'vbm', res.frwork.split.all(i), 'brain_cortex', ...
                'vbm.file.mask', fullfile(res.dir.project, 'data', 'mask.nii'));
        else if boolABCD ==2
                plot_weight(res, 'X', 'vbm', res.frwork.split.all(i), 'brain_cortex', ...
                    'vbm.transM', [1 0 0 118.6; 0 1 0 -128.6; 0 0 1 -63.3; 0 0 0 1], ...
                    'vbm.file.MNI', fullfile(res.dir.project, 'data', 'mask.nii'));
            end
        end
    end
end

