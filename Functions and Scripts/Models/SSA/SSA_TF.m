function [W,S,L] = SSA_TF(P,R, EIG, M, varargin)
%{

This function allows to backtest a trendfollowing strategy using a signal
based on Singular Spectral Analysis which allows to extract the trend
between the data (filtering noise and seasonal moves). 

The implementation is based on : 

https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/58967/versions/2/previews/html/SSA_beginners_guide_v7.html

To use this function, you also need SSA_Signal which compute the signal and
the weighting schemes functions 'VolParity.m' and 'riskparity.m'. The input
and output are explained now : 

INPUT
     There are four Required Inputs:
     P : Matrix of Price
     R : Matrix of Return
     EIG: Number of components
     M : Length of trajectory matrix and covariance matrix for risk based
         investing.
    

    Then all inputs are passed into varargin as name/pair arguments
    
    - 'weight' , a weighting scheme between 'EW', 'volParity',
    'riskParity'. Default is volParity.
    - 'tradingRule', a trading rule based on the quantity of trend between:
                    1. 'noRule'
                    2. 'overQuantity' , we do not change our position if
                    the overall quantity of trend is smaller than a
                    threshold (next name/pair argument). 
                    3. 'indQuantity', we apply the same rule but on each
                    asset. 
                    Default is 'noRule'.
    - 'tradingTarget', a numeric value in [0, 1] which is the treshold for
    the 'tradingRule'. Default is 0.5.

    - 'volTarget', a numeric value allowing for a constant running
    volatility. Default is 0.1. 

    - 'ssaScale', a scalar that is used in SSA_Signal(..., varargin) to
    rescale the extreme trends between [-ssaScale, ssaScale]. Default is 2.
    
    - 'ssaMinMax', a scalar that is used to rescale all the weights between
    [-ssaMinMax, ssaMinMax], it is apply after 'ssaScale' in SSA_Signal.
    Default is 1. 
    

OUTPUT

     W : Weights of the allocation (Risk Parity Allocation)
     S : Signal (SSA -> Can be corrected with trading rules)
     L : Leverage to attain volatility target

%}
%% Input Parsing
%Create Parser Object
ssaInput = inputParser;

% Define Weighting Scheme Parameters
defaultWeighting = 'volParity';
validWeighting = {'EW','volParity', 'riskParity'};
checkWeighting = @(x) any(validatestring(x, validWeighting));

% Define TradingRule Parameters
defaultTrading = 'noRule'; 
validTrading = {'noRule', 'overQuantity', 'indQuantity'}; 
checkTrading = @(x) any(validatestring(x, validTrading));

% Define TradingRuleLevel parameters
defaultTradingLevel = 0.5; 
checkTradingLevel = @(x) isnumeric(x) && (x >= 0) && (x <= 1);

% Define volTarget parameters
defaultVolTarget = 0.1; 
checkVolTarget = @(x) isnumeric(x);

% Define ssaRescale parameters
defaultScale = 1; 
checkScale = @(x) isnumeric(x);

%Define ssaMinMax parameters
defaultMinMax = 2;
checkMinMax = @(x) isnumeric(x);

% Verbosity
defaultVerbose = 1;
checkVerbose = @(x) x == 0 || x==1;

% Create Parsing Structure
addRequired(ssaInput, 'P');
addRequired(ssaInput, 'R');
addRequired(ssaInput, 'EIG'); 
addRequired(ssaInput, 'M');
addParameter(ssaInput, 'weight', defaultWeighting, checkWeighting);
addParameter(ssaInput, 'tradingRule', defaultTrading, checkTrading); 
addParameter(ssaInput, 'tradingTarget', defaultTradingLevel, checkTradingLevel);
addParameter(ssaInput, 'volTarget', defaultVolTarget, checkVolTarget);
addParameter(ssaInput, 'ssaScale', defaultScale, checkScale);
addParameter(ssaInput, 'ssaMinMax', defaultMinMax, checkMinMax);
addParameter(ssaInput, 'verbose', defaultVerbose, checkVerbose);

