function plot_proj_2d_train_test(res, P, trid, teid)
% plot_proj_2d
%
% Syntax:  plot_proj_2d(res, P, fname)
%
% # Inputs
% input1:: Description
% input2:: Description
% input3:: Description
%
% # Outputs
% output1:: Description
% output2:: Description
%
% # Example
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
%
% See also: [plot_check_perm](),  [plot_check_split]()
%
% Author: Agoston Mihalik
%
% Website: http://www.mlnl.cs.ucl.ac.uk/


% figure
figure('Units', 'Normalized', 'OuterPosition', [0 0 0.5 0.78]);
% pos = [0.12 0.15 0.67 0.80]; % position same across different types of plots (e.g. 2d_group, 2d_cmap)
pos = [0.3 0.2 0.6 0.56]; % position same across different types of plots (e.g. 2d_group, 2d_cmap)
axes('Position', pos,'linewidth',2)
% axes('Position', pos, 'ActivePositionProperty','outerposition');
hold on;

% Plot data
scatter(P(trid,1), P(trid,2), 120, 'MarkerFaceColor', [0.3 0.3 0.9], 'MarkerEdgeColor', 'k'); hold on,
scatter(P(teid,1), P(teid,2), 120, 'MarkerFaceColor', [0.3 0.1 0.1], 'MarkerEdgeColor', 'k');

% Plot labels
if ~any(isnan(res.proj.xlim)) && ~any(isnan(res.proj.ylim))
    set(gca, 'FontSize', 40, 'FontName', 'Arial', 'XLim', res.proj.xlim, 'YLim', res.proj.ylim); % 24
else
    set(gca, 'FontSize', 40, 'FontName', 'Arial');
end
xlabel(res.proj.xlabel, 'FontSize', 43, 'fontname', 'Arial');
% ylabel(res.proj.ylabel, 'FontSize', 16, 'fontname', 'Arial');
ylabel('Psychosocial Score', 'FontSize', 43, 'fontname', 'Arial');

% legend('Train','Test', 'fontname', 'Arial')

h(1) = plot(nan, nan, 'o', 'MarkerSize', 16, 'MarkerFaceColor', [0.3 0.3 0.9], 'MarkerEdgeColor', 'k', 'DisplayName', 'Train');
h(2) = plot(nan, nan, 'o', 'MarkerSize', 16, 'MarkerFaceColor', [0.3 0.1 0.1], 'MarkerEdgeColor', 'k', 'DisplayName', 'Test');
legend(h)

fname = fullfile(res.dir.res, 'proj');
saveas(gcf, [fname '.png']);