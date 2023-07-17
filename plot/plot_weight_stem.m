function plot_weight_stem(res, weight, iweight, wfname, mod)
% plot_weight_stem
%
% Syntax:  plot_weight_stem(weight, wfname)

figure;
pos = [0.12 0.15 0.67 0.80];
axes('Position', pos);

% Update weights
weight = weight(iweight);
idout = false(size(weight));
if ~isinf(res.simul.weight.numtop) || res.simul.weight.filtzero
    idout = weight==0;
    weight(idout,:) = []; 
end

% Plot weight
stem(weight);
hold on;
xlim([0 numel(weight)+1]);

% Plot labels
xlabel(res.simul.xlabel);
ylabel(res.simul.ylabel);

if exist(res.simul.weight.file.(mod), 'file')    
    % Load true weight
    data = load(res.simul.weight.file.(mod));
    field = fieldnames(data);
    
    % Renormalize weight to match scale
    weight_true = data.(field{1});
    weight_true = weight_true / norm(weight_true) * norm(weight);
    
    % Plot true weight
    weight_true = weight_true(iweight);
    stem(weight_true(~idout));
end

saveas(gcf, [wfname '.png']);