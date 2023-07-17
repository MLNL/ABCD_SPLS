function plot_weight_behav_vert(res, weight, iweight, wfname)
% plot_weight_behav_vert
%
% Syntax:  plot_weight_behav_vert(res, weight, iweight, wfname)

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for behaviour...', 'any', res.behav.file.label);
T = readtable(labelfname);
if ~all(ismember({'Category' 'Label'}, T.Properties.VariableNames)) % check if necessary fields available
    error('The behavioural label file should contain the following columns: Category, Label');
end

% Open figure
figure;% ('Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

% Set colors for the categories
categ = unique(T.Category);
cmap = colormap('jet');
if size(cmap, 1) < numel(categ)
    error('Too many groups, not enough colors to plot them.')
end
cmap = cmap(round(linspace(1,size(cmap, 1),numel(categ))),:);

% Normalize weight
if res.behav.weight.norm
    minmax = max(abs(weight));
    weight = weight ./ minmax;
end

% Create weight table
T.Weight = weight;
T = T(iweight,:); % reorder table based on the order of the weight
if ~isinf(res.behav.weight.numtop) || res.behav.weight.filtzero
    T(T.Weight==0,:) = []; % remove 0 weights
end

% Subselect category colours
[C, ia, ib] = intersect(categ, unique(T.Category));
cmap = cmap(ia,:);
categ = unique(T.Category);

% Plot weights
hold on;
for i=1:numel(categ)
    dummy = T.Weight;
    dummy(~ismember(T.Category, categ{i})) = 0;
    bar(dummy, 'FaceColor', cmap(i,:));
end

% Add legends and labels
hold off;
legend(categ, 'Location', 'NE'); % 'FontSize', 20
xlabel('Behavioural variables'); % 'FontSize', 30
ylabel('Weights'); % 'FontSize', 30
set(gca, 'xTick', 1:numel(T.Label), 'xTickLabel', T.Label); % 'FontSize', 20
if res.behav.weight.norm
    ylim([min(weight)-0.1 max(weight)+0.1])
end

% Save figure
saveas(gcf, [wfname '.png']);
% saveas(gcf, [wfname '.svg']);

% Save weights to csv
writetable(T(:,{'Category' 'Label' 'Weight'}), [wfname '.csv'], 'QuoteStrings', true);