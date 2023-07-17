function [varX, varY, varXY] = calc_expvar(res, splittype, split)

tol = 0;

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load parameters
if ~ismember(cfg.machine.name, {'pls' 'spls'})
    param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
end

for n=1:numel(split)
    % Load data at next level
    res.frwork.level = res.frwork.level + 1;
    if ismember(cfg.machine.name, {'pls' 'spls'})
        data2 = load_data(res, {'X' 'Y'}, splittype, split(n));
    else
        data2 = load_data(res, {'X' 'Y'}, splittype, split(n), param(n));
    end

    % Load original data
    res.frwork.level = 1;
    if ismember(cfg.machine.name, {'pls' 'spls'})
        data1 = load_data(res, {'X' 'Y'}, splittype, split(n));
    else
        data1 = load_data(res, {'X' 'Y'}, splittype, split(n), param(n));
    end
    
    % Percent explained variance in X
    if ~isfield(data1, 'RX') || ~isfield(data2, 'RX')
        [data1.RX, data1.VX] = fastsvd(data1.X, 0, tol, 1, 'R', 'V');
        [data2.RX, data2.VX] = fastsvd(data2.X, 0, tol, 1, 'R', 'V'); 
    end
    LX1 = trace(data1.RX' * data1.RX);
    LX2 = trace(data2.RX' * data2.RX);
    varX = (1 - LX2 / LX1) * 100;
    
    % Percent explained variance in Y
    if ~isfield(data1, 'RY') || ~isfield(data2, 'RY')
        [data1.RY, data1.VY] = fastsvd(data1.Y, 0, tol, 1, 'R', 'V');
        [data2.RY, data2.VY] = fastsvd(data2.Y, 0, tol, 1, 'R', 'V');
    end
    LY1 = trace(data1.RY' * data1.RY);
    LY2 = trace(data2.RY' * data2.RY);
    varY = (1 - LY2 / LY1) * 100;
    
    % Percent explained covariance in XY
    LXY1 = trace(data1.RX' * data1.RY * data1.RY' * data1.RX);
    LXY2 = trace(data2.RX' * data2.RY * data2.RY' * data2.RX);
    varXY = (1 - LXY2 / LXY1) * 100;
end
