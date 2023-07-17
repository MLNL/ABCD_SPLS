function plot_proj_2d_cmap(res, P, fname, grp, lg)
% plot_proj_2d_cmap
%
% Syntax:  plot_proj_2d_cmap(res, P, fname, grp, lg)

figure;
pos = [0.12 0.15 0.67 0.80];
axes('Position', pos);
hold on;

% Add colormap
set_path('cbrewer');
if exist('cbrewer', 'file')
    cmap = cbrewer('seq', 'Purples', 64);
    colormap(cmap);
end

% Plot data
markersize = 100;
scatter(P(:,1), P(:,2), markersize, grp, 'filled', 'MarkerEdgeColor', 'k');
c = colorbar;
ylabel(c, lg);
set(gca, 'Position', pos); % reposition axes as it has been misplaced by colorbar

% Plot labels
xlabel(res.proj.xlabel, 'FontSize', 11);
ylabel(res.proj.ylabel, 'FontSize', 11);
if ~any(isnan(res.proj.xlim)) && ~any(isnan(res.proj.ylim))
    set(gca, 'FontSize', 16, 'FontName', 'Times New Roman', 'XLim', res.proj.xlim, 'YLim', res.proj.ylim); % 24
else
    set(gca, 'FontSize', 16, 'FontName', 'Times New Roman');
end

% Save figure
saveas(gcf, [fname '.png']);