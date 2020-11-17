function [D] = ReturnDecomposition(W, R, C)

% Function computing the retursn of a strategy
R(isnan(R)) = 0;

%Pre-allocating for speed
S = zeros(length(R),1);
D = zeros(length(R),4);

%Computing the return of the strat and it's decomposition
for i = 1:length(R)
    S(i) = W(i,:)*R(i,:);
    for c = 1:4
    D(i, c) = W(i,C == c)*R(i,C == c);   
    end
end


end

