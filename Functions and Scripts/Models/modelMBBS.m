function [W, S, L] = modelMBBS(P,R,D1,D2,n,varargin)
%{
Implementation of the strategy with a signal from baz & al. 2015.

The signal is a CTA-Momentum based on the crossover of EWMA. This function
goes with a function ewmaCO which computes the signal and some function
for the weighting schemes.

**************************************************************************
INPUT

There is three mandatory input which are the prices and the returns of the
assets.

P : Price Series of size N+1XT
R : Return Series of size NXT

All the other inputs are passed as name/pair arguments:

    1. 'memory' : an array of size 2X3 representing 3 pair of short/long
    term EWMA, they are translated into lambda decay factors N/N-1
    Default : [8, 16, 32 ; 24, 48, 96]
    
    2. 'responseScale' : the signal is passed into a response function
    which is scaled by a number in [0, 1].
    Default : 0.89

    3. 'responseExp' : signal is multiplied by exp(-X^2 / responseExp).
    Default : 4

    4. 'mix' : Final signal is a weighted average of the 3 pairs. You can
    choose the mix with an array of size 1X3.
    Default: [1/3, 1/3, 1/3]

    5. 'priceWindow' : Signal is scaled by the realized volatility over the
    price window.
    Default: 63


    6. 'shortWindow' : Signal is scaled by its realized volatility.
    Default: 252


    7. 'weighting' : a string in representing the weighting scheme.
    Accepted value are : {'volParity' (default), 'riskParity', 'EW'}.


    8. 'tradingRule', a trading rule based on the quantity of trend between:
                    1. 'noRule'
                    2. 'overQuantity' , we do not change our position if
                    the overall quantity of trend is smaller than a
                    threshold (next name/pair argument).
                    3. 'indQuantity', we apply the same rule but on each
                    asset.
                    Default is 'noRule'.

    9. 'tradingTarget', a numeric value in [0, 1] which is the threshold for
    the 'tradingRule'. Default is 0.5.

    10. 'volTarget', a numeric value allowing for a constant running
    volatility. Default is 0.1.

*************************************************************************
OUTPUT

     W : Weights of the allocation
     S : Signals
     L : Leverage to attain volatility target

%}
%% Input Parsing

% Generate Parser object
baz = inputParser;

% Memory Parameters
defaultMemory = [8, 16, 32 ; 24, 48, 96];
errorMsgMemory = 'Size of decay values must be 2 by 3!';
checkMemory = @(x) assert(size(x) == [2 3],errorMsgMemory);

% Response scale parameters
defaultScale = 0.95;
checkScale = @(x) x > 0 && x <= 1 && isnumeric(x);

% Response exp Parameters
defaultExp = 4;
checkExp = @(x) isnumeric(x);

% Mix Parameters
defaultMix = [1/3, 1/3, 1/3];
errorMsgMix = 'Size of mix array must be 1X3 and it must sum to 1!';
checkMix = @(x) assert(size(x) == [1 3] && sum(x) == 1,errorMsgMix);

% Price Window Parameters
defaultPW = 63;

% Short window parameters
defaultSW = 252;

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

%Create Parsing structure
addRequired(baz, 'P');
addRequired(baz, 'R');
addRequired(baz, 'D1');
addRequired(baz, 'D2');
addRequired(baz, 'n');
addParameter(baz, 'memory', defaultMemory, checkMemory)
addParameter(baz, 'responseScale', defaultScale, checkScale);
addParameter(baz, 'responseExp', defaultExp, checkExp);
addParameter(baz, 'mix', defaultMix, checkMix);
addParameter(baz, 'PW', defaultPW);
addParameter(baz, 'SW', defaultSW);
addParameter(baz, 'weighting', defaultWeighting, checkWeighting);
addParameter(baz, 'tradingRule', defaultTrading, checkTrading);
addParameter(baz, 'tradingTarget', defaultTradingLevel, checkTradingLevel);
addParameter(baz, 'volTarget', defaultVolTarget, checkVolTarget);

% Parse the inputs
parse(baz, P, R, D1,D2, n, varargin{:});

%% Parameters and Input

% Check size of P and R
if length(P) - 1 == length(R)
    P = P(2:end, :);
    disp('Corrected price length');
elseif length(P) == length(R)
    disp('Input length are ok');
else
    disp('Input length are not coherent')
    return
end

% Check for default name/pair arguments and display it/them
if ~isempty(baz.UsingDefaults)
    disp('Using defaults: ')
    disp(baz.UsingDefaults)
end

% Size of the dataset
[T, A] = size(R);

% Find first available data
f = zeros(1,A);
for i = 1:A
    f(i) = find (~ isnan(R(:,i)), 1);
end

% Define number of need value to start computing the signal
M = baz.Results.SW + max(D2, baz.Results.PW); 

% Preallocating the memory
W = zeros(round((T - M)/21, 0), A);
L = ones(round((T - M)/21, 0), 1);
S = zeros(round((T - M)/21, 0), A);
posIdx = 1;

disp('Starting the backtest !')
%% Performing the allocation

for time = M+1:21:T
    
    %Displaying position of the allocation
    if mod(posIdx, 20) == 0
        fprintf('Allocation %d over %d has been performed !\n',posIdx, round((T- M + 1)/21));
    end
    
    % Find index of available assets at time "time"
    iDx = find(f <= time - M);
    
    % Define returns and prices to compute weights and signals
    R_T = R(time-n+1:time,iDx);
    P_T = P(time-M+1:time,iDx);
    
    %**********************************************************************
    % Handle Weighting Scheme
    if strcmp(baz.Results.weighting, 'EW')
        
        W(posIdx,iDx) = 1/sum(f <= time - M);
        
    elseif strcmp(baz.Results.weighting, 'riskParity')
        
        optiStart = volparity(R_T);
        [W(posIdx, iDx), ~] = riskparity(R_T,  n-1, baz.Results.volTarget, ...
            optiStart, 'vol');
        
    elseif strcmp(baz.Results.weighting, 'volParity')
        
        W(posIdx, iDx) = volparity(R_T);
        
    end
    
    %*********************************************************************
    % Handling Signal
    S(posIdx, iDx) = ewmaCO(P_T,D2);
    
    
    %*********************************************************************
    % Handling trading rule
    if strcmp(baz.Results.tradingRule, 'overQuantity')
        % Quantity and threshold
        QT = sum(abs(S(posIdx, :)));
        TH = sum(f <= time - M)*baz.Results.tradingTarget;
        % Applying the rule
        if QT <= TH
            if posIdx == 1
                % for the first period, we cannot take the previous signal
                S(posIdx, :) = 1;
            else
                % We don't change the signal
                S(posIdx, :) = S(posIdx -1, :);
            end
        end
    elseif strcmp(baz.Results.tradingRule, 'indQuantity')
        % Quantity and threshold
        TH = baz.Results.tradingTarget;
        OUT = abs(S(posIdx, :)) > TH;
        if posIdx == 1
            S(posIdx, OUT==0) = abs(S(posIdx, OUT==0));
        else
            S(posIdx, OUT==0) = S(posIdx-1, OUT==0);
        end
    end
    %*********************************************************************
    % Handling Constant Vol.
    W_T = W(posIdx, iDx).*S(posIdx, iDx);
    L(posIdx) = baz.Results.volTarget/...
        (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
    
    % Next
    posIdx = posIdx + 1;
end
end