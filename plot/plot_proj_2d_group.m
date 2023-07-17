function plot_proj_2d_group(res, P, fname, grp, lg)
% plot_proj_2d_group
%
% Syntax:  plot_proj_2d_group(res, P, fname, grp, lg)

fprintf('Correlation in latent space: %.4f\n', corr(P(:,1), P(:,2)));

figure;
pos = [0.15 0.15 0.67 0.80]; % position same across different types of plots (e.g. 2d_group, 2d_cmap)
axes('Position', pos);
hold on;

% Plot data
markersize = 100;
col = [0.3 0.3 0.9; 0.9 0.3 0.3; 0.3 0.9 0.3; 0.7 0.7 0.7];

ug = unique(grp);
if numel(ug) ~= numel(lg)
   error('Number of clusters should match the number of legends, or use ''other'' for last clusters.') 
end
for i=1:numel(ug)
    hold on;
    if i==numel(ug) && strncmpi(lg{end}, 'other', 5)
        scatter(P(ismember(grp, i:max(grp)),1), P(ismember(grp, i:max(grp)),2), ...
            markersize, 'MarkerFaceColor', col(end,:), 'MarkerEdgeColor', 'k');
    else
        scatter(P(grp==ug(i),1), P(grp==ug(i),2), markersize, 'MarkerFaceColor', col(i,:), ...
            'MarkerEdgeColor', 'k');
    end
end

% Plot labels
xlabel(res.proj.xlabel);
ylabel(res.proj.ylabel);

% Save figure
saveas(gcf, [fname '.png']);
% plot2svg([fname '.svg'], gcf);