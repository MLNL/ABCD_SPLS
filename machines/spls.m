function [u, v] = spls(data, param, tol, maxiter)
% spls
%
% Implementation for Sparse PLS
%
% Syntax:  [u, v] = spls(cfg, data, param)
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
% See also: [rcca](../rcca/),  [fastsvd](../fastsvd/)
%
% Author: Joao Monteiro, Agoston Mihalik
%
% Website: http://www.mlnl.cs.ucl.ac.uk/

% Initialize variables
diff = Inf;
i = 0;
success = true;
data.XY = data.X' * data.Y;        
v = fastsvd(data.XY, 1, 0, 1, 'V');
    
while diff > tol && success    
    % Compute X weight
    u(:,2) = data.XY * v(:,1);
    u(:,2) = u(:,2) / norm(u(:,2));
    
    % Apply soft thresholding to obey constraint
    if param.L1x >= 1 && param.L1x <= sqrt(size(u, 1))
        [u(:,2), failed_sparsity] = iter_soft_threshold(u(:,2), param.L1x);
        if failed_sparsity
            warning('There was a problem with the delta estimation of the L1 regularization of wX');
            u(:,2) = NaN(size(u, 1), 1);
            break
        end
    end
    
    % Compute Y weight
    v(:,2) = data.XY' * u(:,2);
    v(:,2) = v(:,2) / norm(v(:,2));
    
    % Apply soft thresholding to obey constraint
    if param.L1y >= 1 && param.L1y <= sqrt(size(v, 1))
        [v(:,2), failed_sparsity] = iter_soft_threshold(v(:,2), param.L1y);
        if failed_sparsity
            warning('There was a problem with the delta estimation of the L1 regularization of wY');
            v(:,1) = NaN(size(v, 1), 1);
            break
        end
    end
    
    % Check convergence
    diff = max(norm(u(:,2) - u(:,1)), norm(v(:,2) - v(:,1)));
    if i >= maxiter
        warning('Maximum number of iterations reached.');
        success = false;
    end
    i = i+1;
    
    % Update weights
    u(:,1) = u(:,2);
    v(:,1) = v(:,2);
end

%--- Add converged weight vectors to output
u = u(:,2);
v = v(:,1); % index is due to the break statement