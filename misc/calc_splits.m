function calc_splits(res, sptype)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Return if no need for inner loop
param = get_hyperparam(cfg, 'default'); % check if grid search needed
if strcmp(sptype, 'in') && numel(param) == 1
   return; 
end
    
% Set seed for reproducibility
rng(cfg.env.seed.split);

% Block structure for stratified partitioning
if isfield(cfg.frwork.split, 'EBcol')
    load(fullfile(cfg.dir.project, 'data', cfg.idf, 'EB.mat'))
    group = EB(:,cfg.frwork.split.EBcol);
else
    group = ones(cfg.data.nsubj, 1);
end
            
% Split data
switch sptype
    case 'out' % outer loop
        % Initialize train and test data
        trid = true(cfg.data.nsubj, cfg.frwork.split.nout);
        teid = false(size(trid));
        
        % Specify train and test data respecting block structure
        switch cfg.frwork.name
            case 'permutation' % all data
                teid = trid;
                
            case 'holdout' % random subsampling
                [trid, teid] = cvpartition_restricted(cfg, 'out', trid, teid, ...
                    group, 'HoldOut', cfg.frwork.split.propout);

            case 'cv' % cross-validation
                [trid, teid] = cvpartition_restricted(cfg, 'out', trid, teid, ...
                    group, 'KFold', cfg.frwork.split.nout);
                
            case 'fair' % cross-validation
                no_cv_temp=1/cfg.frwork.split.propout;
                [trid, teid] = cvpartition_restricted(cfg, 'out', trid, teid, ...
                    group, 'KFold', no_cv_temp);
                
        end
        
        % Save data
        savemat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', trid, 'oteid', teid);
        
    case 'in' % inner loop
        % Initialize train and test data
        otrid = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid');
        trid = repmat(otrid, 1, 1, cfg.frwork.split.nin);
        teid = false(size(trid));
            
        % Specify train and test data respecting block structure
        switch cfg.frwork.name
            case 'permutation' % all data
                teid = trid;
                
            case 'holdout' % random subsampling
                for i=1:cfg.frwork.split.nout
                    id = trid(:,i,1) == 1;
                    [trid(id,i,:), teid(id,i,:)] = cvpartition_restricted(cfg, 'in', squeeze(trid(id,i,:)), ...
                        squeeze(teid(id,i,:)), group(id,:), 'HoldOut', cfg.frwork.split.propin);
                end
                
            case 'cv' % cross-validation
                for i=1:cfg.frwork.split.nout
                    id = trid(:,i,1) == 1;
                    [trid(id,i,:), teid(id,i,:)] = cvpartition_restricted(cfg, 'in', squeeze(trid(id,i,:)), ...
                        squeeze(teid(id,i,:)), group(id,:), 'KFold', cfg.frwork.split.nin);
                end
                
            case 'fair' % cross-validation
                for i=1:cfg.frwork.split.nout
                    id = trid(:,i,1) == 1;
                    [trid(id,i,:), teid(id,i,:)] = cvpartition_restricted(cfg, 'in', squeeze(trid(id,i,:)), ...
                        squeeze(teid(id,i,:)), group(id,:), 'KFold', cfg.frwork.split.nin);
                end
                
        end
        
        % Save data
        savemat(res, fullfile(res.dir.frwork, 'inmat.mat'), 'itrid', trid, 'iteid', teid);
end


% --------------------------- Private functions ---------------------------

function [trid, teid] = cvpartition_restricted(cfg, sptype, trid, teid, group, varargin)
%   Wrapper function for cvpartition to be able to handle restricted 
% partitioning of data

% Get unique partions
[C, ia, ic] = unique(group, 'stable', 'rows');
if size(C, 1) == 1
    stratify = false;
    ic = 1:size(group, 1);
    C = group;
else
    stratify = true;
end
% if size(group, 2) == 1 || size(C, 1) == 1
%     ic = 1:size(group, 1);
%     C = group;                                                        
% end

% Build partitions from unique partitions
switch cfg.frwork.name
    case 'holdout' % random subsampling
        for i=1:cfg.frwork.split.(['n' sptype])
            partition = cvpartition(C(:,1), varargin{:}, 'Stratify', stratify);
            tmp = partition.training;
            trid(:,i) = tmp(ic);
            tmp = partition.test;
            teid(:,i) = tmp(ic);
        end
        
    case 'cv' % cross-validation
        partition = cvpartition(C(:,1), varargin{:}, 'Stratify', stratify);
        for i=1:cfg.frwork.split.(['n' sptype])
            tmp = partition.training(i);
            trid(:,i) = tmp(ic); 
            tmp = partition.test(i);
            teid(:,i) = tmp(ic);
        end
        
    case 'fair' % 
        if strcmp(sptype, 'out')
            no_cv_temp=varargin{2};
            partition = cvpartition(C(:,1), varargin{1}, no_cv_temp, 'Stratify', stratify);
            %create cv-many folds
            for i=1:no_cv_temp
                tmp = partition.training(i);
                trid(:,i) = tmp(ic);
                tmp = partition.test(i);
                teid(:,i) = tmp(ic);
            end
            %pick nout many sets
            trid=trid(:,1:cfg.frwork.split.nout);
            teid=teid(:,1:cfg.frwork.split.nout);
            
        else if strcmp(sptype, 'in')
                partition = cvpartition(C(:,1), varargin{:}, 'Stratify', stratify);
                for i=1:cfg.frwork.split.nin
                    tmp = partition.training(i);
                    trid(:,i) = tmp(ic);
                    tmp = partition.test(i);
                    teid(:,i) = tmp(ic);
                end
            else
                display('Dodgy stuff');
                return
            end
        end
end


