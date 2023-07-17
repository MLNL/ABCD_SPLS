function plot_proj_2d(res, P, fname)
% plot_proj_2d
%
% Syntax:  plot_proj_2d(res, P, fname)

figure;
pos = [0.12 0.15 0.67 0.80]; % position same across different types of plots (e.g. 2d_group, 2d_cmap)
axes('Position', pos);
hold on;

% Plot data
scatter(P(:,1), P(:,2), 100, 'MarkerFaceColor', [0.3 0.3 0.9], 'MarkerEdgeColor', 'k');
    
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