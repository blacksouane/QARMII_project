function [W,S,L] = SSA_TF(P,R, EIG, M, varargin)
%{
INPUT

     P : Matrix of Price
     R : Matrix of Return
     EIG: Number of components
     M : Length of trajectory matrix and covariance matrix for risk based
         investing.
    
     VARARGIN :
    
    (2) SSA_TF(P,R, EIG, M,'Target', Vol.Target)
        Standard Model
    (3) SSA_TF(P,R, EIG, M, 'Quantity', Threshold, Vol.Target)
        Add a trading rule on the quantity of trend
    (3) SSA_TF(P,R, EIG, M, 'IndQuantity', Threshold, Vol.Target)
        Add a trading rule on the level of trenf of each asset
    

OUTPUT

     W : Weights of the allocation (Risk Parity Allocation)
     S : Signal
     L : Leverage to attain target
%}
%% Parameters

[T, A] = size(P);


% Find for available data
f = zeros(1,A); %Vector having each first available return

for i = 1:A
    f(i) = find (~ isnan(P(:,i)), 1);
end

% Preallocating the memory
W = zeros(round((T - M)/21, 0), A); %Weights
L = ones(round((T - M)/21, 0), 1); %Leverage
S = zeros(round((T - M)/21, 0), A); %Signal
position = 1; %allow for monthly rebalancing


%% Base Allocation

for t = M+1:21:T
    
    %Displaying position of the allocation
    if mod(position, 20) == 0
        fprintf('Allocation %d over %d has been performed !\n',position, round((T-(M+1))/21));
    end
    
    % Find index of available assets at t "t"
    available = f <= t - M;
    Ind = available==1;
    
    % Define returns and prices to compute weights and signals
    R_T = R(t-M+1:t,Ind);
    P_T = P(t-M:t,Ind);
    
    % Compute Grosse Weights
    W(position, Ind) = volparity(R_T);
    
    % Compute Signal
    S(position, Ind) = SSA_Signal(EIG, P_T, M);
    
    %% Correction on signal
    
    if strcmp(varargin(1), 'Target')
        
        % Leveraging the allocation
        W_T = W(position, Ind).*S(position, Ind);
        L(position) = cell2mat(varargin(2)) /...
            (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
        
    elseif strcmp(varargin(1), 'Quantity')
        
        % Quantity and threshold
        QT = sum(abs(S(position, :)));
        TH = sum(available)*cell2mat(varargin(2));
        
        if mod(position,20) == 0
            fprintf('The number of asset is %d, the threshold is %.4g and the quantity of trend is %.4g !\n',...
                sum(available), TH, QT);
            
        end
        if QT <= TH %if trend is smaller than threshold
            
            % We don't take any signal if there is not enough trend (long only)
            S(position, :) = 1;
            
        end
        
        % Leveraging the allocation
        W_T = W(position, Ind).*S(position, Ind);
        L(position) = cell2mat(varargin(3)) / ...
            (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
        
        
    else % Individual trend quantity case
        
        % Quantity and threshold
        TH = cell2mat(varargin(2));
        OUT = abs(S(position, :)) > TH;
        S(position, OUT==0) = abs(S(position, OUT==0));
        
        if mod(position,20) == 0
            fprintf(...
                'The number of asset is %d, the threshold is %.4g and the number of asset over the threshold are %d !\n',...
                sum(available), TH, sum(OUT));
        end
        
        % Leveraging the allocation
        W_T = W(position, Ind).*S(position, Ind);
        L(position) = cell2mat(varargin(3))...
            / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
        
    end
    position = position + 1;
end


end

