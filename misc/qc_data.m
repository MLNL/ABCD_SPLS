function [flagcol, flagrow] = qc_data(data, varargin)

% Parse inputs and update defaults
S = parse_input(varargin{:});
def = parse_input('feat.freq.cut', 0.95 / 0.05, 'feat.freq.nan', 0.9, 'feat.sqdev.range', 100, ...
    'sub.freq.nan', 0.9);
S = assign_defaults(S, def);

% Initialize array for flagging subjects and features
[nsub, nfeat] = size(data);
flagcol = false(1, nfeat);
flagrow = false(nsub, 1);

for i=1:nfeat
    % Check if too many missing values in features
    % REF: ?Aln�s et al (2020) Proc Natl Acad Sci 202001517 
    if sum(isnan(data(:,i))) / nsub > S.feat.freq.nan
        flagcol(i) = true;
        continue;
    end
    
    % Remove missing values
    x = data(~isnan(data(:,i)),i);
    
    % Get unique values
    [ux, ~, ix] = unique(x);
    
    % Check if only one unique value
    % REF: Smith et al (2015) Nat Neurosci 18, 1565
    if numel(ux) == 1
        flagcol(i) = true;
        continue;
    end
    
    % Check if ratio of most and second most frequent values is too high
    % REF: ?Aln�s et al (2020) Proc Natl Acad Sci 202001517 
    freq = sort(accumarray(ix, 1), 'descend');
    if freq(1) / freq(2) > S.feat.freq.cut
        flagcol(i) = true;
        continue
    end
    
    % Check if extreme outliers
    % REF: Smith et al (2015) Nat Neurosci 18, 1565
    med = median(x);
    sqdev = (x - med) .^ 2;
    if max(sqdev) > S.feat.sqdev.range * mean(sqdev)
        flagcol(i) = true;
    end
end

% Check if too many missing values in subjects
% REF: ?Aln�s et al (2020) Proc Natl Acad Sci 202001517 
for i=1:nsub
    if sum(isnan(data(i,~flagcol))) / (nfeat-sum(flagcol)) > S.sub.freq.nan
        flagrow(i) = true;
    end
end


