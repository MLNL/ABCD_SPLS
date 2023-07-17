function [weight, iweight] = postproc_corr(res, weight, modtype,corrVal)

res.(modtype).weight.sorttype = 'abs';

% Sort weights if requested
if strcmp(res.(modtype).weight.sorttype, '')
    iweight = 1:numel(weight); % we keep original order
elseif strcmp(res.(modtype).weight.sorttype, 'abs')
    [~, iweight] = sort(abs(weight), 'descend');
elseif strcmp(res.(modtype).weight.sorttype, 'sign')
    [~, iweight] = sort(weight, 'descend');
end

weight(abs(weight)<abs(corrVal)) = 0;


% Keep only positive/negative weights if requested
if isfield(res.(modtype).weight, 'sign')
    if strcmp(res.(modtype).weight.sign, 'positive')
        weight(weight<0) = 0;
    elseif strcmp(res.(modtype).weight.sign, 'negative')
        weight(weight>0) = 0;
    end
end

% Keep only top weights if requested
if ~isinf(res.(modtype).weight.numtop)
    if strcmp(res.(modtype).weight.sorttype, 'abs') && sum(weight~=0) >= res.(modtype).weight.numtop
        weight(iweight(res.(modtype).weight.numtop+1:end)) = 0;
    end
end

[~, iweight] = sort(weight, 'descend');

