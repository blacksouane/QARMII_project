function [W, S, L] = SVM_Strategy(data, n, Model, C, F, Option)

% Test function, we start around 4000
start = Model.day;
data = data(start+127:end,:); % initially +1
M = 90;
position = 1;
disp(size(data));
[T, A] = size(data);

% Find for available data
f = zeros(1,A); %Vector having each first available return

    for i = 1:A
        f(i) = find (~ isnan(data(:,i)), 1);
    end
    
for time = M+1:21:T

% Find index of available assets at time "time"
available = f <= time - M; 
Ind = available==1;

% Define returns and prices to compute weights and signals
R_T = data(time-n:time-1,Ind); %enlever le +1 de time-n+1 pck on commence a M+1-n+1 commence en 2

if strcmp(Option,'VolParity')
% Compute Grosse Weights
W(position, Ind) = volparity(R_T);

elseif strcmp(Option,'RiskParity')
% Finding the n days covariance matrix  
initial = volparity(R_T);
[W(position, Ind), ~] = riskparity(R_T,  n-1, 0.1,initial, 'vol');

else % equally weighted
W(position, Ind) = 1/sum(available);  

end
% Compute Signal
[S(position, Ind)] = SVM_Signal(data(time-M:time-1,Ind),Model.Model, C, F); % enlever le time-m+1 et ajouter -1

% We are taking leverage to get a constant running Volatility
W_T = W(position, Ind).*S(position, Ind);
L(position) = 0.1 / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
position = position + 1;  

end


end

