%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantitative Asset And Risk Management II
% Trend-Following, Momemtum Crashes and High correlations 
%
% Maxime Borel and Benjamin Souane
% HEC Lausanne 
% 
% Date : 17.12.2020
%==========================================================================

%{

This script execute the entire back-tests for our models. The first section
is about loading and preprocessing the data. The rest of the model
implements each strategy section by section.

More formally, each section calls the necessary functions for the model,
therefore you need to have the entire library loaded up in order for it to
work. 

Each section should be independant from the other however some slight bugs
may still happen if you run only one section (you, anyway, need to run the
first section to load and process the data). As performing the MBBS
sensitivity analysis 1hours the user is requested to input Y/N depending if
you want to run or not.

The model implemented are the following : 

0. Data
1. Momentum
2. Momentum, jumping the nine first month
3. MA 
4. CTA-momentum based on EWMA crossover
5. Singular Sprectrum Analysis - SSA
6. Support Vector Machine - SVM
7. Sensitivity Analysis

Finally, the last sections create some tables and summary plots.

Enjoy!

%}

%% 0. Importing all the libraries in the directory

clc;
clear;
addpath(genpath(pwd));
addpath(genpath('Kevin Sheppard Toolbox'))
clear RESTOREDEFAULTPATH_EXECUTED
MomLength = 252;
ImportData; % this script import all the required data
DataProcessing; % this script adjusts the currency, compute return

%% 1.Momemtum 252 Days

%{
Implementation of the momentum model, we simply compute the return over N
previous days (252) in this case and generate a binary signal accordingly.

It is different than the cross-section momentum since we are generating T
(number of asset) signal that are independant from one another therefore,
we can be entirely short or entirely long. 

We test the signals with our three weighting schemes and compute the
covariance matrix on 180 days for the risk based weighting schemes.

%}
disp('*************************** MOMEMTUM 252 DAYS **************************')
% Vol. Parity
MOM252VP.Momentum = MomLength; % we set the momentum window
MOM252VP.Vola = 180; % day to compute the the covariance matrix
MOM252VP.T = 0.1; % volatility target 10% here 
% the function take different variable argument signal and weight scheme
% here we peform the strategy of momentum with volatility parity. 
[MOM252VP.W, MOM252VP.S, MOM252VP.L] = model1(data.daily, MOM252VP.Momentum,...
    MOM252VP.Vola, MOM252VP.T, 'signal','Binary','weight','VP'); % get the weight the signal and leverage
MOM252VP.NW = MOM252VP.W.*MOM252VP.S; % compute the net weight 
[MOM252VP.R,MOM252VP.CumR,MOM252VP.Stats] = PortfolioStatistics(data.monthly,...
    MOM252VP.NW,MOM252VP.L,0.001); % compute the return of the strategy using previous computation
[MOM252VP.CorrelationAnalysis] = SharpeCorrelation(MOM252VP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum); % correlation analysis and sharpe for different correlation regime
[MOM252VP.FACTOR, MOM252VP.AFACTOR] = factoranalysis(MOM252VP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r); % we perform a factor analysis and for different type of index

% Equal Weighted
MOM252EW.Momentum = MomLength;
MOM252EW.Vola = 180;
MOM252EW.T = 0.1;
[MOM252EW.W, MOM252EW.S, MOM252EW.L] = model1(data.daily, MOM252EW.Momentum,...
    MOM252EW.Vola, MOM252EW.T, 'signal','Binary','weight','EW'); % change the weighting scheme, here equally weighted 
MOM252EW.NW = MOM252EW.W.*MOM252EW.S;
[MOM252EW.R,MOM252EW.CumR,MOM252EW.Stats] = PortfolioStatistics(data.monthly,...
    MOM252EW.NW,MOM252EW.L,0.001);
