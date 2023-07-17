function plot_weight_brain_conn_node(res, weight, wfname)
% plot_weight_brain_conn_node
%
% Syntax:  plot_weight_brain_conn_node(res, weight, wfname)

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for regions...', 'any', res.conn.file.label);
T = readtable(labelfname);

% Check if necessary fields available
if strcmp(res.conn.node.type, 'ROI') && ~all(ismember({'X' 'Y' 'Z' 'Region' 'Label'}, ...
        T.Properties.VariableNames))
    error('The connectivity label file should contain the following columns: X, Y, Z, Region, Label');
end
if ~ismember('Color', T.Properties.VariableNames)
    T.Color = ones(size(T, 1), 1);
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
conn_weight = conn_weight + conn_weight'; % symmetric connectivity matrix is needed for downstream calculations
nparcel = length(conn_weight);
if numel(T.Label) ~= nparcel
    error('Number of parcels does not match the dimensionality of the weight vector');
end

if strcmp(res.conn.node.type, 'ROI')
    % Weights summarized by ROI node
    T.Size = sum(abs(conn_weight), 2) ./ sum(conn_weight ~= 0, 2); % needed due to 0s after using top connectinons
    T.Size(isnan(T.Size)) = 0;
    
    % Save results to text file
    T = T(T.Size~=0,:);
    [B, I] = sort(abs(T.Size), 'descend'); % sort nodes for easier readibility
    T = T(I,:);
    writetable(table(T.Label, T.Region, T.Size, 'VariableNames', {'Node' 'Network' 'Weight'}), [wfname '.csv']);
    
    % Prepare BrainNet files (from scratch to avoid bad files)
    fname = init_brainnet(res, 'labelfname', labelfname, 'T', T);
    
    % Plot brainnet
    if exist(fname.options, 'file')
        BrainNet_MapCfg(fname.surf, fname.node, [wfname '.png'], fname.options);
    else
        BrainNet_MapCfg(fname.surf, fname.node, [wfname '.png']);
    end
else
    error('Only ROI-based connectivity is supported at the moment.')
end