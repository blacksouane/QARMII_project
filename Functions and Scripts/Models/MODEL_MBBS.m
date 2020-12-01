function [W,S,L,w1] = MODEL_MBBS(P, R, n, D1, D2, PW, SW, varargin)

%INPUT

% P : Matrix of Price
% R : Matrix of Return
% n : length of Forecastatility of Risk Parity
% D1: Short MA
% D2: Long MA
% PW: Scaling 1
% SW. Scaling 2
% VARARGIN : Varagin arguments come by pair.
%'Target' -> A volatility Target such a 15% (0.15)
%'Quantity' -> A % of the max value for the signal (i.e the
%number of assets).
%'Forecast' -> A method. for now only "Garch"

%% Assert Input validity

assert(strcmp(varargin(1),'Target') || strcmp(varargin(1),'Quantity')|| ...
    strcmp(varargin(1),'Forecast')|| strcmp(varargin(1),'IndQuantity')...
    || strcmp(varargin(1),'Signal'), 'Not available varargin options')


%% Parameters
[T, A] = size(R);


% Find for available data
f = zeros(1,A); %Vector having each first available return

for i = 1:A
    f(i) = find (~ isnan(R(:,i)), 1);
end
M = SW + 100;

% Preallocating the memory
W = zeros(round((T - M)/21, 0), A); %Weights
L = ones(round((T - M)/21, 0), 1); %Leverage
S = zeros(round((T - M)/21, 0), A); %Signal
position = 1; %allow for monthly rebalancing


%% Performing Allocation

for time = M+1:21:T
    
    %Displaying position of the allocation
    if mod(position, 20) == 0
        fprintf('Allocation %d over %d has been performed !\n',position, round((T-(M+2))/21));
    end
    % Find index of available assets at time "time"
    available = f <= time - M;
    Ind = available==1;
    
    % Define returns and prices to compute weights and signals
    R_T = R(time-n+1:time,Ind);
    P_T = P(time-M:time,Ind);
    
    % Compute Grosse Weights
    W(position, Ind) = volparity(R_T);
    
    % Compute Signal
    S(position, Ind) = ewmaCO(P_T, 100);
    %[S(position, Ind),~,~,~,~] = bazsignal(P_T, D1, D2, PW, SW);
    
    % Advanced method
    if strcmp(varargin(1), 'Target')
        % We are taking leverage to get a constant running Volatility
        W_T = W(position, Ind).*S(position, Ind);
        L(position) = cell2mat(varargin(2)) / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
        
    elseif strcmp(varargin(1), 'Forecast')
        %Garch ,....l
        ret_asset = cell2mat(varargin(3));
        ret_asset = ret_asset(time-452+1:time);
        x1 = GARCH_reg_predict(ret_asset,199,252,5); % Scalar Value -> Predicted Vol
        w1(position,1) = tradingrule_garch(sqrt(x1),0.018,0.022,0.027,0.032,0.0357); % subjective level based on graphical analysis
        % W_T(position, Ind) = (W(position, Ind).*S(position, Ind)).*w1(position,1); % see the trading rule function for pftlo lvl in risky
        % L(position) = cell2mat(varargin(2)) / (sqrt(W_T(position, Ind)*cov(R_T)*W_T(position, Ind).')*sqrt(252));
        % W(position,Ind) = W_T(position, Ind);
        
    elseif strcmp(varargin(1), 'Quantity') %We compute the quantity of trend
        
        % Compute parameters
        QT = sum(abs(S(position, :)));
        TH = sum(available)*cell2mat(varargin(2));
        
        if mod(position,20) == 0
            fprintf('The number of asset is %d, the threshold is %.4g and the quantity of trend is %.4g !\n',...
                sum(available), TH, QT);
            
        end
        if QT <= TH %if trend is smaller than threshold
            
            % We don't take any signal if there is not enough trend (long only)
            S(position, :) = 1;
            
            
            %{
    elseif QT > sum(available) - TH %Here we have a lot of trend
        
        % We increase our investment (we take massive directional bets)
        S(position, :) = S(position, :)*2;
            %}
        end
        
        if length(varargin) > 2
            
            % We are taking leverage to get a constant running Volatility
            W_T = W(position, Ind).*S(position, Ind);
            L(position) = cell2mat(varargin(3)) / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
            
        end
        
    elseif strcmp(varargin(1), 'IndQuantity') %Indivual Trend Quantity
        
        TH = cell2mat(varargin(2));
        OUT = abs(S(position, :)) > TH;
        S(position, OUT==0) = abs(S(position, OUT==0));
        
        if mod(position,20) == 0
            fprintf(...
                'The number of asset is %d, the threshold is %.4g and the number of asset over the threshold are %d !\n',...
                sum(available), TH, sum(OUT));
        end
        
        
        if length(varargin) > 2
            
            % We are taking leverage to get a constant running Volatility
            W_T = W(position, Ind).*S(position, Ind);
            L(position) = cell2mat(varargin(3)) / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
            
        end
        
    else %Just signal
        
        QT = sum(abs(S(position, :)));
        TH = sum(available)*cell2mat(varargin(2));
        
        if mod(position,20) == 0
            fprintf('The number of asset is %d, the threshold is %.4g and the quantity of trend is %.4g !\n',...
                sum(available), TH, QT);
            
        end
        if QT <= TH %if trend is smaller than threshold
            
            % We don't take any signal if there is not enough trend (long only)
            S(position, :) = 1;%abs(S(position, :));
            
        end
        
        W = ones(round((T - M)/21, 0), A); %Weights
        
        if length(varargin) > 2
            
            % We are taking leverage to get a constant running Volatility
            W_T = W(position, Ind).*S(position, Ind);
            L(position) = cell2mat(varargin(3)) / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
            
        end
        
        
    end
    
    % Go for next rebalancing
    position = position + 1;
end


end

