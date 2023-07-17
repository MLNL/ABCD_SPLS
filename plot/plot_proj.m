function P = plot_proj(res, mod, level, sidvar, split, label, func, varargin)
% plot_proj
%
% It plots the projections of the data (or latent variables).
%
% # Syntax
%   plot_proj(res, mod, level, sidvar, split, label, func, varargin)
%
% # Inputs
% res:: struct 
%   res structure containing information about results and plot specifications
% mod:: cell array 
%   modality of data to be used for plotting (i.e., {'X', 'Y'}) 
% level:: int or numeric array
%   level of associative effect with same dimensionality as 'mod' or 
%   automatically extended (e.g. from int to numeric array)
% sidvar:: 'osplit', 'otrid', 'oteid', 'isplit', 'itrid',  'iteid'
%   specifies subjects to be used for plotting
%
%   first letter can be 'o' for outer or 'i' for inner split, followed by 
%   either 'trid' for training, 'teid' for test or 'split' for both 
%   training and test data
% split:: int or numeric array
%   index of data split to be used with same dimensionality as 'mod' or 
%   automatically extended (e.g. from int to numeric array)
% label:: 'none', char 
%   'none' for scatterplot with same colour for all subjects or
%
%   label (e.g. from LabelsY.xlsx) to be used as a continuous colormap
%   (e.g. Age) or for colouring different groups (e.g. Male); label file
%   and corresponding data file are specified by 'res.proj.file.label' and 
%   'res.proj.file.data'
%
%   if '+' is included in the character (e.g. 'MDD+HC') group information is 
%   taken from cfg.data.group
% func:: '2d', '2d_group', '2d_cmap'
%   name of the specific plotting function (after plot_proj_* prefix) to
%   be called
% varargin:: name-value pairs
%   additional options can be passed via name-value pairs with dot notation
%   supported (e.g., 'proj.xlim', [-5 5])
%
% # Examples
%
% ## Simple Plots
% Most often, we plot brain score vs. behaviour score for a specific 
% level (i.e., associative effect).
%
%    % Plot data projections coloured by groups provided in data/label files
%    res.proj.file.data = fullfile(res.dir.project, 'data', 'V.mat');
%    res.proj.file.label = fullfile(res.dir.project, 'data', 'LabelsV.xlsx');
%    plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.best, ...
%              'Remission', '2d_group');   
%
% ![projection_plot](../figures/projection_plot.png)
%
% ## Multi Level Plots
% To plot projections aggregated over multiple levels, all you need to 
% specify is res.proj.multi_level = 1 and provide a 2D cell array of input 
% variable 'mod'. Input variables 'level' and 'split' should have the same 
% dimensionality or they will be extended automatically from 1-D or 2-D arrays
% (e.g. level = repmat(level, size(mod))).
%
%    % Plot data projections across levels (and averaged over modalities 
%    % in a given level after standardization)
%    res.proj.multi_label = 1;
%    plot_proj(res, {'X' 'Y'; 'X' 'Y'}, [1 1; 2 2], 'osplit', res.frwork.split.best, ...
%              'Remission', '2d_group');
%
% ---
% See also: [plot_paropt](../plot_paropt), [plot_weight](../plot_weight/)

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Parse input and add default settings
res = res_defaults(res, 'projection', varargin{:});

% Add SPM if needed
if strcmp(res.gen.selectfile, 'interactive')
    set_path('spm');
end

% Match modalities, levels, splits and flips
if res.proj.multi_level && size(mod, 1) < 2
    error(['Please specify at least 2x2 modalities for multi level plotting! ' ...
        'See function description for more information.'])
end
if numel(level) == 1
    level = repmat(level, size(mod));
elseif size(level, 2) == 1
    level = repmat(level, 1, 2);
end
if numel(split) == 1
    split = repmat(split, size(mod));
elseif size(split, 2) == 1
    split = repmat(split, 1, 2);
end
if numel(res.proj.flip) == 1
    res.proj.flip = repmat(res.proj.flip, size(mod));
elseif size(res.proj.flip, 2) == 1
    res.proj.flip = repmat(res.proj.flip, 1, 2);
end

%----- Calculate projection separately for each axis

[nlevels, nmods] = size(mod);
for i=1:nlevels
    for j=1:nmods
        tic
        % Update res if needed
        if res.frwork.level ~= level(i)
            res.frwork.level = level(i);
            res = res_defaults(res, 'load');
        end
        
        % Load weights
        w = loadmat(res, fullfile(res.dir.res, 'model.mat'), ['w' mod{i,j}]);
        w = w(split(i,j,1),:)';
        
        % Postprocess brain weights if requested (sorting, filtering etc.)
