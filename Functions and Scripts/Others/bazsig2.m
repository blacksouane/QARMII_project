function [S] = bazsig2(P, D, varargin)
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
U = 8;
% Memory Parameters
defaultMemory = [U, U*2, U*4 ; U*3, U*6, U*12];
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
checkMix = @(x) assert(length(x) == 3 && sum(x) == 1,errorMsgMix);

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
addParameter(baz, 'PW', defaultPW);
addParameter(baz, 'SW', defaultSW);

% Parse the inputs
parse(baz, P, D, varargin{:});

%% Input Extracting and parameters

%Extract size of price matrix
[~, A] = size(P);


%% Computing the signal

% 1. Transform value into decay factors
DF = (baz.Results.memory - 1)./baz.Results.memory;
maxLB = max(baz.Results.PW,D);

% compute the EWMA
for a=1:A
    MA = mean(P(maxLB-D+1:maxLB-1,a),1);
    EWMA1(1,1) = P(maxLB,a)*DF(1,1)+(1-DF(1,1))*MA;
    EWMA2(1,1) = P(maxLB,a)*DF(2,1)+(1-DF(2,1))*MA;
    
    EWMA1(1,2) = P(maxLB,a)*DF(1,2)+(1-DF(1,1))*MA;
    EWMA2(1,2) = P(maxLB,a)*DF(2,2)+(1-DF(2,2))*MA;
    
    EWMA1(1,3) = P(maxLB,a)*DF(1,3)+(1-DF(1,3))*MA;
    EWMA2(1,3) = P(maxLB,a)*DF(2,3)+(1-DF(2,3))*MA;
    N=length(P);
    
    position = 2;
    for k=1:3
        for i=maxLB+1:N
            EWMA1(position,k) = P(i,a)*DF(1,k)+(1-DF(1,k))*EWMA1(position-1,k);
            EWMA2(position,k) = P(i,a)*DF(2,k)+(1-DF(2,k))*EWMA2(position-1,k);
            position = position + 1;
        end
        position = 2;
    end
    
    x = EWMA2-EWMA1;
    y=zeros(size(x));
    position = 1;
    for i=maxLB:N
        y(position,:) = x(position,:)./std(P(i-baz.Results.PW+1:i));
        position = position + 1;
    end
    
    position = 1;
    u = zeros(length(baz.Results.SW:length(y)),3);
    for j=1:3
        for i =baz.Results.SW:length(y)
            u(position,:) = y(i,j)./std(y(i-baz.Results.SW+1:i,j));
            position = position + 1;
        end
        position = 1;
    end
    c = (u.*exp(-(u.^2)./baz.Results.responseExp))./baz.Results.responseScale;
    
    S(:,a)=mean(c,2);
end



end

