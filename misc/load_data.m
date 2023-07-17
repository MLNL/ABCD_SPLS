function varargout = load_data(res, mod, splittype, split, param)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load training and test indexes
switch splittype
    case 'otrid'
        otrid = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid');
        trid = otrid(:,split);
        
    case 'itrid'
        itrid = loadmat(res, fullfile(res.dir.frwork, 'inmat.mat'), 'itrid', 'iteid');
        trid = itrid(:,split(1),split(2));
        
    case 'oext'
        oextid = loadmat(res, fullfile(res.dir.frwork, 'extmat.mat'), 'oextid');
        trid = oextid(:,split);
        
    case {'osplit' 'oteid'}
        [otrid, oteid] = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', 'oteid');
        trid = otrid(:,split);
        teid = oteid(:,split);
        
    case {'isplit' 'iteid'}
        [itrid, iteid] = loadmat(res, fullfile(res.dir.frwork, 'inmat.mat'), 'itrid', 'iteid');
        trid = itrid(:,split(1),split(2));
        teid = iteid(:,split(1),split(2));
        
    case 'iext'
        otrid = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid');
        oextid = loadmat(res, fullfile(res.dir.frwork, 'extmat.mat'), 'oextid');
        
        % Concatenate original training indexes and external indexes
        trid = cat(1, otrid(:,split(1)), false(size(oextid, 1), 1));
        teid = cat(1, false(size(otrid, 1), 1), oextid(:,split(2)));
end

% Initialize data
[data, trdata, tedata] = deal(struct());

% Add confounds to modality if needed
if cfg.data.conf
    mod = [{'C'} mod];
end

for i=1:numel(mod)
    % Shorthand for modality without processing
    m = erase(mod{i}, 'R');
    
    % Initialize folder/file for SVD results
    proc = 0;
    if ismember(cfg.machine.name, {'cca' 'rcca'})
        if ~isdir(fullfile(cfg.dir.load, 'svd'))
            mkdir(fullfile(cfg.dir.load, 'svd'))
        end
        if ismember(splittype, {'osplit' 'otrid' 'oteid' 'iext'})
            fnamep = sprintf('svd%s_split_%d.mat', lower(m), split(1));
        elseif ismember(splittype, {'isplit' 'itrid' 'iteid'})
            fnamep = sprintf('svd%s_split_%d_subsample_%d.mat', lower(m), ...
                split(1), split(2));
        end
        if exist_file(cfg, fullfile(cfg.dir.load, 'svd', ['tr_' fnamep])) ...
                && exist_file(cfg, fullfile(cfg.dir.load, 'svd', ['te_' fnamep]))
            proc = 1;
        end
    end
    if ~exist('param', 'var') && ~strncmp(mod{i}, 'R', 1)
       proc = 0; 
    end
    
    if proc
        fprintf('Loading initial SVD results of %s...', m)
        
        % Load processed data
        [trdata.(['R' m]), trdata.(['V' m]), trdata.(['L' m])] = loadmat(cfg, ...
            fullfile(cfg.dir.load, 'svd', ['tr_' fnamep]), ['R' m], ['V' m], ['L' m]);
        tedata.(['R' m]) = loadmat(cfg, fullfile(cfg.dir.load, 'svd', ...
            ['te_' fnamep]), ['R' m]);
        
        fprintf('done!\n'); toc
    
    else
        fprintf('Loading data %s...', m)
        
        % Load original and/or external data
        switch splittype
            case 'oext'
                data = load_data_mod(res, data, m);
                
            case 'iext'
                data = load_data_mod(cfg, data, m);
                data = load_data_mod(res, data, m);
                
            otherwise
                data = load_data_mod(cfg, data, m);
        end
        
        fprintf('done!\n'); toc
        
        % Impute missing data
        data = impute_mat(cfg, data, trid, m);
        
        % Add bias term to confounds if needed
        if strcmp(m, 'C')
            if isfield(data, 'C') && ~any(arrayfun(@(x) isequal(ones(size(data.C, 1), 1), data.C(:,x)), 1:size(data.C, 2)))
                data.C = [ones(size(data.C, 1), 1) data.C];
            end
        end
        
        % Training examples in input space
        trdata.(m) = data.(m)(trid,:);
        
        % Test examples in input space
        if exist('teid', 'var')
            tedata.(m) = data.(m)(teid,:);
        end
        
        % Nothing else to do with confounds
        if strcmp(m, 'C')
            continue
        end
        
        fprintf('Preprocessing data %s...', m);
        
        % Initialize folder/file for preprocessed data
        if ~isdir(fullfile(cfg.dir.load, 'preproc'))
            mkdir(fullfile(cfg.dir.load, 'preproc'))
        end
        if ismember(splittype, {'osplit' 'otrid' 'oteid' 'iext'})
            fnamepp = fullfile(cfg.dir.load, 'preproc', sprintf('preproc%s_split_%d.mat', ...
                lower(m), split(1)));
        elseif ismember(splittype, {'isplit' 'itrid' 'iteid'})
            fnamepp = fullfile(cfg.dir.load, 'preproc', sprintf('preproc%s_split_%d_subsample_%d.mat', ...
                lower(m), split(1), split(2)));
        elseif strcmp(splittype, 'oext')
            fnamepp = fullfile(cfg.dir.load, 'preproc', sprintf('preproc%s_oext.mat', lower(m)));
        end
        
        % Preprocess training and test data
        trdata = preproc_data(res, trdata, m, fnamepp, trid);
        if exist('teid', 'var')
            tedata = preproc_data(res, tedata, m, fnamepp);
        end
        fprintf('done!\n'); toc
        
        if ismember(cfg.machine.name, {'pls' 'spls'}) ...
                || (~exist('param', 'var') && ~strncmp(mod{i}, 'R', 1))
            % No need for SVD here
        
        else
            fprintf('Compute initial SVD for RAM/time-efficiency...');
            
            % Map examples into new feature space
            [trdata.(['V' m]), trdata.(['R' m]), trdata.(['L' m])] = fastsvd(...
                trdata.(m), 0, cfg.machine.eig.tol, cfg.machine.eig.varex, 'V', 'R', 'L');
            if exist('teid', 'var')
                tedata.(['R' m]) = tedata.(m) * trdata.(['V' m]);
            end
            
            % Remove original data to free up RAM
