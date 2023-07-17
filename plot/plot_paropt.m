function plot_paropt(res, mod, split, varargin)
% plot_paropt
%
% It plots the grid search results of the hyperparameter optimization. 
%
% # Syntax
%   plot_paropt(res, mod, split, varargin)
%
% # Inputs
% res:: struct 
%   res structure containing information about results and plot specifications
% mod:: cell array 
%   modality of data to be used for plotting (i.e., {'X', 'Y'})
% split:: int
%   index of data split to be used
% varargin:: 'correl', 'covar', 'simwx', 'simwy', 'simwxy', 'correl+simwxy'
%   metrics to be plotted as a function of hyperparameter grid, each metric 
%   in a separate subplot
%
% # Examples
%    % Plot hyperparameter surface for grid search results
%    plot_paropt(res, {'X' 'Y'}, res.frwork.split.best, 'correl', 'simwxy', ...
%                'correl+simwxy');
%
% ![hyperparameter_surface](../figures/hyperparameter_surface.png)
%
% ---
% See also: [plot_proj](../plot_proj), [plot_weight](../plot_weight)

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Parse input and add default settings
res = res_defaults(res, 'paropt');

% Get grid search results
[param, S] = get_hyperparam(res, 'grid');

% Compute combined similarity and distance metric
for i=1:res.frwork.split.nall
    if any(contains(varargin, 'simwxy')) || any(contains(varargin, 'dist2'))
        S.simwxy(i,:) = nanmean([S.simwx(i,:); S.simwy(i,:)], 1);
    end
    if ismember('dist2', varargin)
        S.dist2(i,:) = calc_stability_distance(S.correl(i,:), S.simwxy(i,:));
    end
    if ismember('dist3', varargin)
        S.dist3(i,:) = calc_stability_distance(S.correl(i,:), S.simwx(i,:), S.simwy(i,:));
    end
end

% Number of hyperparameter levels
p = cfg.machine.param.name; % shorthand variable
num = cell(1, numel(p));
for i=1:numel(p)
    num{i} = numel(cfg.machine.param.(p{i}));
end

% Remove parameters with 1 level
param = rmfield(param, p(cellfun(@(x) x==1, num)));
p(cellfun(@(x) x==1, num)) = [];
num(cellfun(@(x) x==1, num)) = [];

% Reshape data
for i=1:numel(varargin)
    S.(varargin{i}) = permute(S.(varargin{i}), [2 1]); % swap dimensions
    S.(varargin{i}) = reshape(S.(varargin{i}), num{:}, res.frwork.split.nall);
end

% Plot grid search reasults for each metric as a subplot
if numel(p) == 1
    % Plot curve/line as a function of 1 hyperparameter
    figure;
    for i=1:numel(varargin)
        subplot(1, numel(varargin), i);
        plot_2D(cfg, mod, S.(varargin{i})(:,split), varargin{i});
    end
    saveas(gcf, fullfile(res.dir.res, sprintf('parOpt_split%d.png', split)));
    
elseif numel(p) == 2
    % Plot surface as a function of 2 hyperparameters
    figure('Position', [500 600 numel(varargin)*400 400]);
    for i=1:numel(varargin)
        subplot(1, numel(varargin), i);
        plot_3D(cfg, mod, S.(varargin{i})(:,:,split), res.param.xscale, res.param.yscale, param(split), varargin{i});
        if i==2
                title('Optimising generalisability and stability of L_1 regularisation hyper-parameters for brain (c_u) and psychosocial (c_v) variables', 'FontName', 'Arial', 'Fontsize', 13)
        end
    end
    saveas(gcf, fullfile(res.dir.res, sprintf('parOpt_split%d.png', res.frwork.split.all(split))));
end


% --------------------------- Private functions ---------------------------

function plot_2D(cfg, fn, data, ylab)

plot(cfg.machine.param.(fn{1}), data);
xlabel(fn{1}); % 'Fontsize', 15
ylabel(ylab); % 'Fontsize', 15
         

function plot_3D(cfg, mod, data, xscale, yscale, param, ylab)

fields = fieldnames(param);

[Y, X] = meshgrid(cfg.machine.param.(fields{2}), cfg.machine.param.(fields{1})); % to match the order of correl
if all(ismember(fields, {'L2x' 'L2y'}))
    surf(1-X, 1-Y, data);
    hold on;
    plot3(gca, 1-repmat(param.(fields{1}), 1, 2), 1-repmat(param.(fields{2}), 1, 2), ...
        get(gca, 'ZLim'), 'r', 'LineWidth', 2);
else
    surf(X, Y, data);
    hold on;
    plot3(gca, repmat(param.(fields{1}), 1, 2), repmat(param.(fields{2}), 1, 2), ...
        get(gca, 'ZLim'), 'r', 'LineWidth', 2);
end
if strcmp(yscale, 'log')
    set(gca, 'YScale', 'log')
end
if strcmp(xscale, 'log')
    set(gca, 'XScale', 'log')
end

set(gca, 'FontSize', 11, 'Fontname', 'Arial');

if all(ismember(fields, {'L2x' 'L2y'}))
    xlabel(['1 - ' fields{1}], 'Fontsize', 13); % , 'Fontsize', 15
    ylabel(['1 - ' fields{2}], 'Fontsize', 13); % 'Fontsize', 15
else
    xlabel(fields{1}, 'Fontsize', 13); % , 'Fontsize', 15
    ylabel(fields{2}, 'Fontsize', 13); % 'Fontsize', 15
end

    xlabel('c_u', 'Fontsize', 13); % , 'Fontsize', 15
    ylabel('c_v', 'Fontsize', 13); % 'Fontsize', 15
    
switch ylab
    case 'trcorrel'
        zlabel('Training correlation', 'Fontsize', 13)
    case 'correl'
        zlabel('Test correlation', 'Fontsize', 13)
    case 'dist2'
        zlabel('Distance', 'Fontsize', 13)
    case 'simwx'
        zlabel('Brain weight similarity', 'Fontsize', 13)
    case 'simwy'
        zlabel('Psychosocial weight similarity', 'Fontsize', 13)       
end
% set(gca, 'FontSize', 14); % , 'XTick', 0:0.2:1, 'YTick', 0:0.2:1
view(-130, 20); % add view to help assessment
% view(-35, 70);
% view(-20, 90);
% view(-50, 20);