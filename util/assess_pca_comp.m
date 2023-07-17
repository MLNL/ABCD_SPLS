function varargout = assess_pca_comp(mod, mat, varargin) % absvar cumvar pcax pcay
%   assess_pca_comp(cfg, varargin) assesses the possible number of PCA
% components based on Name-Value pairs of one of the following criterion:
% 1. absolute explained variance threshold (Name: absvar)
% 2. cumulative explained variance threshold (Name: cumvar)
% 3. number of principal components (Names: pcax, pcay)
%
% Examples:
% assess_pca_comp('X', X, 'absvar', 0.01)
% assess_pca_comp('X', X, 'cumvar', 0.9)
% assess_pca_comp('X', X, 'pca', 10)

% Parse input
S = parse_input(varargin{:});

% Initialize variables for figure
h = figure;
hold on;
lg = {};
% color = {'r', 'b'};

% Define toolkit vars
data.(mod) = mat;
trid = true(size(data.(mod), 1), 1);
cfg.data.(mod).impute = 'median';
cfg.env.fileend = '';

% Impute missing data
data = impute_mat(cfg, data, trid, mod);

% Pre-process data
data = preproc_data(cfg, data, mod, trid, 'test');

% SVD
[u, L, v] = nets_svds(data.(mod), 0);
L = diag(L);
S.pca = numel(L);

% Variance explained
varex = L .^ 2;
varex = varex / sum(varex);

% Plot explained variance
plot(varex); % color{d}
lg = [lg {['explained variance of ' mod]}];

% Calculate top components if absolute variance threshold given
if isfield(S, 'absvar')
    S.pca = find(varex > S.absvar, 1, 'last');
end

% Cumulative variance explained
cumvarex = cumsum(varex);

% Plot cumulative explained variance
plot(cumvarex); % , [color{d} ':']
lg = [lg {['cumulative explained variance of ' mod]}];
ylim([0 1])


% Calculate top components if cumulative variance threshold given
if isfield(S, 'cumvar')
    if size(S.cumvar, 2) > 1
        error('cumvar should be a scalar or a column vector')
    end
    S.pca = dsearchn(cumvarex, S.cumvar);
end

% Print results
for i=1:numel(S.pca)
    fprintf('Variance of %s explained by top %d components: %.4f\n', mod, S.pca(i), cumvarex(S.pca(i)));
end

% Plot legend
if exist('h', 'var')
    legend(lg)
end