% % % % % % % %            trdata = rmfield(trdata, m);
            if exist('teid', 'var')
% % % % % %                tedata = rmfield(tedata, m);
            end
            
            % Save SVD results
            if ~exist_file(cfg, fullfile(cfg.dir.load, 'svd', ['tr_' fnamep]))
                name_value = parse_struct(trdata, 1, {[m] ['V' m] ['R' m] ['L' m]}); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                savemat(res, fullfile(cfg.dir.load, 'svd', ['tr_' fnamep]), name_value{:});
            end
            
            % Save SVD results
            if ~exist_file(cfg, fullfile(cfg.dir.load, 'svd', ['te_' fnamep])) && exist('teid', 'var')
                name_value = parse_struct(tedata, 1, {[m] ['R' m]}); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                savemat(res, fullfile(cfg.dir.load, 'svd', ['te_' fnamep]), name_value{:});
            end
            
        end
        
        fprintf('done!\n'); toc
    end
    
    % Define feature index
    if exist('param', 'var')
        if ismember(cfg.machine.name, {'pls' 'spls'})
            featid.(lower(m)) = true(1, cfg.data.(m).nfeat);
        else
            featid.(lower(m)) = get_featid(trdata, param, m);
        end
    end
    
    % Deflate data
    if res.frwork.level > 1 ...
            && (isfield(trdata, ['R' m]) || ismember(cfg.machine.name, {'pls' 'spls'}))
        [trdata, tedata] = deflate_data(res, trdata, tedata, m, split(1));
    end
    
end

% if exist('param', 'var') && ismember(cfg.machine.name, {'pls' 'spls'})    
%     % Initialize folder/file for SVD results
%     if ~isdir(fullfile(cfg.dir.load, 'svd', sprintf('level%d', res.frwork.level)))
%         mkdir(fullfile(cfg.dir.load, 'svd', sprintf('level%d', res.frwork.level)))
%     end
%     if numel(split) == 1
%         fname = sprintf('tr_svdxy_split_%d.mat', split(1));
%     elseif numel(split) == 2
%         fname = sprintf('tr_svdxy_split_%d_subsample_%d.mat', split(1), split(2));
%     end
%     fname = fullfile(cfg.dir.load, 'svd', sprintf('level%d', res.frwork.level), fname);
%     
%     if ~exist_file(cfg, fname)
%         fprintf('Compute initial SVD for RAM/time-efficiency...');
%         
%         % Calculate cross-covariance matrix
%         trdata.XY = trdata.X' * trdata.Y;
%         
%         % Calculate SVD on cross-covariance matrix
%         trdata.VXY = fastsvd(trdata.XY, 1, 0, 1, 'V');
%         
%         % Save SVD results
%         name_value = parse_struct(trdata, 1, {'XY' 'VXY'});
%         savemat(res, fname, name_value{:});
%         
%     else
%         fprintf('Loading initial SVD results of XY...');
%         
%         % Load SVD results
%         [trdata.XY, trdata.VXY] = loadmat(res, fname, 'XY', 'VXY');
%     end
%     
%     fprintf('done!\n'); toc
% end

% Remove confounds from modality if needed
if isfield(cfg.data, 'C')
    mod(ismember(mod, 'C')) = [];
end

% Assign output in data+id format
varargout = {trdata trid};

% if splittype=='oteid' % UNCOMMENT THIS ONLY WHEN RUNNING CALC_EXPVAR
%     varargout = {};   % UNCOMMENT THIS ONLY WHEN RUNNING CALC_EXPVAR
% end                   % UNCOMMENT THIS ONLY WHEN RUNNING CALC_EXPVAR

switch splittype
    case {'oteid' 'iteid' 'osplit' 'isplit'}
        varargout = [varargout {tedata teid}];
        if exist('param', 'var')
            varargout{end+1} = featid;
        end
        
    case 'iext'
        varargout = [varargout {tedata teid(size(otrid, 1)+1:end)}];
end


% --------------------------- Private functions ---------------------------

function data = load_data_mod(res, data, mod)

% Load modality data
tmp = load(res.data.(mod).fname);

if ~isfield(data, mod)
    % Assign data
    data.(mod) = tmp.(mod);
else
    % Concatenate data - features should match, otherwise padded with 0!!
    [nsubj1, nfeat1] = size(data.(mod));
    [nsubj2, nfeat2] = size(tmp.(mod));
    if nfeat1 > nfeat2
        data.(mod) = cat(1, data.(mod), [tmp.(mod) zeros(nsubj2, nfeat1-nfeat2)]);
        warning('Testing features of %s padded with 0 to be able to concatenate data.', mod)
    elseif nfeat1 < nfeat2
        data.(mod) = cat(1, [data.(mod) zeros(nsubj1, nfeat2-nfeat1)], tmp.(mod));
        warning('Training features of %s padded with 0 to be able to concatenate data.', mod)
    else
        data.(mod) = cat(1, data.(mod), tmp.(mod));
    end
end
