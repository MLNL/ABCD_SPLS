function plot_weight_behav_horz(res, weight, iweight, wfname)
% plot_weight_behav_horz
%
% Syntax:  plot_weight_behav_horz(res, weight, iweight, wfname)

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for behaviour...', 'any', res.behav.file.label);
T = readtable(labelfname);
if ~all(ismember({'Category' 'Label'}, T.Properties.VariableNames)) % check if necessary fields available
    error('The behavioural label file should contain the following columns: Category, Label');
end

% Open figure
figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

% Set colors for the categories
categ = unique(T.Category);
cmap = colormap('jet');
if size(cmap, 1) < numel(categ)
    error('Too many groups, not enough colors to plot them.')
end
cmap = cmap(round(linspace(1,size(cmap, 1),numel(categ))),:);

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
    barh(dummy, 'FaceColor', cmap(i,:));
end

% User friendly display for long label names
if ~isinf(res.behav.label.maxchar)
    for i=1:size(T, 1)
        if numel(T.Label{i}) > res.behav.label.maxchar
            T.Label{i} = T.Label{i}(1:res.behav.label.maxchar);
        end
    end
end

% Add legends and labels
T.LabelUpd=cellfun( @(x) x(1:min(200,length(x))),T.Label, 'UniformOutput',false);
hold off;
set(gca, 'yTick', 1:numel(T.LabelUpd), 'yTickLabel', T.LabelUpd, 'FontSize', 15,'fontname','Arial');
legend(categ, 'Location','NE', 'FontSize', 15, 'fontname', 'Arial');
ylabel('Psychosocial variables', 'FontSize', 16, 'fontname', 'Arial')
xlabel('Weights', 'FontSize', 16)

% Save figure
saveas(gcf, [wfname '.png']);

% Save weights to csv
writetable(T(:,{'Category' 'Label' 'Weight'}), [wfname '.csv'], 'QuoteStrings', true);