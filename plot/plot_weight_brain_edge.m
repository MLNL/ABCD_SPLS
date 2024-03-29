function plot_weight_brain_edge(res, weight, wfname)
% plot_weight_brain_edge
%
% Syntax:  plot_weight_brain_edge(res, weight, wfname)

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for regions...', 'any', res.conn.file.label);
T = readtable(labelfname);

% Check if necessary fields available
if ~all(ismember({'Index' 'X' 'Y' 'Z' 'Label'}, T.Properties.VariableNames))
    error('The connectivity label file should contain the following columns: Index, X, Y, Z, Label');
end
if ~ismember('Color', T.Properties.VariableNames)
    T.Color = ones(size(T, 1), 1);
end
if ~ismember('Size', T.Properties.VariableNames)
    T.Size = ones(size(T, 1), 1);
end

% Load mask
maskfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select mask file...', 'mat', res.conn.file.mask);
load(maskfname);
if sum(mask(:)) ~= numel(weight)
    error('Mask does not match the dimensionality of weight');
end

% Create connectivity matrix
fprintf('Max weight: %.4f\n', max(abs(weight(:))));
conn_weight = zeros(size(mask));
conn_weight(mask==1) = weight; % fill up using linear indexing
nparcel = length(conn_weight);
if numel(T.Label) ~= nparcel
    error('Number of parcels does not match the dimensionality of the weight vector');
end

% Save results to text file
[nodeA, nodeB, idnodeA, idnodeB] = deal({}); % regionA, regionB, idA, idB, descA, descB,
w = [];
for i=1:nparcel
    for j=1:nparcel
        if conn_weight(i,j) ~= 0
            nodeA(end+1,1) = T.Label(i);
            idnodeA{end+1,1} = T.Index(i);
            nodeB(end+1,1) = T.Label(j);
            idnodeB{end+1,1} = T.Index(j);
            w(end+1,1) = conn_weight(i,j);
        end
    end
end

Tout = table(nodeA, idnodeA, nodeB, idnodeB, w); % regionA, idA, regionB, idB, descA, descB
[B, I] = sort(Tout.w, 'descend');
Tout = Tout(I,:);
writetable(Tout, [wfname '.csv']);

% Prepare BrainNet files (from scratch to avoid bad files)
% conn_weight = conn_weight / max(abs(conn_weight(:))); % rescale weight for better visualization
conn_weight = conn_weight + conn_weight'; % make matrix symmetric for BrainNet viewer
fname = init_brainnet(res, 'labelfname', labelfname, 'T', T, 'wfname', wfname, 'weight', conn_weight);

% Plot brainnet
if exist(fname.options, 'file')
    BrainNet_MapCfg(fname.surf, fname.node, fname.edge, [wfname '.png'], fname.options);
else
    BrainNet_MapCfg(fname.surf, fname.node, fname.edge, [wfname '.png']);
end