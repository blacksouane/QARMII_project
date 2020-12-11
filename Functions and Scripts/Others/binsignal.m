function [s] = binsignal(r)
% binsignal computes the momentum signal in each asset in r.
%   For each asset (columns), we compute the geometrical return and assign:

%   a. + 1 for positive returns
%   b. - 1 for negative returns

% Get the last cumulative return
s = (cumprod(r + 1) - 1); 
s = s(end,:);

% Computing the signal
s(s<=0) = -1; 
s(s>0) = 1; 
 

end

