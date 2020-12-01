function [S] = ewmaCO(P, D, varargin)
%{
Implementation of the EWMA crossover from Baz & al. 2015

It generates a continuous signal in [-1 , 1]
**************************************************************************
INPUT :
**************************************************************************
There are 2 mandatory input

    1. P : Matrix of price of size TXN
    2. D : Length of EWMA lookback
    
All the other input are passed as name/pair argument in varargin

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


Therefore, you need priceWindow + max{shortWindow, D} + 1 data to be able to
generate a signal and use it. 

**************************************************************************
OUTPUT :
**************************************************************************

S : A signal of size 1XT

You can use it to generate a higher number of signal directly but the best
method is to loop outside of the function to compute both the signal and
the weights at the same time for each rebalancing.
%}


%% Input Parsing

% Generate Parser object
baz = inputParser;

% Memory Parameters
defaultMemory = [8, 16, 32 ; 24, 48, 96];
errorMsgMemory = 'Size of decay values must be 2 by 3!';
checkMemory = @(x) assert(size(x) == [2 3],errorMsgMemory);

% Response scale parameters
defaultScale = 0.89;
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


%Create Parsing structure
addRequired(baz, 'P');
addRequired(baz, 'D');
addParameter(baz, 'memory', defaultMemory, checkMemory)
addParameter(baz, 'responseScale', defaultScale, checkScale);
addParameter(baz, 'responseExp', defaultExp, checkExp);
addParameter(baz, 'mix', defaultMix, checkMix);
addParameter(baz, 'priceWindow', defaultPW);
addParameter(baz, 'shortWindow', defaultSW);

% Parse the inputs
parse(baz, P, D, varargin{:});

%% Input Extracting and parameters

%Extract size of price matrix
[T, A] = size(P);


%% Computing the signal

% 1. Transform value into decay factors
DF = (baz.Results.memory - 1)./baz.Results.memory;

% 2. Compute EWMA
delta = zeros(PW,3,A);
pos = 1;
for L = 1:3
    
    % Create movAvg object
    movAvg_1 = dsp.MovingAverage('Method','Exponential weighting',...
    'ForgettingFactor',DF(1, L));
    movAvg_2 = dsp.MovingAverage('Method','Exponential weighting',...
    'ForgettingFactor',DF(2, L));

    for lookback = baz.Results.SW+D:baz.Results.PW + baz.Results.SW + D
        
        % Vector of EWMA
        temp_1 = movAvg_1(P(lookback-D:lookback));
        temp_2 = movAvg_2(P(lookback-D:lookback));
        
        % Compute delta over the last value
        delta(pos, L, :) = temp_1(end, :) - temp_2(end, :);
         
         pos = pos + 1; 
    end
    
   pos = 1;
end

% Rescale by price
x = delta;
for 
end