% Parse the inputs
parse(ssaInput, P, R, EIG, M, varargin{:})
%% Input extracting and Parameters

% Check for empty name/pair arguments and display it/them
if ssaInput.Results.verbose == 1
    if ~isempty(ssaInput.UsingDefaults)
        disp('Using defaults: ')
        disp(ssaInput.UsingDefaults)
    end
end

% Size Parameters
[T, A] = size(P);

% Find vector of first available data
f = zeros(1,A);

for i = 1:A
    f(i) = find (~ isnan(P(:,i)), 1);
end

% Preallocating the memory for output
W = zeros(round((T - M)/21, 0), A);
L = ones(round((T - M)/21, 0), 1); 
S = zeros(round((T - M)/21, 0), A);

% Define positon matching
position = 1; 
%% Loop Allocation

for t = M+1:21:T
    
    %Displaying position of the allocation
    if ssaInput.Results.verbose == 1
        if mod(position, 20) == 0
            fprintf('Allocation %d over %d has been performed !\n',position, round((T-(M+1))/21));
        end
    end
    
    % Find index of available assets at t "t"
    available = f <= t - M;
    Ind = available==1;
    
    % Define returns and prices to compute weights and signals
    R_T = R(t-M+1:t,Ind);
    P_T = P(t-M:t,Ind);
    
    % Compute Signal
    S(position, Ind) = SSA_Signal(EIG, P_T, M, 'scale', ...
        ssaInput.Results.ssaScale, 'minMax', ssaInput.Results.ssaMinMax);
    
    %**********************************************************************
    % Handle Weighting Scheme
    if strcmp(ssaInput.Results.weight, 'EW')
        
        W(position,Ind) = 1/sum(available);
        
    elseif strcmp(ssaInput.Results.weight, 'riskParity')  
        
        optiStart = volparity(R_T);
        [W(position, Ind), ~] = riskparity(R_T,  M-1, ssaInput.Results.volTarget, ...
           optiStart, 'vol');
        
    elseif strcmp(ssaInput.Results.weight, 'volParity')
        
        W(position, Ind) = volparity(R_T);
        
    end
    %*********************************************************************
    
    % Case noRule
    if strcmp(ssaInput.Results.tradingRule, 'noRule')
        
        % Signal and weights are already computed so we do nothing.
     
    % Trading rule based on the overall quantity of trend
    elseif strcmp(ssaInput.Results.tradingRule, 'overQuantity')
        
        % Quantity and threshold
        QT = sum(abs(S(position, :)));
        TH = sum(available)*ssaInput.Results.tradingTarget;
        
        % Displaying number of assets over threshold
        if ssaInput.Results.verbose == 1
            if mod(position,20) == 0
                fprintf('The number of asset is %d, the threshold is %.4g and the quantity of trend is %.4g !\n',...
                    sum(available), TH, QT);

            end
        end
        
        % Applying the rule
        if QT <= TH 
            
            if position == 1
                % for the first period, we cannot take the previous signal
                S(position, :) = 1;
            
            else
                % We don't change the signal
                S(position, :) = S(position -1, :);
                
            end
        end
        
        
    else % Individual trend quantity case
        
        % Quantity and threshold
        TH = ssaInput.Results.tradingTarget;
        OUT = abs(S(position, :)) > TH;
        
        if position == 1
            
            S(position, OUT==0) = abs(S(position, OUT==0));
        
        else
            
            S(position, OUT==0) = S(position-1, OUT==0);
            
        end
        
        % Displaying computations
        if ssaInput.Results.verbose == 1
            if mod(position,20) == 0
                fprintf(...
                    'The number of asset is %d, the threshold is %.4g and the number of asset over the threshold are %d !\n',...
                    sum(available), TH, sum(OUT));
            end
        end
        
    end
    
    % Leveraging the allocation
    W_T = W(position, Ind).*S(position, Ind);
    L(position) = ssaInput.Results.volTarget/...
        (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
    
    % Going for the next rebalancing
    position = position + 1;
    
end


end

