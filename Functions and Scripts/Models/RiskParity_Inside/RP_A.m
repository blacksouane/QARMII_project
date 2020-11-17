function [W, S, l] = RP_A(r, M, n, T, class)

[N, A] = size(r);
W = zeros(round((T - M)/21, 0), A);
l = zeros(round((T - M)/21, 0), 1);
S = zeros(round((T - M)/21, 0), A);
position = 1; 

f = zeros(1,A); %Vector having each first available return

    for i = 1:A
        f(i) = find (~ isnan(r(:,i)), 1);
    end

    for time = M+1:21:N
        
      
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);
   
        % Define returns to compute weights
        toCompute = r(time - n+1:time, Ind);
        toClass = class(Ind);
      
        % Compute the signal
        S(position,Ind) = binsignal(r(time - M:time, Ind));
        
        % Compute Weights
        W(position, Ind) = riskparity_A(toCompute,  n, T,toClass);
        
        % Compute Leverage
        W_l = W(position, Ind);
        C_l = cov(toCompute);
        l(position) = T / (sqrt(W_l*C_l*W_l.')*sqrt(252));
        
        position = position + 1;
    end
    
    
end