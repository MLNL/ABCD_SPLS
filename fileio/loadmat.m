function varargout = loadmat(res, fname, varargin)
% loadmat
%   Some description here

% Parse fname
[pathstr, name, ext] = fileparts(fname);
if isempty(res.env.fileend)
    filename = getfname(pathstr, ['^' name ext]);
else
    filename = getfname(pathstr, ['^' name '_\d+' ext]);
end

timestamp = clock;

while ~isempty(filename)
    % Try loading data
    try
        S = load(fullfile(pathstr, filename{1}));
        varargout = cellfun(@(x) S.(x), varargin, 'un', 0);
        break;
    catch
        % Keep looping if file is temporarily unavailable
        if etime(clock, timestamp) < 60
            pause(10*rand); % wait a bit
            continue;
%                      elseif etime(clock, datevec(f(ismember({f.name}, [name ext])).datenum)) < 600
%                          fname % this branch might not work, so variables are displayed for debugging
%                          f = dir(pathstr)
%                          f(ismember({f.name}, [name ext])).datenum
%                          continue;
        else
            delete(fullfile(pathstr, filename{1}));
            warning('File corrupt: %s\n', fullfile(pathstr, filename{1}));
            %error('File corrupt: %s\n', fullfile(pathstr, file(1).name));
            filename(1) = [];
        end
    end
end