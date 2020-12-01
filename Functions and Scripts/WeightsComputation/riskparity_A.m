function [WF] = riskparity_A(r, n, T, class)

%% Defining optimization parameters

% Data parameters
[~, a] = size(r);

%Setting the unused parameters of the optimisation
A = []; %No linear constraint
b = []; %No linear constraint
Aeq = []; %No Bounds on the linear constraint
beq = []; %No Bounds on the linear constraint
lb = []; %No Bounds on the weights
ub = []; %No Bounds on the weights
warning ( 'off' , 'MATLAB:nearlySingularMatrix')

% Setting the objective function
fun = @(x) - sum(log(abs(x)));

% Options of the optimisation
options = optimoptions('fmincon','Display','off',...
    'algorithm','sqp','FiniteDifferenceType','central',...
    'OptimalityTolerance',1e-11);


%% Construct Initial Weights

% Construct class vectors

 % We assume that there is 4 asset class numbered 1, 2, 3, 4
asset_class = zeros(n,4);
W = zeros(1, a);

for Aclass = 1:4
    ind = find(class == Aclass);
    W(ind) = volparity(r(:, ind)); % Volatility Parity Weights
    asset_class(:, Aclass) = (W(ind)*r(:, ind)')'; % Vector for each asset class
end

% Construct optimisation starting points
Y = volparity(asset_class);

%% Performing the risk parity allocation

% Finding the n days covariance matrix
CovMat = cov(asset_class); 

% Optimizing the month's weights 
[W_T] = fmincon(@(x) fun(x),Y,A,b,Aeq,beq,lb,ub,...
@(x) volConst(x,T,CovMat),options);

% We construct the final weights
WF = zeros(1, a);
for Aclass = 1:4
 ind = find(class == Aclass);
 WF(ind) = W_T(Aclass)*W(ind);   
end

end

