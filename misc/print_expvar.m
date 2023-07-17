function print_expvar(res)

if ~isfield(res.frwork.split, 'best')
    res.frwork.split.best = 1;
end

tol = 1e-8;

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load parameters
if ~ismember(cfg.machine.name, {'pls' 'spls'})
    param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
end

for n=res.frwork.split.best
    % Load data at next level
    res.frwork.level = res.frwork.level + 1;
    if ismember(cfg.machine.name, {'pls' 'spls'})
        [trdata2, ~, tedata2] = load_data(res, {'X' 'Y'}, 'osplit', res.frwork.split.all(n));
    else
        [trdata2, ~, tedata2] = load_data(res, {'X' 'Y'}, 'osplit', res.frwork.split.all(n), param(n));
    end
    % Load original data
    res.frwork.level = 1;
    if ismember(cfg.machine.name, {'pls' 'spls'})
        [trdata1, ~, tedata1] = load_data(res, {'X' 'Y'}, 'osplit', res.frwork.split.all(n));
    else
        [trdata1, ~, tedata1] = load_data(res, {'X' 'Y'}, 'osplit', res.frwork.split.all(n), param(n));
    end

    fprintf('Training data\n-------------\n');
    
    if ~isfield(trdata1, 'RX') || ~isfield(trdata2, 'RX')
        [trdata1.RX, trdata1.VX] = fastsvd(trdata1.X, 0, tol, 'R', 'V');
        [trdata2.RX, trdata2.VX] = fastsvd(trdata2.X, 0, tol, 'R', 'V'); 
    end
    LX1 = trace(trdata1.RX' * trdata1.RX);
    LX2 = trace(trdata2.RX' * trdata2.RX);
    fprintf('Percent explained variance in X: %.2f\n', (1-LX2/LX1)*100);
    
    if ~isfield(trdata1, 'RY') || ~isfield(trdata2, 'RY')
        [trdata1.RY, trdata1.VY] = fastsvd(trdata1.Y, 0, tol, 'R', 'V');
        [trdata2.RY, trdata2.VY] = fastsvd(trdata2.Y, 0, tol, 'R', 'V');
    end
    LY1 = trace(trdata1.RY' * trdata1.RY);
    LY2 = trace(trdata2.RY' * trdata2.RY);
    fprintf('Percent explained variance in Y: %.2f\n', (1-LY2/LY1)*100);
    
    LXY1 = trace(trdata1.RX' * trdata1.RY * trdata1.RY' * trdata1.RX);
    LXY2 = trace(trdata2.RX' * trdata2.RY * trdata2.RY' * trdata2.RX);
    fprintf('Percent explained covariance in XY: %.2f\n', (1-LXY2/LXY1)*100);
    
    fprintf('Testing data\n------------\n');
    
    if ~isfield(tedata1, 'RX') || ~isfield(tedata2, 'RX')
        tedata1.RX = tedata1.X * trdata1.VX;
        tedata2.RX = tedata2.X * trdata2.VX;
    end
    LX1 = trace(tedata1.RX' * tedata1.RX);
    LX2 = trace(tedata2.RX' * tedata2.RX);
    fprintf('Percent explained variance in X: %.2f\n', (1-LX2/LX1)*100);
    
    if ~isfield(tedata1, 'RY') || ~isfield(tedata2, 'RY')
        tedata1.RY = tedata1.Y * trdata1.VY;
        tedata2.RY = tedata2.Y * trdata2.VY;
    end
    LY1 = trace(tedata1.RY' * tedata1.RY);
    LY2 = trace(tedata2.RY' * tedata2.RY);
    fprintf('Percent explained variance in Y: %.2f\n', (1-LY2/LY1)*100);
    
    LXY1 = trace(tedata1.RX' * tedata1.RY * tedata1.RY' * tedata1.RX);
    LXY2 = trace(tedata2.RX' * tedata2.RY * tedata2.RY' * tedata2.RX);
    fprintf('Percent explained covariance in XY: %.2f\n', (1-LXY2/LXY1)*100);
end
