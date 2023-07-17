function S = run_machine(cfg, trdata, tedata, featid, param, correl_type)

%----- Model training

% Run machine
switch cfg.machine.name
    case {'pls' 'spls'}
        % PLS/SPLS solved by power method
        [S.wX, S.wY] = spls(trdata, param, cfg.machine.tol, cfg.machine.maxiter);
        
    case {'cca' 'rcca'}
        % CCA/RCCA/PLS/PCA-CCA solved by standard eigenvalue problem
        [S.wX, S.wY] = rcca(trdata, featid, param);
end

%---- Model diagnostics

% Compute projections for training data
if ismember(cfg.machine.name, {'pls' 'spls'})
    trdata.PX = calc_proj(trdata.X, S.wX);
    trdata.PY = calc_proj(trdata.Y, S.wY);
else
    trdata.PY = calc_proj(trdata.RY(:,featid.y), S.wY);
    trdata.PX = calc_proj(trdata.RX(:,featid.x), S.wX);
end

% Compute training metrics
if ismember('trcorrel', cfg.machine.metric) %%|| strcmp(cfg.frwork.name, 'permutation')
    % Correlation
    S.trcorrel = corr(trdata.PX, trdata.PY, 'Type', correl_type);
end
if ismember('trcovar', cfg.machine.metric) %%|| strcmp(cfg.frwork.name, 'permutation')
    % Covariance
    S.trcovar = cov2(trdata.PX, trdata.PY);
end
        
%---- Model evaluation

% Compute projections for test data
% if strcmp(cfg.frwork.name, 'permutation')
%     % Correlation
%     S.correl = S.trcorrel;
% 
%     % Covariance
%     S.covar = S.trcovar;
% else
    if ismember(cfg.machine.name, {'pls' 'spls'})
        tedata.PX = calc_proj(tedata.X, S.wX);
        tedata.PY = calc_proj(tedata.Y, S.wY);
    else
        tedata.PX = calc_proj(tedata.RX(:,featid.x), S.wX);
        tedata.PY = calc_proj(tedata.RY(:,featid.y), S.wY);
    end
    
    % Compute test metrics
    if ismember('correl', cfg.machine.metric)
        % Correlation
        S.correl = corr(tedata.PX, tedata.PY, 'Type', correl_type);
    end
    if ismember('covar', cfg.machine.metric)
        % Covariance
        S.covar = cov2(tedata.PX, tedata.PY);
    end
% end

%---- Auxiliary steps

% Calculate primal weights
if ismember(cfg.machine.name, {'cca' 'rcca'})
    S.wX = trdata.VX(:,featid.x) * S.wX;
    S.wY = trdata.VY(:,featid.y) * S.wY;
end

% Record unsuccessful convergence for SPLS
if ismember('unsuc', cfg.machine.metric)
    S.unsuc = isnan(S.correl);
end