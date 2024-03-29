function [up, failed] = iter_soft_threshold(w, c)

failed = false;

%--- update values
delta = 0;
up = soft_threshold(w, delta);
up = up./norm(up,2);

%--- check if it obeys the condition. If not, find delta that does.
if norm(up, 1) > c
    delta1 = delta;
    delta2  = delta1+1.1; % delta2 must be > 1
    
    % get first estimate of delta2
    flag = false;
    i = 0;
    max_delta = 0;
    while ~flag
        up = soft_threshold(w, delta2);
        up = up./norm(up,2);
        
        if sum(abs(up)) == 0 || isnan(sum(abs(up))) % if everthing is zero, the up/|up| will be 0/0 = nan
            delta2 = delta2/1.618; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) > c
            delta1 = delta2;
            delta2 = delta2*2; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) <= c
            flag = true;
        end
        
        if delta2>max_delta, max_delta = delta2;end
        
        if delta2 == 0
            warning('Delta has to be zero.');
            failed = true;
            break
        end
        i = i+1;
        if i>1E4
            warning('First delta estimation update did not converge.');
            delta1 = 0;
            delta2 = max_delta;
            break
        end
    end
    
    up = bisec(w, c, delta1, delta2);
    if isempty(up) || sum(isnan(up))>0
        warning('Delta estimation unsuccessful.')
        failed = true;
    end
end


function out = soft_threshold(a,delta)
% Performs soft threshold (it does not normalize the output)
diff = abs(a)-delta;
diff(diff<0) = 0;
out = sign(a).*diff;


function out = bisec(K, c, x1,x2)
converge = false;
success = true;
tolerance = 1E-6;
while ~converge && success
    x = (x2 + x1) / 2;
    out = soft_threshold(K, x);
    out = out./norm(out,2);
    if sum(abs(out)) == 0
        x2 = x;
    elseif norm(out, 1) > c
        x1 = x;
    elseif norm(out, 1) < c
        x2 = x;
    end
    
    diff = abs(norm(out, 1) - c);
    if diff <= tolerance
        converge = true;
    elseif isnan(sum(diff))
        success = false;
        out = nan(size(K));
    end
end