%         if strcmp(mod{i,j}, 'X') && isfield(res.conn, 'weight')
%             w = postproc_weight(res, w, 'conn');
%         end
            
        if ismember(cfg.machine.name, {'pls' 'spls'})
            % Load data in input space
            [trdata, trid, tedata, teid] = load_data(res, mod(i,j), sidvar, squeeze(split(i,j,:)));

        else
            % Load data in feature space
            if ismember(sidvar, {'isplit' 'itrid' 'iteid'})
                error('Functionality not implemented yet. The models should be retrained.')
            end
            if ismember(sidvar, {'otrid' 'itrid' 'oext'})
                [trdata, trid] = load_data(res, {['R' mod{i,j}]}, ...
                    sidvar, squeeze(split(i,j,:)));
            else
                [trdata, trid, tedata, teid] = load_data(res, {['R' mod{i,j}]}, ...
                    sidvar, squeeze(split(i,j,:)));
            end
        end
         
        switch sidvar
            case {'otrid' 'itrid' 'oext'}
                data = trdata;
                sid = trid;
                
            case {'oteid' 'iteid' 'iext'}
                data = tedata;
                sid = teid;
                
            case {'osplit' 'isplit'}
                % Concatenate data
                if ismember(cfg.machine.name, {'cca' 'rcca'})
                    data = concat_data(trdata, tedata, {['R' mod{i,j}]}, trid, teid);
                else
                    data = concat_data(trdata, tedata, mod(i,j), trid, teid);
                end
                sid = any([trid teid], 2);
        end

        if ismember(cfg.machine.name, {'pls' 'spls'})
            % Project data in input space
            P(:,i,j) = calc_proj(data.(mod{i,j}), w);
            
        else
            % Load parameter
            param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
            
            % Define feature index
            featid = get_featid(trdata, param(split(i,j,1)), mod{i,j});
                    
            % Project data in feature space
            w = trdata.(['V' mod{i,j}])(:,featid)' * w;
            P(:,i,j) = calc_proj(data.(['R' mod{i,j}])(:,featid), w);
        end
                    
        % Flip sign if requested
        if res.proj.flip(i,j)
            P(:,i,j) = -P(:,i,j);
        end
    end
end

%----- Calculate mean over modalities to plot multiple levels

if res.proj.multi_level
    % Standardize data and calculate mean over modalities
    P = zscore(P);
    P = mean(P, 3);
    
    % Update axis labels (only 2D plots at the moment!)
    for i=1:nlevels
        axesLabels{i} = sprintf('Level %d (%s)', i, strjoin(mod(i,:), '-'));
    end
    res.proj.xlabel = axesLabels{1};
    res.proj.ylabel = axesLabels{2};
else
    P = squeeze(P);
end

%----- Define label (e.g. cluster or colormap)
if nargout == 1 && isempty(label)
    return
else
    label = strsplit(label, ':');
end

if strcmp(label{1}, 'none') % no group and no colormap
    grp = ones(cfg.data.nsubj, 1);
    lg = {''};
    
elseif strfind(label{1}, '+') % groups based on cfg.data.group
    S = load(fullfile(res.dir.project, 'data', 'group.mat'), 'group');
    grp = S.group;
    lg = strsplit(label{1}, '+');
    
elseif strfind(label{1}, 'teid')
    if numel(unique(split)) > 1
        error('This functionality works only with 1 splits of data.')
    end
    [~, oteid] = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', 'oteid');
    grp = oteid(:,unique(split)) + 1;
    lg = {'training' 'test'};
    
else % groups/colormap based on custom variable
    % Load data file
    fname = select_file(res, fullfile(res.dir.project, 'data'), ...
        ['Select data file including ' label{1} '...'], 'mat', res.proj.file.data);
    D = load(fname);
    fieldname = fieldnames(D);
    
    % Load label file
    fname = select_file(res, fullfile(res.dir.project, 'data'), ...
        ['Select delimited label file including ' label{1} '...'], 'any', res.proj.file.label);
    T = readtable(fname);
    
    if ismember(label{1}, T.Label)
        grp = D.(fieldname{1})(:,ismember(T.Label, label{1}));
        if strfind(func, 'cmap')
            lg = label{1};
        elseif strfind(func, 'group')
            g = unique(grp);
            if ismember(0, g)
                grp = grp + 1;
            end
            lg = sprintfc([label{1} ' %d'], g);
        end
    else
        error('Grptype must match a field in the selected label file.')
    end
end

% Select relevant subjects
grp = grp(sid);

%----- Visualize projections/latent space

% Specify file name
if res.proj.multi_level
    fname = fullfile(res.dir.frwork, 'res', 'proj');
else
    fname = fullfile(res.dir.res, 'proj');
end
if ~strcmp(label{1}, 'none')
    fname = sprintf('%s_%s', fname, label{1});
end
if any(ismember(sidvar, {'osplit' 'otrid' 'oteid' 'iext'}))% outer splits
    fname = sprintf('%s_split%d', fname, split(1));
    if ~strcmp(sidvar, 'osplit')
        fname = sprintf('%s_%s', fname, sidvar(2:end));
    end 
elseif strcmp(sidvar, 'oext')
    fname = sprintf('%s_%s', fname, sidvar);
end

% Scatter plot
func = str2func(['plot_proj_' func]);
if isequal(func, @plot_proj_2d)
    func(res, P, fname);
else
    func(res, P, fname, grp, lg);
end