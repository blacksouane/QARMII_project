function [MODEL] = performance(W, S, L, R, C, factor, rf, indices, varargin)
%{
This function compute the performance of the an allocation using three
angles :

1. Portoflio Statistics (mandatory)

2. Performance regarding correlation (optional)

3. Performance regarding factors and indicatord (optional)

The model needs 4 mandatory inputs : 

INPUT: 
        W: Gross Weights of the strategy (NumAsset X Periods)
        S: A signal (binary or continuous)
            If you want to use the function outside of a trend-following
            framework, just une a signal composed of 1. (NumAsset X
            Periods)
        L: A leverage (1XNumPeriods) to attain a constant volatility. Here
        again, if you don't need it, just use ones. 
        
        R: A matrix of assets returns (NumAsset X NumPeriods)


All the other input are passed in varargin through name/pair arguments,
they launch the optional part of the analysis if the input are in.

VARARGIN : 

    'fees', a scalar in basis point. There is no default value, otherwise fees are not computed.  
    'window', a scalar which represent the length of the window to compute
    sharpe ratio and correlation. Default is 36 (monthly values). 
    'regime', an array of three correlation level to compute performance
    relative to regimes. Default = [0, 0.1, 0.2].
    'factor', data of factor. 
    'rf', data of risk free rates
    'indices', leading indices to compute correlations. 
%}


%% Input Parsing

% Create Parser Object
perfInput = inputParser;

% fees Parameters
defaultFees = 0.001;
checkFees = @(x) isnumeric(x);

% windowParameters
defaultWindow = 36;
checkWindow = @(x) isnumeric(x); 

% regimeParameters
defaultRegime = [0, 0.1, 0.2]; 

% Create Parsing Structure
addRequired(perfInput, 'W');
addRequired(perfInput, 'S');
addRequired(perfInput, 'L'); 
addRequired(perfInput, 'R');
addRequired(perfInput, 'C');
addRequired(perfInput, 'factor');
addRequired(perfInput, 'indices');
addRequired(perfInput, 'rf'); 
addParameter(perfInput, 'fees', defaultFees, checkFees);
addParameter(perfInput, 'window', defaultWindow, checkWindow);
addParameter(perfInput, 'regime', defaultRegime);

% Parse the input
parse(perfInput, W, S, L, R, factor, indices, rf,varargin{:})

%% Parameters 

% Add input into structure
MODEL.W = W; 
MODEL.S = S; 
MODEL.L = L; 
MODEL.LN = length(MODEL.L);
MODEL.LD = length(R); 

% Compute NetWeights
MODEL.NW = MODEL.W.*MODEL.S;

%% Computing portfolio statistics

% Handle date mismatch
if LN > LD 
    
    PortNW = MODEL.NW(end-LD+1:end, :);
    PortL = MODEL.L(end-LD+1:end, :);
    PortR = R; 
    
elseif LD > LN
    
    PortNW = MODEL.NW;
    PortL = MODEL.L;
    PortR = R(end-LN+1:end,:); 
    
else
 
    PortNW = MODEL.NW;
    PortL = MODEL.L;
    PortR = R;
    
end

% Compute performance
if isempty(perfInput.Results.fees)
    [MODEL.R, MODEL.CumR, MODEL.Stats] = PortfolioStatistics(PortR, PortNW, ...
    PortL);
else
    [MODEL.R, MODEL.CumR, MODEL.Stats] = PortfolioStatistics(PortR, PortNW, ...
    PortL, perfInput.Results.fees);
end

%% Correlation study

MODEL.CorrelationAnalysis = SharpeCorrelation(MODEL.R, R, ...
        perfInput.Results.window, perfInput.Results.regime, ...
        C);

%% Factor 

if isempty(perfInput.Results.factor)
    disp('We are not performing factor analysis')
    
else
    [MODEL.FACTOR, MODEL.AFACTOR] = factoranalysis(MODEL.R,...
        perfInput.Results.factor, perfInput.Results.rf, perfInput.Results.indices);
end

