function varargout = fastsvd(X, n, tol, varex, varargin)
% fastsvd
%
% Implementation for RAM/time-efficient Singular Value Decomposition (SVD)
%
% Syntax:  [U, S, V, R, L] = fastsvd(X, n, tol, varex, varargin)
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
% See also: [spls](../spls/), [rcca](../rcca/)
%
% Author: Agoston Mihalik
%
% Website: http://www.mlnl.cs.ucl.ac.uk/

% Data dimensionality
[nrows, ncols] = size(X);

% Number of singular values
if n == 0
    n = min([nrows ncols]);
end

% Calculate SVD based on dimensionality
if nrows < ncols
    % Kernel matrix
    U = X * X';
    
    if n < nrows
        % Calculate subset of left singular vectors (in descending order)
        % and eigenvalues
        [U, L] = eigs(U, n);
        L = diag(L);
    else
        % Calculate left singular vectors (in descending order) and
        % eigenvalues
        [U, L] = eig(U);
        L = diag(L);
        L = flipud(L);
        U = fliplr(U);
    end
    
    % Remove badly scaled seigenvalues
    U(:,abs(L)<tol) = [];
    L(abs(L)<tol) = [];
    if isempty(L)
        error('All eigenvalues are removed, probably due to badly scaled features.')
    end
    
    % Remove small eigenvalues
	if varex < 1
		U(:,cumsum(L) / sum(L) > varex) = [];
		L(cumsum(L) / sum(L) > varex) = [];
	end
    if isempty(L)
        error('All eigenvalues are removed, probably due to bad eigendecomposition settings.')
    end
    
    % Calculate singular values and right singular vectors
    if any(ismember(varargin, {'R' 'S' 'V'}))
        S = sqrt(abs(L));
    end
    if ismember('V', varargin)
        V = X' * (U * diag(1./S));
%         V = X' * bsxfun(@times, U, 1./S');
    end
    
else
    % Covariance matrix
    V = X' * X;
    
    if n < ncols
        % Calculate subset of right singular vectors (in descending order)
        % and eigenvalues
        [V, L] = eigs(V, n);
        L = diag(L);
    else
        % Calculate right singular vectors (in descending order) and
        % eigenvalues
        [V, L] = eig(V);
        L = diag(L);
        L = flipud(L);
        V = fliplr(V);
    end
    
    % Remove badly scaled eigenvalues
    V(:,abs(L)<tol) = [];
    L(abs(L)<tol) = [];
    if isempty(L)
        error('All eigenvalues are removed, probably due to badly scaled features.')
    end
    
    % Remove small eigenvalues
	if varex < 1
		V(:,cumsum(L) / sum(L) > varex) = [];
		L(cumsum(L) / sum(L) > varex) = [];
	end
    if isempty(L)
        error('All eigenvalues are removed, probably due to bad eigendecomposition settings.')
    end
    
    % Calculate singular values and right singular vectors
    if any(ismember(varargin, {'R' 'S' 'U'}))
        S = sqrt(abs(L));
    end
    if any(ismember(varargin, {'R' 'U'}))
        U = X * (V * diag(1./S));
%         U = X * bsxfun(@times, V, 1./S');
    end
end

if ismember('R', varargin)
    % Calculate data in new feature space (U*S = X*V, but the previous is faster)
    R = U * diag(S);
%     R = bsxfun(@times, U, S');
end

% Assign outputs with eval (rare exception for using eval!)
for i=1:numel(varargin)
   varargout{i} = eval(varargin{i});
end
