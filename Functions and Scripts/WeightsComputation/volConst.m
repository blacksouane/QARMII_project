function [c,ceq] = volConst(x,Target,CovMat)
%Volatility Constraint

% Setting the non-linear inequality (volatility) constraint
c = sqrt(252)*sqrt(x*CovMat*x.') - Target;

% Setting the unused equality constraint
ceq = [];

end

