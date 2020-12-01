function [r,f] = ReturnNaN(p)

%Function Computing the r with a vector of price of heterogenic
%length.

%   INPUT:
% Vector of p

%*************************************

%   OUTPUT:
% r : Matrix of r
% f : Vector of first data value (after NaN)




%Setting the parameters 
N = size(p,2);

%Find the first non NAN Value
f = NaN(1,N); %Vector having each first available p

    for i = 1:N
        f(i) = find (~ isnan (p(:,i)), 1);
    end

% Computing Daily r 
r = NaN(length(p)-1,N);

    for i = 1:N
        
        for j = f(i):(length(p)-1)
            
        r(j,i) = p(j+1,i)/p(j,i)-1;
        
        end
        
    end
    
end

