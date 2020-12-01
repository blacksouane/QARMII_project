function [Turnover] = turnoverp(Weights,Preturn,indivreturn)
% Weights need to be dimension NxT it is the vector of weight
% Preturn are the return of the portfolioas column vector
% indivreturn are the matrix of the individual return as column vector 
Preturn=Preturn.';
indivreturn=indivreturn.';
T=size(Weights,2)-1;
turnover=zeros(T-1,1);

disp(size(Preturn));
disp(size(indivreturn));
disp(size(Weights));

for t=2:T
    turnover(t-1,1)=sum(abs(Weights(:,t)-(Weights(:,t-1).*((1+indivreturn(:,t))/(1+Preturn(1,t-1))))));
end
Turnover=sum(turnover);

end