[MOM252EW.CorrelationAnalysis] = SharpeCorrelation(MOM252EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM252EW.FACTOR, MOM252EW.AFACTOR] = factoranalysis(MOM252EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity
MOM252RP.Momentum = MomLength;
MOM252RP.Vola = 180;
MOM252RP.T = 0.1;
[MOM252RP.W, MOM252RP.S, MOM252RP.L,MOM252RP.MCR] = model1(data.daily, MOM252RP.Momentum,...
    MOM252RP.Vola, MOM252RP.T, 'signal','Binary','weight','RP'); % we change the weighting scheme use risk parity 
MOM252RP.NW = MOM252RP.W.*MOM252RP.S;
[MOM252RP.R,MOM252RP.CumR,MOM252RP.Stats] = PortfolioStatistics(data.monthly,...
    MOM252RP.NW,MOM252RP.L,0.001);
[MOM252RP.CorrelationAnalysis] = SharpeCorrelation(MOM252RP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM252RP.FACTOR, MOM252RP.AFACTOR]  = factoranalysis(MOM252RP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


% Plotting the results
f = figure('visible','on');
plot(data.Mdate, MOM252EW.CumR,data.Mdate,MOM252VP.CumR,data.Mdate,MOM252RP.CumR);
legend('Equal Weighted', 'Volatility Parity','Risk Parity','location',...
    'northwest');
title('252 days momemtum');
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MOM252', '-dpng', '-r1000')
clear f;

%% 2.Momemtum 90 days

%{
Same commentary that before but with 90 days for the covariance matrix
estimation since we are working with 90 days for the momentum.
%}

disp('*************************** MOMEMTUM 90 DAYS **************************\n')
data.monthly = MonthlyReturns(data.daily, 90, 21); % recompute the return, as the signal length is smaller we have more allocation
data.Mdate = Date(data.daily,data.date, 90, 21);

% Vol. Parity
MOM90VP.Momentum = 90; % set the new signal length 
MOM90VP.Vola = 90; % compute the covariance matrix using 60 day 
MOM90VP.T = 0.1; % volatility target 
[MOM90VP.W, MOM90VP.S, MOM90VP.L] = model1(data.daily, MOM90VP.Momentum,...
    MOM90VP.Vola, MOM90VP.T, 'signal','Binary','weight','VP'); %same as before only the return change anf the signal length 
MOM90VP.NW = MOM90VP.W.*MOM90VP.S;
[MOM90VP.R,MOM90VP.CumR,MOM90VP.Stats] = PortfolioStatistics(data.monthly,...
    MOM90VP.NW,MOM90VP.L,0.001);
[MOM90VP.CorrelationAnalysis] = SharpeCorrelation(MOM90VP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM90VP.FACTOR, MOM90VP.AFACTOR] = factoranalysis(MOM90VP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted
MOM90EW.Momentum = 90;
MOM90EW.Vola = 90;
MOM90EW.T = 0.1;
[MOM90EW.W, MOM90EW.S, MOM90EW.L] = model1(data.daily, MOM90EW.Momentum,...
    MOM90EW.Vola, MOM90EW.T, 'signal','Binary','weight','EW'); % change the weigthing scheme
MOM90EW.NW = MOM90EW.W.*MOM90EW.S;
[MOM90EW.R,MOM90EW.CumR,MOM90EW.Stats] = PortfolioStatistics(data.monthly,...
    MOM90EW.NW,MOM90EW.L,0.001);
[MOM90EW.CorrelationAnalysis] = SharpeCorrelation(MOM90EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM90EW.FACTOR, MOM90EW.AFACTOR] = factoranalysis(MOM90EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity
MOM90RP.Momentum = 90;
MOM90RP.Vola = 90;
MOM90RP.T = 0.1;
[MOM90RP.W, MOM90RP.S, MOM90RP.L,MOM90RP.MCR,MOM90RP.CORR] = model1(data.daily, MOM90RP.Momentum,...
    MOM90RP.Vola, MOM90RP.T, 'signal','Binary','weight','RP'); %change the weighting scheme 
MOM90RP.NW = MOM90RP.W.*MOM90RP.S;
[MOM90RP.R,MOM90RP.CumR,MOM90RP.Stats] = PortfolioStatistics(data.monthly,...
    MOM90RP.NW,MOM90RP.L,0.001);
[MOM90RP.CorrelationAnalysis] = SharpeCorrelation(MOM90RP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM90RP.FACTOR, MOM90RP.AFACTOR] = factoranalysis(MOM90RP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate, MOM90EW.CumR,...
    data.Mdate,MOM90VP.CumR,...
    data.Mdate,MOM90RP.CumR);
legend('Equal Weighted', 'Volatility Parity','Risk Parity','location',...
    'northwest')
title('90 days momemtum')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MOM90', '-dpng', '-r1000')
clear f;

%% 2.Momemtum 90 days JUMP

%{

Implementation of the "momentum jump" model. The idea is to compute the
signal with the 9th to 12th previous month. 

We test the strategy for each weighting scheme.

%}

disp('*************************** MOMEMTUM JUMP 90 DAYS **************************\n')

data.monthly = MonthlyReturns(data.daily, MomLength, 21); % recompute the return, here use again 252 but based on the end of the window
data.Mdate = Date(data.daily,data.date ,MomLength, 21);

% Vol. Parity
MOMJUMPVP.Momentum = MomLength; % length required for the signal
MOMJUMPVP.Vola = 180; % use the same length as MOM252 for compute the covariance 
MOMJUMPVP.T = 0.1; % volatility target 
[MOMJUMPVP.W, MOMJUMPVP.S, MOMJUMPVP.L] = model1(data.daily, MOMJUMPVP.Momentum,...
    MOMJUMPVP.Vola, MOMJUMPVP.T, 'signal','MomJump','weight','VP'); % change the signal to use the end of the window to get the signal
MOMJUMPVP.NW = MOMJUMPVP.W.*MOMJUMPVP.S;
[MOMJUMPVP.R,MOMJUMPVP.CumR,MOMJUMPVP.Stats] = PortfolioStatistics(data.monthly,...
    MOMJUMPVP.NW,MOMJUMPVP.L,0.001);
[MOMJUMPVP.CorrelationAnalysis] = SharpeCorrelation(MOMJUMPVP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOMJUMPVP.FACTOR, MOMJUMPVP.AFACTOR] = factoranalysis(MOMJUMPVP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted
MOMJUMPEW.Momentum = MomLength;
MOMJUMPEW.Vola = 180;
MOMJUMPEW.T = 0.1;
[MOMJUMPEW.W, MOMJUMPEW.S, MOMJUMPEW.L] = model1(data.daily, MOMJUMPEW.Momentum,...
    MOMJUMPEW.Vola, MOMJUMPEW.T, 'signal','MomJump','weight','EW'); % change the weighting scheme
MOMJUMPEW.NW = MOMJUMPEW.W.*MOMJUMPEW.S;
[MOMJUMPEW.R,MOMJUMPEW.CumR,MOMJUMPEW.Stats] = PortfolioStatistics(data.monthly,...
    MOMJUMPEW.NW,MOMJUMPEW.L,0.001);
[MOMJUMPEW.CorrelationAnalysis] = SharpeCorrelation(MOMJUMPEW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOMJUMPEW.FACTOR, MOMJUMPEW.AFACTOR] = factoranalysis(MOMJUMPEW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity
MOMJUMPRP.Momentum = MomLength;
MOMJUMPRP.Vola = 180;
MOMJUMPRP.T = 0.1;
[MOMJUMPRP.W, MOMJUMPRP.S, MOMJUMPRP.L,MOMJUMPRP.MCR] = model1(data.daily, MOMJUMPRP.Momentum,...
    MOMJUMPRP.Vola, MOMJUMPRP.T, 'signal','MomJump','weight','RP'); % change the weighting scheme
MOMJUMPRP.NW = MOMJUMPRP.W.*MOMJUMPRP.S;
[MOMJUMPRP.R,MOMJUMPRP.CumR,MOMJUMPRP.Stats] = PortfolioStatistics(data.monthly,...
    MOMJUMPRP.NW,MOMJUMPRP.L,0.001);
[MOMJUMPRP.CorrelationAnalysis] = SharpeCorrelation(MOMJUMPRP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOMJUMPRP.FACTOR, MOMJUMPRP.AFACTOR] = factoranalysis(MOMJUMPRP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate, MOMJUMPEW.CumR,...
    data.Mdate,MOMJUMPVP.CumR,...
    data.Mdate,MOMJUMPRP.CumR);
legend('Equal Weighted', 'Volatility Parity','Risk Parity','location',...
    'northwest')
title('Allocations with Momemtum Jump 9-12 mth')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MOMJUMP', '-dpng', '-r1000')
clear f;

%% 3. Moving Average

%{

Implementation of the simple MA crossover algorithm.

%}

disp('*************************** Moving Average **************************\n')

% Vol. Parity MA
MAVP.Momentum = MomLength;
MAVP.Vola = 90;
MAVP.T = 0.1;
[MAVP.W, MAVP.S, MAVP.L] = model1(data.daily, MAVP.Momentum,...
    MAVP.Vola, MAVP.T, 'signal','MA','weight','VP',...
    21, 63, 'price', data.p); % signal is Moving Average, weighting scheme is vol parity and we use 21d for st MA and 63 LT MA
MAVP.NW = MAVP.W.*MAVP.S; % net weigth 
[MAVP.R,MAVP.CumR,MAVP.Stats] = PortfolioStatistics(data.monthly,...
    MAVP.NW,MAVP.L,0.001);
[MAVP.CorrelationAnalysis] = SharpeCorrelation(MAVP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MAVP.FACTOR, MAVP.AFACTOR] = factoranalysis(MAVP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted MA
MAEW.Momentum = MomLength;
MAEW.Vola = 90;
MAEW.T = 0.1;
[MAEW.W, MAEW.S, MAEW.L] = model1(data.daily, MAEW.Momentum,...
    MAEW.Vola, MAEW.T, 'signal','MA','weight','EW',...
    21, 63, 'price', data.p); % change the weighting scheme 
MAEW.NW = MAEW.W.*MAEW.S;
[MAEW.R,MAEW.CumR,MAEW.Stats] = PortfolioStatistics(data.monthly,...
    MAEW.NW,MAEW.L,0.001);
[MAEW.CorrelationAnalysis] = SharpeCorrelation(MAEW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MAEW.FACTOR, MAEW.AFACTOR] = factoranalysis(MAEW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity MA
MARP.Momentum = MomLength;
MARP.Vola = 90;
MARP.T = 0.1;
[MARP.W, MARP.S, MARP.L,MARP.MCR] = model1(data.daily, MARP.Momentum,...
    MARP.Vola, MARP.T, 'signal','MA','weight','RP',...
    21, 63, 'price', data.p); % change the weighting scheme 
MARP.NW = MARP.W.*MARP.S; %Weights are already Net
[MARP.R,MARP.CumR,MARP.Stats] = PortfolioStatistics(data.monthly,...
    MARP.NW,MARP.L,0.001);
[MARP.CorrelationAnalysis] = SharpeCorrelation(MARP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MARP.FACTOR, MARP.AFACTOR] = factoranalysis(MARP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate, MAEW.CumR,data.Mdate,MAVP.CumR,data.Mdate,MARP.CumR);
legend('Equal Weighted', 'Volatility Parity','Risk Parity','location',...
    'northwest');
title('Allocations with Moving Average signal')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MA', '-dpng', '-r1000')
clear f;

%% Model statistics
%table will all statistics
Model1_stats = [renamevars(MOM252VP.Stats,'Var1','MOM252VP'),...
    renamevars(MOM252RP.Stats,'Var1','MOM252RP'),...
    renamevars(MOM252EW.Stats,'Var1','MOM252EW'),...
    renamevars(MOM90VP.Stats,'Var1','MOM90VP'),...
    renamevars(MOM90RP.Stats,'Var1','MOM90RP'),...
    renamevars(MOM90EW.Stats,'Var1','MOM90EW'),...
    renamevars(MOMJUMPVP.Stats,'Var1','MOMJUMPVP'),...
    renamevars(MOMJUMPRP.Stats,'Var1','MOMJUMPRP'),...
    renamevars(MOMJUMPEW.Stats,'Var1','MOMJUMPEW'),...
    renamevars(MAVP.Stats,'Var1','MAVP'),...
    renamevars(MARP.Stats,'Var1','MARP'),...
    renamevars(MAEW.Stats,'Var1','MAEW')];

%% 4.CTA-momentum based on EWMA crossover

%{
 Implementation of the CTA-Momentum signal based on Baz al.(2015). we backtested several submodels. 
 it uses 3 difference of ST LT EWMA rescaled to get the signal. 
 
  1. Volatility parity with individual trend trading rule (amount of trend
     70% of available assets), forgetting factor of 11
  2. Risk parity with no trading rule, foregeting factor of 11
  3. Signal weighted with individual trading rule (amount of trend
     70% of available assets), forgetting factor of 11
  4. Volatility parity with overall trend trading rule (amount of trend
     70% of available assets), forgetting factor of 11
  5. Risk parity with overall trend trading rule (amount of trend
     70% of available assets), forgetting factor of 11
  6. Risk parity with overall trend trading rule (amount of trend
     70% of available assets), forgetting factor of 11

70% and 11 are parameters that gives relatively good performance,
nevertheless this model is highly sensitive to the parameters, check the
sensitivty analysis. 
%}

fprintf('*************************** MBBS **************************')
% there is better comment in the function modelMBBS
D = 300; % set the length of the exponentiel moving average 
sign = max(D,63); % as the signal require at least 63% of price we have to take the max here 300
data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21); % recompute the return, du to the signal we need 252 EWMA before 
data.Mdate = Date(data.daily,data.date ,MomLength+sign, 21); % compute the signal this is why we start a Momlength +sign 

disp('*************************** MBBS volParity indQuantity **************************')
[MBBSVPNR.W,MBBSVPNR.S,MBBSVPNR.L] = modelMBBS(data.p, data.daily,D, 90,... % we give the price and daily data, the length of EWMA, 
    'tradingRule','indQuantity','tradingTarget',0.7,... % length to compute the cov and set some trading rule we have individualy 
    'weighting','volParity','memory',11); % trend quantity and require 70% of trend, Memory is forgetting factor in the EWMA 
MBBSVPNR.NW = MBBSVPNR.W.*MBBSVPNR.S; % netweigth
[MBBSVPNR.R,MBBSVPNR.CumR,MBBSVPNR.Stats] = PortfolioStatistics(data.monthly,...
    MBBSVPNR.NW,MBBSVPNR.L,0.001);
[MBBSVPNR.CorrelationAnalysis] = SharpeCorrelation(MBBSVPNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSVPNR.FACTOR, MBBSVPNR.AFACTOR] = factoranalysis(MBBSVPNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** MBBS riskParity noRule  **************************')
[MBBSRPNR.W,MBBSRPNR.S,MBBSRPNR.L] =  modelMBBS(data.p, data.daily, D, 90, 'tradingRule',... % do risk parity and no trading rule 
    'noRule','weighting','riskParity','memory',11); 
MBBSRPNR.NW = MBBSRPNR.W.*MBBSRPNR.S;
[MBBSRPNR.R,MBBSRPNR.CumR,MBBSRPNR.Stats] = PortfolioStatistics(data.monthly,...
    MBBSRPNR.NW,MBBSRPNR.L,0.001);
[MBBSRPNR.CorrelationAnalysis] = SharpeCorrelation(MBBSRPNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSRPNR.FACTOR, MBBSRPNR.AFACTOR] = factoranalysis(MBBSRPNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** MBBS Signalweighted indQuant  **************************')
[MBBSEWNR.W,MBBSEWNR.S,MBBSEWNR.L] = modelMBBS(data.p, data.daily, D,90, 'tradingRule','indQuantity',...
    'tradingTarget',0.7,'weighting','EW','memory',11); % individual trend quantity trading rul of 70% weigthing scheme is EW
MBBSEWNR.NW = MBBSEWNR.W.*MBBSEWNR.S;
[MBBSEWNR.R,MBBSEWNR.CumR,MBBSEWNR.Stats] = PortfolioStatistics(data.monthly,...
    MBBSEWNR.NW,MBBSEWNR.L,0.001);
[MBBSEWNR.CorrelationAnalysis] = SharpeCorrelation(MBBSEWNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSEWNR.FACTOR, MBBSEWNR.AFACTOR] = factoranalysis(MBBSEWNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** MBBS volParity, overQuantity **************************')
[MBBSVPOQ.W,MBBSVPOQ.S,MBBSVPOQ.L] = ...
    modelMBBS(data.p, data.daily, D , 90, 'tradingRule', 'overQuantity','tradingTarget',0.7,...
    'memory',11); % vol parity trading rule overall quantity of trend measure on all asset not individually
MBBSVPOQ.NW = MBBSVPOQ.W.*MBBSVPOQ.S;
[MBBSVPOQ.R,MBBSVPOQ.CumR,MBBSVPOQ.Stats] = PortfolioStatistics(data.monthly,...
    MBBSVPOQ.NW,MBBSVPOQ.L,0.001);
[MBBSVPOQ.CorrelationAnalysis] = SharpeCorrelation(MBBSVPOQ.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSVPOQ.FACTOR, MBBSVPOQ.AFACTOR] = factoranalysis(MBBSVPOQ.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** MBBS riskParity overQuanitity **************************')
[MBBSRPOQ.W,MBBSRPOQ.S,MBBSRPOQ.L] =  modelMBBS(data.p, data.daily, D, 90, 'tradingRule',...
    'overQuantity','weighting', 'riskParity','tradingTarget',0.7,'memory',11); % risk parity
MBBSRPOQ.NW = MBBSRPOQ.W.*MBBSRPOQ.S;
[MBBSRPOQ.R,MBBSRPOQ.CumR,MBBSRPOQ.Stats] = PortfolioStatistics(data.monthly,...
    MBBSRPOQ.NW,MBBSRPOQ.L,0.001);
[MBBSRPOQ.CorrelationAnalysis] = SharpeCorrelation(MBBSRPOQ.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSRPOQ.FACTOR, MBBSRPOQ.AFACTOR] = factoranalysis(MBBSRPOQ.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** MBBS Signalweighted overQuantity **************************')
% Improved signal and Trend quantity tracking
[MBBSEWOQ.W,MBBSEWOQ.S,MBBSEWOQ.L] = modelMBBS(data.p, data.daily, D ,90, 'tradingRule',...
    'overQuantity','weighting', 'EW','tradingTarget',0.7,'memory',11); % equaly weigthed 
MBBSEWOQ.NW = MBBSEWOQ.W.*MBBSEWOQ.S;
[MBBSEWOQ.R,MBBSEWOQ.CumR,MBBSEWOQ.Stats] = PortfolioStatistics(data.monthly,...
    MBBSEWOQ.NW,MBBSEWOQ.L,0.001);
[MBBSEWOQ.CorrelationAnalysis] = SharpeCorrelation(MBBSEWOQ.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSEWOQ.FACTOR, MBBSEWOQ.AFACTOR] = factoranalysis(MBBSEWOQ.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate(1:end),MBBSVPNR.CumR,data.Mdate(1:end),MBBSRPNR.CumR...
    ,data.Mdate(1:end), MBBSEWNR.CumR,data.Mdate(1:end),...
    MBBSVPOQ.CumR,data.Mdate(1:end), MBBSRPOQ.CumR,...
    data.Mdate(1:end), MBBSEWOQ.CumR);
legend('VP indQuant','RP noRule','EW indQuant','VP Overall','RP Overall','EW Overall','location',...
    'northwest');
title('MBBS Model')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MBBS', '-dpng', '-r1000')
clear f;

% summary table 
MBBS_stats = [renamevars(MBBSVPNR.Stats,'Var1','Vol.Parity indQuant'),...
    renamevars(MBBSRPNR.Stats,'Var1','R.Parity noRule'),...
    renamevars(MBBSEWNR.Stats,'Var1','EW indQuant'),...
    renamevars(MBBSVPOQ.Stats,'Var1','V.Parity O.quantity'),...
    renamevars(MBBSRPOQ.Stats,'Var1','R.Parity O.Quantity'),...
    renamevars(MBBSEWOQ.Stats,'Var1','EW O.Quantity')];

% correlation regimes table 
MBBS_corrregime = [MBBSVPNR.CorrelationAnalysis.SR(2,:);...
    MBBSVPOQ.CorrelationAnalysis.SR(2,:);... 
    MBBSRPNR.CorrelationAnalysis.SR(2,:);...
    MBBSRPOQ.CorrelationAnalysis.SR(2,:);...
    MBBSEWNR.CorrelationAnalysis.SR(2,:);...
    MBBSEWOQ.CorrelationAnalysis.SR(2,:)];
MBBS_corrregime = array2table(MBBS_corrregime,'VariableNames',{'R0','R0.1','R0.2'},...
    'RowNames',{'MBBSVPIQ','MBBSVPOQ','MBBSRPNR','MBBSRPOQ','MBBSEWIQ','MBBSEWOQ'});
    
%% 5.SSA - Singular Spectrum Analysis 

%{

Implementation of the Singular Spectrum Analysis signal. The signal itself
is the linear trend of the 1st Principal Component of the
"auto-correlation" matrix.

%}

% the function SSA_TF works in the same way as modelMBBS, please check the
% function itself 
SSA.MomLength = 90; % length of the signal 
SSA.LatentDim = 30; % how many past day to condisder 
data.monthly = MonthlyReturns(data.daily,SSA.MomLength, 21); % recompute the return to adjust to the signal length 
data.Mdate = Date(data.daily,data.date ,SSA.MomLength, 21);

% we use Singular spectrum analysis to extract a signal
disp('*************************** SSA - Volatility Parity**************************')
% Improved signal and Trend quantity tracking
[SSA.W,SSA.S,SSA.L] = SSA_TF(data.p, data.daily, SSA.LatentDim,... % vol parity without trading rule, vol target is set a 10%
    SSA.MomLength, 'weight', 'volParity', 'tradingRule', 'noRule', 'volTarget', 0.1); 
SSA.NW = SSA.W.*SSA.S;
[SSA.R,SSA.CumR,SSA.Stats] = PortfolioStatistics(data.monthly,...
    SSA.NW(2:end,:),SSA.L(2:end),0.001);
[SSA.CorrelationAnalysis] = SharpeCorrelation(SSA.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA.FACTOR, SSA.AFACTOR] = factoranalysis(SSA.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Risk Parity **************************')
% Improved signal and Trend quantity tracking
[SSA_RP.W,SSA_RP.S,SSA_RP.L] = SSA_TF(data.p, data.daily, SSA.LatentDim, ... % change the weigthing scheme use risk parity 
    SSA.MomLength, 'weight', 'riskParity', 'tradingRule', 'noRule', 'volTarget', 0.1,...
    'ssaScale', 1);
SSA_RP.NW = SSA_RP.W.*SSA_RP.S;
[SSA_RP.R,SSA_RP.CumR,SSA_RP.Stats] = PortfolioStatistics(data.monthly,...
    SSA_RP.NW(2:end,:),SSA_RP.L(2:end),0.001);
[SSA_RP.CorrelationAnalysis] = SharpeCorrelation(SSA_RP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_RP.FACTOR, SSA_RP.AFACTOR] = factoranalysis(SSA_RP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - EW **************************')
% Improved signal and Trend quantity tracking
[SSA_EW.W,SSA_EW.S,SSA_EW.L] = SSA_TF(data.p, data.daily, SSA.LatentDim, ... % change the weighting scheme use risk parity 
    SSA.MomLength, 'weight', 'EW', 'tradingRule', 'noRule', 'volTarget', 0.1);
SSA_EW.NW = SSA_EW.W.*SSA_EW.S;
[SSA_EW.R,SSA_EW.CumR,SSA_EW.Stats] = PortfolioStatistics(data.monthly,...
    SSA_EW.NW(2:end,:),SSA_EW.L(2:end),0.001);
[SSA_EW.CorrelationAnalysis] = SharpeCorrelation(SSA_EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_EW.FACTOR, SSA_EW.AFACTOR] = factoranalysis(SSA_EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Quantity **************************')
% Improved signal and Trend quantity tracking
[SSA_Quantity.W,SSA_Quantity.S,SSA_Quantity.L] = SSA_TF(data.p, data.daily,... % improve signal with trading rule 
    SSA.LatentDim, SSA.MomLength,... % use trend overall asset, required level of trend is 50%
     'weight', 'riskParity', 'tradingRule', 'overQuantity', 'tradingTarget',... % we use risk parity 
     0.5,'volTarget', 0.1);
SSA_Quantity.NW = SSA_Quantity.W.*SSA_Quantity.S;
[SSA_Quantity.R,SSA_Quantity.CumR,SSA_Quantity.Stats] = PortfolioStatistics(data.monthly,...
    SSA_Quantity.NW(2:end,:),SSA_Quantity.L(2:end),0.001);
[SSA_Quantity.CorrelationAnalysis] = SharpeCorrelation(SSA_Quantity.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_Quantity.FACTOR, SSA_Quantity.AFACTOR] = factoranalysis(SSA_Quantity.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Individual Trend Quantity **************************')
% Improved signal and Trend quantity tracking
[SSA_IndQuantity.W,SSA_IndQuantity.S,SSA_IndQuantity.L] = SSA_TF(data.p, data.daily,...
    SSA.LatentDim, SSA.MomLength,... % here use also risk parity change the trading rule, measure it on asset individually 50% is ask
     'weight', 'riskParity', 'tradingRule', 'indQuantity', 'tradingTarget',...
     0.5,'volTarget', 0.1);
SSA_IndQuantity.NW = SSA_IndQuantity.W.*SSA_IndQuantity.S;
[SSA_IndQuantity.R,SSA_IndQuantity.CumR,SSA_IndQuantity.Stats] = PortfolioStatistics(data.monthly,...
    SSA_IndQuantity.NW(2:end,:),SSA_IndQuantity.L(2:end),0.001);
[SSA_IndQuantity.CorrelationAnalysis] = SharpeCorrelation(SSA_IndQuantity.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_IndQuantity.FACTOR, SSA_IndQuantity.AFACTOR] = factoranalysis(SSA_IndQuantity.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate(end-length(SSA.CumR)+1:end), SSA.CumR,...
    data.Mdate(end-length(SSA.CumR)+1:end), SSA_Quantity.CumR,...
    data.Mdate(end-length(SSA.CumR)+1:end), SSA_IndQuantity.CumR, ...
    data.Mdate(end-length(SSA.CumR)+1:end), SSA_RP.CumR,...
    data.Mdate(end-length(SSA.CumR)+1:end), SSA_EW.CumR);
legend('SSA Volatility Parity','SSA Risk Parity + Overall Trend',...
    'SSA Risk Parity + Individual Trend','SSA Risk Parity'...
    ,'SSA Equal Weighted','location','northwest');
title('SSA signal at constant volatilty')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/SSA', '-dpng', '-r1000')
clear f;

% summary table 
SSA_stats = [renamevars(SSA.Stats,'Var1','Vol.Parity'),...
    renamevars(SSA_RP.Stats,'Var1','R.Parity'),...
    renamevars(SSA_EW.Stats,'Var1','EW'),...
    renamevars(SSA_Quantity.Stats,'Var1','R.Parity O.Quantity'),...
    renamevars(SSA_IndQuantity.Stats,'Var1','R.Parity I.Quantity')];

%% 6.Support vector machine
% for more details see directly in the script

SVM_Model; % Lauching the model, the script set the model, split data into a training set and test set and train the model 
data.monthly = MonthlyReturns(data.daily,SVM_MODEL.day+121, 21); % recompute the return to adjuste to the signal length  train set
data.Mdate = Date(data.daily,data.date ,SVM_MODEL.day+121, 21); % the 121 come from the SVM_Model script 

disp('*************************** SVM - Volatility Parity NoRule **************************')
% Volatility Parity
[SVM_MODELNR.W, SVM_MODELNR.S, SVM_MODELNR.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0,'VolParity');
SVM_MODELNR.NW = SVM_MODELNR.W.*SVM_MODELNR.S; % take the model as impute, vol parity, use 90 days to compute the signal. 
[SVM_MODELNR.R, SVM_MODELNR.CumR, SVM_MODELNR.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODELNR.S)+1:end,:),...
    SVM_MODELNR.NW,SVM_MODELNR.L,0.001);
[SVM_MODELNR.FACTOR, SVM_MODELNR.AFACTOR] = factoranalysis(SVM_MODELNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODELNR.CorrelationAnalysis] = SharpeCorrelation(SVM_MODELNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

disp('*************************** SVM - Risk Parity Norule **************************')

% Risk Parity
[SVM_MODEL_RiskNR.W, SVM_MODEL_RiskNR.S, SVM_MODEL_RiskNR.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0,'RiskParity');
SVM_MODEL_RiskNR.NW = SVM_MODEL_RiskNR.W.*SVM_MODEL_RiskNR.S; % we use risk parity 
[SVM_MODEL_RiskNR.R, SVM_MODEL_RiskNR.CumR, SVM_MODEL_RiskNR.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_RiskNR.S)+1:end,:),...
    SVM_MODEL_RiskNR.NW,SVM_MODEL_RiskNR.L,0.001);
[SVM_MODEL_RiskNR.FACTOR, SVM_MODEL_RiskNR.AFACTOR] = factoranalysis(SVM_MODEL_RiskNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_RiskNR.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_RiskNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

disp('*************************** SVM - EW NoRule **************************')
% Equally Weighted
[SVM_MODEL_EWNR.W, SVM_MODEL_EWNR.S, SVM_MODEL_EWNR.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0,'EW'); % EW scheme
SVM_MODEL_EWNR.NW = SVM_MODEL_EWNR.W.*SVM_MODEL_EWNR.S;
[SVM_MODEL_EWNR.R, SVM_MODEL_EWNR.CumR, SVM_MODEL_EWNR.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_EWNR.S)+1:end,:),...
    SVM_MODEL_EWNR.NW,SVM_MODEL_EWNR.L,0.001);
[SVM_MODEL_EWNR.FACTOR, SVM_MODEL_EWNR.AFACTOR] = factoranalysis(SVM_MODEL_EWNR.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_EWNR.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_EWNR.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

disp('*************************** SVM - Volatility Parity with trading rule **************************')
% Volatility Parity
[SVM_MODEL.W, SVM_MODEL.S, SVM_MODEL.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'VolParity');
SVM_MODEL.NW = SVM_MODEL.W.*SVM_MODEL.S; % take the model as impute, vol parity, use 90 days to compute the signal. 
[SVM_MODEL.R, SVM_MODEL.CumR, SVM_MODEL.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL.S)+1:end,:),...
    SVM_MODEL.NW,SVM_MODEL.L,0.001);
[SVM_MODEL.FACTOR, SVM_MODEL.AFACTOR] = factoranalysis(SVM_MODEL.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

disp('*************************** SVM - Risk Parity with trading rule **************************')

% Risk Parity
[SVM_MODEL_Risk.W, SVM_MODEL_Risk.S, SVM_MODEL_Risk.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'RiskParity');
SVM_MODEL_Risk.NW = SVM_MODEL_Risk.W.*SVM_MODEL_Risk.S; % we use risk parity 
[SVM_MODEL_Risk.R, SVM_MODEL_Risk.CumR, SVM_MODEL_Risk.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_Risk.S)+1:end,:),...
    SVM_MODEL_Risk.NW,SVM_MODEL_Risk.L,0.001);
[SVM_MODEL_Risk.FACTOR, SVM_MODEL_Risk.AFACTOR] = factoranalysis(SVM_MODEL_Risk.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_Risk.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_Risk.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

disp('*************************** SVM - EW with trading rule **************************')
% Equally Weighted
[SVM_MODEL_EW.W, SVM_MODEL_EW.S, SVM_MODEL_EW.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'EW'); % EW scheme
SVM_MODEL_EW.NW = SVM_MODEL_EW.W.*SVM_MODEL_EW.S;
[SVM_MODEL_EW.R, SVM_MODEL_EW.CumR, SVM_MODEL_EW.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_EW.S)+1:end,:),...
    SVM_MODEL_EW.NW,SVM_MODEL_EW.L,0.001);
[SVM_MODEL_EW.FACTOR, SVM_MODEL_EW.AFACTOR] = factoranalysis(SVM_MODEL_EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_EW.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);


f = figure('visible','on');
plot(data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL.CumR, ...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_Risk.CumR,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_EW.CumR,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODELNR.CumR,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_RiskNR.CumR,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_EWNR.CumR)
title('Support vector machine Model')
ylabel('Cumulative return')
xlabel('date')
legend('Volatility Parity TR','Risk Parity TR','Equally Weighted TR',...
    'Volatility Parity NR','Risk Parity NR','Equally Weighted NR'...
    ,'location','northwest')
print(f,'Output/SVM', '-dpng', '-r1000')
clear f;

SVM_stats = [renamevars(SVM_MODEL.Stats,'Var1','Vol.Parity'),...
    renamevars(SVM_MODEL_Risk.Stats,'Var1','R.Parity'),...
    renamevars(SVM_MODEL_EW.Stats,'Var1','EW'),...
    renamevars(SVM_MODELNR.Stats,'Var1','Vol.Parity NR'),...
    renamevars(SVM_MODEL_RiskNR.Stats,'Var1','R.Parity NR'),...
    renamevars(SVM_MODEL_EWNR.Stats,'Var1','EW NR')];
%% 7.Sensitivity Analysis & Return decomposition 

    % Return Decomposition
    data.monthly = MonthlyReturns(data.daily, 1, 21);
    data.Mdate = Date(data.daily,data.date ,1, 21); % compute the signal this is why we start a Momlength +sign 
    returnDec; % compute the decomposition of the return for every model, every asset classes 

    prompt = 'Do you want to perform the Sensitivity analysis for the MBBS model ? Y/N : ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'Y';
    end
    if strcmp(str,'Y') == 1
    % Sensitivity MBBS
        MBBS__Sensitivity;
    end 
    % Sensitivity SSA
    SSA_Sensitivity;

    % Sensitivity SVM
    SVM_Sensitivity;

%% 8.Creating tables, plots and clearing variables

% Creating tables
creatingtables;


% Compute signals plot
plotSIGNAL(SSA_RP.S, data.classNum,...
    data.Mdate,'Output/SSA_RP_SignalDecomposition',...
    'SSA signal decomposition', ...
    data.class)

plotSIGNAL(SVM_MODEL_Risk.S, data.classNum,...
    data.Mdate,'Output/SVM_S',...
    'SVM Signal Decomposition', ...
    data.class)

plotSIGNAL(MOM252VP.S,data.classNum,...
    data.Mdate(9:end),'Output/MOM252_s',...
    'MOM252 Signal Decomposition', ...
    data.class) 

plotSIGNAL(MBBSRPOQ.S,data.classNum,...
    data.Mdate(9:end),'Output/MBBSRPOQSignal',...
    'MBBSEPOQ Signal Decomposition', ...
    data.class) 

% Correlation and Model
f = figure();
scatter(SVM_MODEL_Risk.CorrelationAnalysis.C_Inter, SVM_MODEL_Risk.CorrelationAnalysis.S,'filled')
hold on
scatter(SSA_RP.CorrelationAnalysis.C_Inter, SSA_RP.CorrelationAnalysis.S,'filled')
hold on
scatter(MBBSRPOQ.CorrelationAnalysis.C_Inter, MBBSRPOQ.CorrelationAnalysis.S,'filled')
lsline
xlabel('Correlation between asset class')
ylabel('Sharpe Ratio')
xlim([0.09 0.7])
ylim([min(SVM_MODEL_Risk.CorrelationAnalysis.S),max(SVM_MODEL_Risk.CorrelationAnalysis.S)])
legend('Support Vector Machine', 'Singular Sprectrum Analysis', 'MBBSRPOQ', 'location', 'southoutside', 'orientation', 'horizontal')
title('Sharpe Ratio and Correlation Regime')
print(f,'Output/CorrSharpeRP', '-dpng', '-r1000')


% Comparative graph
% begin strategy at the same time 
T = length(SVM_MODEL_Risk.R); 
MOM252RP.Scale = 100.*cumprod(1 + MOM252RP.R(end-T+1:end)); % MOM252 
MBBSRPOQ.Scale = 100.*cumprod(1 + MBBSRPOQ.R(end-T+1:end));% MBBS
SSA_IndQuantity.Scale = 100.*cumprod(1 + SSA_IndQuantity.R(end-T+1:end)); % SSA

f = figure('visible', 'on');
plot(data.Mdate(end-length(SVM_MODEL.CumR):end-1), MOM252RP.Scale,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1), MBBSRPOQ.Scale,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1), SSA_IndQuantity.Scale,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1), SVM_MODEL_Risk.CumR)
xlabel('Date')
ylabel('Cumulative return')
title('Comparison of the strategies')
legend('MOM252','MBBSRPOQ','SSA RP indQuant','SVM RP OQ','location','southoutside','orientation','horizontal')
print(f,'Output/comparativegraph', '-dpng', '-r1000')

% Clear Temporary Variables
clear height i asset A N position TF D LD m minMax Num P pos pos_2 PP RS s SCALE sign y0  width f
