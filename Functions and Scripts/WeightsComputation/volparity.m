function w = volparity(r)
% Compute the volatility allocation on the assets

% INPUT
    % r : Returns of the assets

% OUTPUT
    % w : Weights of the allocation
    
    
% Computing the volatilites
v = std(r); % Computing volatilities
i = v.^-1; % Inverting the volatilities
s = sum(i); 

% Computing the weights
w = i/s;









end