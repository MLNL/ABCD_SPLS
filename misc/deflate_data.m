function [trdata, tedata] = deflate_data(res, trdata, tedata, m, osplit, varargin)
% Various deflations for standard and regularized CCA/PLS
%
% All projection deflations below are subcases of the generalized
% deflation.
%
% Namely, the generalized eigenvalue problem is defined as: 
% A * w = lambda * B * w, 
%
% with A, B symmetric matrices, B positive definite
% 
% The generalized deflation is as follows:
% A <- A - lambda * B * w * w' * B'
%
% Notably, deflation of B is not needed.
%
% The generalized deflation can be written in the input feature space as:
% X <- X - X * wx * wx' * Bxx
% Y <- Y - Y * wy * wy' * Byy
%
% using the following notations:
% A = [0   Axy;     B = [Bxx   0;     w = [wx;
%      Ayx   0]          0   Bxy]          wy]
%
% Similarly, the generalized deflation in a transformed feature space is:
% RX <- RX - RX * wx * wx' * Bxx
% RY <- RY - RY * wy * wy' * Byy
%
% For further reading, see:
% Shawe-Taylor, Cristiani: Kernel methods for pattern analysis, 2004
% Mihalik et al Biol Psychiatry, 2020

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

for i=2:res.frwork.level
    % Get splits from previous level
    reso = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', i-1), ...
        'res.mat'), 'res');
    
    % Get primal weight
    w = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', ...
        i-1), 'model.mat'), ['w' m]);
            
    if ismember(cfg.machine.name, {'pls' 'spls'})
        % Select weight
        if strcmp(cfg.defl.crit, 'none')
            w = w(reso.frwork.split.all==osplit,:)';
        else
            w = w(reso.frwork.split.all==reso.frwork.split.best,:)';
        end
        
        if strcmp(cfg.defl.name, 'pls-projection')
            % Projection deflation for PLS/SPLS
            % ---------------------------------
            % 1. symmetric deflation, i.e. X, Y interchangeable
            % 2. both X and Y data are deflated
            % 3. subcase of the generalized deflation with the following
            %    choice of Bxx, Byy:
            %      - Bxx = I and Byy = I
            % 4. orthogonalizes u[i], v[i] to u[j], v[j] where i != j
            % 5. equivalent to Hotelling 's deflation if non-sparse (i.e. u, v
            %    are true singular vectors)
            
            % Deflation step
            trdata.(m) = trdata.(m) - (trdata.(m) * w) * w';
            if ~isempty(fieldnames(tedata))
                tedata.(m) = tedata.(m) - (tedata.(m) * w) * w';
            end
            
        elseif strcmp(cfg.defl.name, 'pls-modeA')
            % Mode-A deflation for PLS/SPLS correlation (PLSC)
            % ------------------------------------------------
            % 1. symmetric deflation, i.e. X, Y interchangeable
            % 2. both X and Y are deflated
            % 3. orthogonalizes Xu[i], Yv[i] to Xu[j], Yv[j] where i != j and
            %    it holds even when u, v are sparse
            % 4. orthogonalizes u[i], v[i] to u[j], v[j] where i != j if
            %    u, v non-sparse
            % 5. used both in SPLS (Le Cao et al 2008, 2009) and PLS (Wegelin 2000)
            % 6. equivalent to PLS regression deflation in case of X
            % 7. equivalent to PLS projection deflation if X'*X = I and Y'*Y = I
            
            % Loadings based on training data
            p = trdata.(m)' * (trdata.(m) * w) / ((trdata.(m) * w)' * (trdata.(m) * w));
            
            % Deflation step
            trdata.(m) = trdata.(m) - (trdata.(m) * w) * p';
            if ~isempty(fieldnames(tedata))
                tedata.(m) = tedata.(m) - (tedata.(m) * w) * p';
            end
            
        elseif strcmp(cfg.defl.name, 'pls-regression')
            % Regression deflation for PLS/SPLS regression (PLSR)
            % ---------------------------------------------------
            % 1. asymmetric deflation, predicts Y from X
            % 2. only X is deflated, deflation of Y is not necessary or
            %    needs to be done using loading of X (Shawe-Taylor, Cristiani 2004)
            % 3. equivalent to PLS mode-A deflation of X, for properties see
            %    there
            
            if strcmp(m, 'X')
                % Loadings based on training data
                p = trdata.(m)' * (trdata.(m) * w) / ((trdata.(m) * w)' * (trdata.(m) * w));
                
                % Deflation step
                trdata.(m) = trdata.(m) - (trdata.(m) * w) * p';
                if ~isempty(fieldnames(tedata))
                    tedata.(m) = tedata.(m) - (tedata.(m) * w) * p';
                end
            end
        end
        
    else
        % Select weight
        if strcmp(cfg.defl.crit, 'none')
            split = osplit;
        else
            split = reso.frwork.split.best;
        end
        w = w(reso.frwork.split.all==split,:)';
        
        % Get hyperparameters
        param = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', ...
            i-1), 'param.mat'), 'param');
        t = param(reso.frwork.split.all==split).(['L2' lower(m)]);
        
        % Define feature index
        featid = get_featid(trdata, param(reso.frwork.split.all==split), m);

        if strcmp(cfg.defl.name, 'generalized')
            % Generalized deflation for CCA/RCCA
            % ---------------------------------
            % 1. symmetric deflation, i.e. X, Y interchangeable
            % 2. both X and Y are deflated
            % 3. subcase of the generalized deflation with the following
            %    choice of Bxx, Byy in the input space:
            %     - Bxx = (1-tx) * X' * X / (n-1) + tx * I
            %     - Byy = (1-ty) * Y' * Y / (n-1) + ty * I
            %       where X, Y refer to the original X, Y data and the
            %       hyperparameters (tx, ty) define regularized CCA which
            %       smooths between CCA (tx=ty=0) and PLS (tx=ty=1)
            % 4. for RAM/time-efficiency, the input space is mapped into a 
            %    new feature space defined by the principal components of X
            %    and Y. Consequently, Bxx and Byy are:
            %     - Bxx = (1-tx) * SX' * SX / (n-1) + tx * I
            %     - Byy = (1-ty) * SY' * SY / (n-1) + ty * I
            %       where X = UX * SX * VX' and Y = UY * SY * VY' and the
            %       hyperparameters are as above
            
            % Calculate weight in new feature space
            w = trdata.(['V' m])(:,featid)' * w;

            % Variance based on training data
            B = (1-t) * trdata.(['L' m])(featid) + repmat(t, sum(featid), 1);
            
            % Deflation step
            trdata.(['R' m])(:,featid) = trdata.(['R' m])(:,featid) - ...
                (trdata.(['R' m])(:,featid) * w) * (w' * diag(B));
            if ~isempty(fieldnames(tedata))
                tedata.(['R' m])(:,featid) = tedata.(['R' m])(:,featid) - ...
                    (tedata.(['R' m])(:,featid) * w) * (w' * diag(B));
            end
        end
        
        
    end
end