%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantitative Asset And Risk Management II
% Trend-Following, Momemtum Crashes and High correlations 
%
% Maxime Borel and Benjamin Souane
% HEC Lausanne 
% 
%==========================================================================

%Importing all the libraries in the directory
clc;
clear;
addpath(genpath(pwd));
addpath(genpath('Kevin Sheppard Toolbox'))
clear RESTOREDEFAULTPATH_EXECUTED
MomLength = 252;
ImportData;
DataProcessing;

disp('####################################################################');
disp('-------------------------- Model 1 ---------------------------------');
disp('####################################################################');
%% Momemtum 252 Days

disp('*************************** MOMEMTUM 252 DAYS **************************')
% Vol. Parity
MOM252VP.Momentum = MomLength;
MOM252VP.Vola = 180;
MOM252VP.T = 0.1;
[MOM252VP.W, MOM252VP.S, MOM252VP.L] = model1(data.daily, MOM252VP.Momentum,...
    MOM252VP.Vola, MOM252VP.T, 'signal','Binary','weight','VP');
MOM252VP.NW = MOM252VP.W.*MOM252VP.S;
[MOM252VP.R,MOM252VP.CumR,MOM252VP.Stats] = PortfolioStatistics(data.monthly,...
    MOM252VP.NW,MOM252VP.L,0.001);
[MOM252VP.CorrelationAnalysis] = SharpeCorrelation(MOM252VP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM252VP.FACTOR, MOM252VP.AFACTOR] = factoranalysis(MOM252VP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted
MOM252EW.Momentum = MomLength;
MOM252EW.Vola = 180;
MOM252EW.T = 0.1;
[MOM252EW.W, MOM252EW.S, MOM252EW.L] = model1(data.daily, MOM252EW.Momentum,...
    MOM252EW.Vola, MOM252EW.T, 'signal','Binary','weight','EW');
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
    MOM252RP.Vola, MOM252RP.T, 'signal','Binary','weight','RP');
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
print(f,'Output/MOM252', '-dpng', '-r1000')
ylabel('Cumulative return')
xlabel('date')
clear f;

%% Momemtum 90 days

disp('*************************** MOMEMTUM 90 DAYS **************************\n')
data.monthly = MonthlyReturns(data.daily, 90, 21);
data.Mdate = Date(data.daily,data.date, 90, 21);

% Vol. Parity
MOM90VP.Momentum = 90;
MOM90VP.Vola = 60;
MOM90VP.T = 0.1;
[MOM90VP.W, MOM90VP.S, MOM90VP.L] = model1(data.daily, MOM90VP.Momentum,...
    MOM90VP.Vola, MOM90VP.T, 'signal','Binary','weight','VP');
MOM90VP.NW = MOM90VP.W.*MOM90VP.S;
[MOM90VP.R,MOM90VP.CumR,MOM90VP.Stats] = PortfolioStatistics(data.monthly,...
    MOM90VP.NW,MOM90VP.L,0.001);
[MOM90VP.CorrelationAnalysis] = SharpeCorrelation(MOM90VP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM90VP.FACTOR, MOM90VP.AFACTOR] = factoranalysis(MOM90VP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted
MOM90EW.Momentum = 90;
MOM90EW.Vola = 60;
MOM90EW.T = 0.1;
[MOM90EW.W, MOM90EW.S, MOM90EW.L] = model1(data.daily, MOM90EW.Momentum,...
    MOM90EW.Vola, MOM90EW.T, 'signal','Binary','weight','EW');
MOM90EW.NW = MOM90EW.W.*MOM90EW.S;
[MOM90EW.R,MOM90EW.CumR,MOM90EW.Stats] = PortfolioStatistics(data.monthly,...
    MOM90EW.NW,MOM90EW.L,0.001);
[MOM90EW.CorrelationAnalysis] = SharpeCorrelation(MOM90EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOM90EW.FACTOR, MOM90EW.AFACTOR] = factoranalysis(MOM90EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity
MOM90RP.Momentum = 90;
MOM90RP.Vola = 60;
MOM90RP.T = 0.1;
[MOM90RP.W, MOM90RP.S, MOM90RP.L,MOM90RP.MCR,MOM90RP.CORR] = model1(data.daily, MOM90RP.Momentum,...
    MOM90RP.Vola, MOM90RP.T, 'signal','Binary','weight','RP');
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

%% Momemtum 90 days JUMP

disp('*************************** MOMEMTUM JUMP 90 DAYS **************************\n')

data.monthly = MonthlyReturns(data.daily, MomLength, 21);
data.Mdate = Date(data.daily,data.date ,MomLength, 21);

% Vol. Parity
MOMJUMPVP.Momentum = MomLength;
MOMJUMPVP.Vola = 90;
MOMJUMPVP.T = 0.15;
[MOMJUMPVP.W, MOMJUMPVP.S, MOMJUMPVP.L] = model1(data.daily, MOMJUMPVP.Momentum,...
    MOMJUMPVP.Vola, MOMJUMPVP.T, 'signal','MomJump','weight','VP');
MOMJUMPVP.NW = MOMJUMPVP.W.*MOMJUMPVP.S;
[MOMJUMPVP.R,MOMJUMPVP.CumR,MOMJUMPVP.Stats] = PortfolioStatistics(data.monthly,...
    MOMJUMPVP.NW,MOMJUMPVP.L,0.001);
[MOMJUMPVP.CorrelationAnalysis] = SharpeCorrelation(MOMJUMPVP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOMJUMPVP.FACTOR, MOMJUMPVP.AFACTOR] = factoranalysis(MOMJUMPVP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted
MOMJUMPEW.Momentum = MomLength;
MOMJUMPEW.Vola = 90;
MOMJUMPEW.T = 0.15;
[MOMJUMPEW.W, MOMJUMPEW.S, MOMJUMPEW.L] = model1(data.daily, MOMJUMPEW.Momentum,...
    MOMJUMPEW.Vola, MOMJUMPEW.T, 'signal','MomJump','weight','EW');
MOMJUMPEW.NW = MOMJUMPEW.W.*MOMJUMPEW.S;
[MOMJUMPEW.R,MOMJUMPEW.CumR,MOMJUMPEW.Stats] = PortfolioStatistics(data.monthly,...
    MOMJUMPEW.NW,MOMJUMPEW.L,0.001);
[MOMJUMPEW.CorrelationAnalysis] = SharpeCorrelation(MOMJUMPEW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MOMJUMPEW.FACTOR, MOMJUMPEW.AFACTOR] = factoranalysis(MOMJUMPEW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Risk. Parity
MOMJUMPRP.Momentum = MomLength;
MOMJUMPRP.Vola = 90;
MOMJUMPRP.T = 0.15;
[MOMJUMPRP.W, MOMJUMPRP.S, MOMJUMPRP.L,MOMJUMPRP.MCR] = model1(data.daily, MOMJUMPRP.Momentum,...
    MOMJUMPRP.Vola, MOMJUMPRP.T, 'signal','MomJump','weight','RP');
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

%% Moving Average
disp('*************************** Moving Average **************************\n')

% Vol. Parity MA
MAVP.Momentum = MomLength;
MAVP.Vola = 90;
MAVP.T = 0.15;
[MAVP.W, MAVP.S, MAVP.L] = model1(data.daily, MAVP.Momentum,...
    MAVP.Vola, MAVP.T, 'signal','MA','weight','VP',...
    21, 63, 'price', data.p);
MAVP.NW = MAVP.W.*MAVP.S;
[MAVP.R,MAVP.CumR,MAVP.Stats] = PortfolioStatistics(data.monthly,...
    MAVP.NW,MAVP.L,0.001);
[MAVP.CorrelationAnalysis] = SharpeCorrelation(MAVP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MAVP.FACTOR, MAVP.AFACTOR] = factoranalysis(MAVP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Equal Weighted MA
MAEW.Momentum = MomLength;
MAEW.Vola = 90;
MAEW.T = 0.15;
[MAEW.W, MAEW.S, MAEW.L] = model1(data.daily, MAEW.Momentum,...
    MAEW.Vola, MAEW.T, 'signal','MA','weight','EW',...
    21, 63, 'price', data.p);
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
MARP.T = 0.15;
[MARP.W, MARP.S, MARP.L,MARP.MCR] = model1(data.daily, MARP.Momentum,...
    MARP.Vola, MARP.T, 'signal','MA','weight','RP',...
    21, 63, 'price', data.p);
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


%All Signal with VP

%% BAZ SIGNAL
fprintf('*************************** MBBS **************************\n')
D = [70,300];
sign = max(D(2),63);
data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
data.Mdate = Date(data.daily,data.date ,MomLength+sign, 21);

disp('*************************** Trend Quantity with leverage  Vol Paritiy **************************\n')
[MBBSLeverage.W,MBBSLeverage.S,MBBSLeverage.L] = ...
    modelMBBS(data.p, data.daily, D(1),D(2), 90, 'tradingRule', 'overQuantity','tradingTarget',0.7);
MBBSLeverage.NW = MBBSLeverage.W.*MBBSLeverage.S;
[MBBSLeverage.R,MBBSLeverage.CumR,MBBSLeverage.Stats] = PortfolioStatistics(data.monthly,...
    MBBSLeverage.NW,MBBSLeverage.L,0.001);
[MBBSLeverage.CorrelationAnalysis] = SharpeCorrelation(MBBSLeverage.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSLeverage.FACTOR, MBBSLeverage.AFACTOR] = factoranalysis(MBBSLeverage.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** Individual Trend Quantity Risk Parity **************************\n')
[MBBS2.W,MBBS2.S,MBBS2.L] =  modelMBBS(data.p, data.daily, D(1), D(2), 90, 'tradingRule', 'overQuantity',...
    'weighting', 'riskParity','tradingTarget',0.7);
MBBS2.NW = MBBS2.W.*MBBS2.S;
[MBBS2.R,MBBS2.CumR,MBBS2.Stats] = PortfolioStatistics(data.monthly,...
    MBBS2.NW,MBBS2.L,0.001);
[MBBS2.CorrelationAnalysis] = SharpeCorrelation(MBBS2.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBS2.FACTOR, MBBS2.AFACTOR] = factoranalysis(MBBS2.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);


disp('*************************** Signal with leverage ~ Signal Weighted **************************\n')
% Improved signal and Trend quantity tracking
[MBBSEW.W,MBBSEW.S,MBBSEW.L] = modelMBBS(data.p, data.daily, D(1),D(2),90, 'tradingRule', 'overQuantity',...
    'weighting', 'EW','tradingTarget',0.7);
MBBSEW.NW = MBBSEW.W.*MBBSEW.S;
[MBBSEW.R,MBBSEW.CumR,MBBSEW.Stats] = PortfolioStatistics(data.monthly,...
    MBBSEW.NW,MBBSEW.L,0.001);
[MBBSEW.CorrelationAnalysis] = SharpeCorrelation(MBBSEW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[MBBSEW.FACTOR, MBBSEW.AFACTOR] = factoranalysis(MBBSEW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

% Plotting the results
f = figure('visible','on');
plot(data.Mdate(end-length(MBBS2.CumR)+1:end),MBBS2.CumR,data.Mdate(end-length(MBBS2.CumR)+1:end),MBBSLeverage.CumR...
    ,data.Mdate(end-length(MBBS2.CumR)+1:end), MBBSEW.CumR);%,data.Mdate(11:end),MBBS3.CumR
legend('Risk Parity','Volatility Parity','EW Quantity','location',...
    'northwest');
title('MBBS Model with trading rule on overall trend')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/MBBS', '-dpng', '-r1000')
clear f;

MBBS_stats = [renamevars(MBBS2.Stats,'Var1','Vol.Parity Ind.Quantity'),...
    renamevars(MBBSLeverage.Stats,'Var1','Vol.Parity Quantity'),...
    renamevars(MBBSEW.Stats,'Var1','EW Quantity')];
%% SSA

SSA.MomLength = 45;
SSA.LatentDim = 1;
data.monthly = MonthlyReturns(data.daily,SSA.MomLength, 21);
data.Mdate = Date(data.daily,data.date ,SSA.MomLength, 21);

% we use Singular spectrum analysis to extract a signal
disp('*************************** SSA - Volatility Parity**************************\n')
% Improved signal and Trend quantity tracking
[SSA.W,SSA.S,SSA.L] = SSA_TF(data.p, data.daily, SSA.LatentDim,...
    SSA.MomLength, 'weight', 'volParity', 'tradingRule', 'noRule', 'volTarget', 0.1);
SSA.NW = SSA.W.*SSA.S;
[SSA.R,SSA.CumR,SSA.Stats] = PortfolioStatistics(data.monthly,...
    SSA.NW(2:end,:),SSA.L(2:end),0.001);
[SSA.CorrelationAnalysis] = SharpeCorrelation(SSA.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA.FACTOR, SSA.AFACTOR] = factoranalysis(SSA.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Risk Parity **************************\n')
% Improved signal and Trend quantity tracking
[SSA_RP.W,SSA_RP.S,SSA_RP.L] = SSA_TF(data.p, data.daily, SSA.LatentDim, ...
    SSA.MomLength, 'weight', 'riskParity', 'tradingRule', 'noRule', 'volTarget', 0.1,...
    'ssaScale', 1);
SSA_RP.NW = SSA_RP.W.*SSA_RP.S;
[SSA_RP.R,SSA_RP.CumR,SSA_RP.Stats] = PortfolioStatistics(data.monthly,...
    SSA_RP.NW(2:end,:),SSA_RP.L(2:end),0.001);
[SSA_RP.CorrelationAnalysis] = SharpeCorrelation(SSA_RP.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_RP.FACTOR, SSA_RP.AFACTOR] = factoranalysis(SSA_RP.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - EW **************************\n')
% Improved signal and Trend quantity tracking
[SSA_EW.W,SSA_EW.S,SSA_EW.L] = SSA_TF(data.p, data.daily, SSA.LatentDim, ...
    SSA.MomLength, 'weight', 'EW', 'tradingRule', 'noRule', 'volTarget', 0.1);
SSA_EW.NW = SSA_EW.W.*SSA_EW.S;
[SSA_EW.R,SSA_EW.CumR,SSA_EW.Stats] = PortfolioStatistics(data.monthly,...
    SSA_EW.NW(2:end,:),SSA_EW.L(2:end),0.001);
[SSA_EW.CorrelationAnalysis] = SharpeCorrelation(SSA_EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_EW.FACTOR, SSA_EW.AFACTOR] = factoranalysis(SSA_EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Quantity **************************\n')
% Improved signal and Trend quantity tracking
[SSA_Quantity.W,SSA_Quantity.S,SSA_Quantity.L] = SSA_TF(data.p, data.daily,...
    SSA.LatentDim, SSA.MomLength,...
     'weight', 'riskParity', 'tradingRule', 'overQuantity', 'tradingTarget',...
     0.5,'volTarget', 0.1);
SSA_Quantity.NW = SSA_Quantity.W.*SSA_Quantity.S;
[SSA_Quantity.R,SSA_Quantity.CumR,SSA_Quantity.Stats] = PortfolioStatistics(data.monthly,...
    SSA_Quantity.NW(2:end,:),SSA_Quantity.L(2:end),0.001);
[SSA_Quantity.CorrelationAnalysis] = SharpeCorrelation(SSA_Quantity.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);
[SSA_Quantity.FACTOR, SSA_Quantity.AFACTOR] = factoranalysis(SSA_Quantity.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);

disp('*************************** SSA - Individual Trend Quantity **************************\n')
% Improved signal and Trend quantity tracking
[SSA_IndQuantity.W,SSA_IndQuantity.S,SSA_IndQuantity.L] = SSA_TF(data.p, data.daily,...
    SSA.LatentDim, SSA.MomLength,...
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
legend('SSA Volatility Parity','SSA Volatility Parity + Overall Trend',...
    'SSA Volatility Parity + Individual Trend','SSA Risk Parity'...
    ,'SSA Equal Weighted','location','northwest');
title('SSA signal at constant volatilty')
ylabel('Cumulative return')
xlabel('date')
print(f,'Output/SSA', '-dpng', '-r1000')
clear f;


%% Support vector machine

SVM_Model; % Lauching the model
%data.monthly = MonthlyReturns(data.daily,2274, 21);
%data.Mdate = Date(data.daily,data.date ,2274, 21);
%classificationModel = trainSVM(data, 0.4, 90);

% Volatility Parity
[SVM_MODEL.W, SVM_MODEL.S, SVM_MODEL.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'VolParity');
SVM_MODEL.NW = SVM_MODEL.W.*SVM_MODEL.S;
[SVM_MODEL.R, SVM_MODEL.CumR, SVM_MODEL.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL.S)+1:end,:),...
    SVM_MODEL.NW,SVM_MODEL.L.',0.001);
[SVM_MODEL.FACTOR, SVM_MODEL.AFACTOR] = factoranalysis(SVM_MODEL.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

% Risk Parity
[SVM_MODEL_Risk.W, SVM_MODEL_Risk.S, SVM_MODEL_Risk.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'RiskParity');
SVM_MODEL_Risk.NW = SVM_MODEL_Risk.W.*SVM_MODEL_Risk.S;
[SVM_MODEL_Risk.R, SVM_MODEL_Risk.CumR, SVM_MODEL_Risk.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_Risk.S)+1:end,:),...
    SVM_MODEL_Risk.NW,SVM_MODEL_Risk.L.',0.001);
[SVM_MODEL_Risk.FACTOR, SVM_MODEL_Risk.AFACTOR] = factoranalysis(SVM_MODEL_Risk.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_Risk.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_Risk.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);


%{
svmRisk = applySVM(data,'weight', 'riskParity');
[svmRisk.R, svmRisk.CumR, svmRisk.Stats] = PortfolioStatistics(data.monthly(end-length(svmRisk.S)+1:end,:),...
    svmRisk.NW,svmRisk.L,0.001);
%}
    
%[svmRisk.R,svmRisk.cumR,svmRisk.Stats] = PortfolioStatistics
% Equally Weighted
[SVM_MODEL_EW.W, SVM_MODEL_EW.S, SVM_MODEL_EW.L] = SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'EW');
SVM_MODEL_EW.NW = SVM_MODEL_EW.W.*SVM_MODEL_EW.S;
[SVM_MODEL_EW.R, SVM_MODEL_EW.CumR, SVM_MODEL_EW.Stats] = PortfolioStatistics(data.monthly(end-length(SVM_MODEL_EW.S)+1:end,:),...
    SVM_MODEL_EW.NW,SVM_MODEL_EW.L.',0.001);
[SVM_MODEL_EW.FACTOR, SVM_MODEL_EW.AFACTOR] = factoranalysis(SVM_MODEL_EW.R,data.fffactor.monthly, data.rf.monthly,...
    data.AF.monthly.r);
[SVM_MODEL_EW.CorrelationAnalysis] = SharpeCorrelation(SVM_MODEL_EW.R, data.monthly, 36,...
    [0 ,0.1, 0.2], data.classNum);

f = figure('visible','on');
plot(data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL.CumR, ...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_Risk.CumR,...
    data.Mdate(end-length(SVM_MODEL.CumR):end-1),SVM_MODEL_EW.CumR)
title('Support vector machine Model')
ylabel('Cumulative return')
xlabel('date')
legend('Volatility Parity','Risk Parity','Equally Weighted','location','northwest')
print(f,'Output/SVM', '-dpng', '-r1000')


%% Sensitivity Analysis

    % Sensitivity MBBS
    MBBS__Sensitivity;

    % Sensitivity SSA
    SSA_Sensitivity;

    % Sensitivity SVM
    SVM_Sensitivity;


%% Creating tables, GUI and clearing cache

% Creating tables
creatingtables;
% SG trend index barcaly en plus HFR macro systemic 
% GUI
%{
guiData;
GUI; % TODO : StartUpFcn -> Data loading before component creation
%}

plotSIGNAL(SSA_RP.S, data.classNum,...
    data.Mdate,'Output/SSA_RP_SignalDecomposition',...
    'SSA signal decomposition', ...
    data.class)

plotSIGNAL(SVM_MODEL_Risk.S, data.classNum,...
    data.Mdate,'Output/SVM_S',...
    'SVM Signal Decomposition', ...
    data.class)

plotSIGNAL(MBBSEW.S,data.classNum,...
    data.Mdate(9:end),'Output/MBBS_EW_SignalDecompostion',...
    'MBBS EW Signal Decomposition', ...
    data.class)

plotSIGNAL(MOM252VP.S,data.classNum,...
    data.Mdate(9:end),'Output/MOM252_s',...
    'MOM252 Signal Decomposition', ...
    data.class) 

plotSIGNAL(MBBSEW.S,data.classNum,...
    data.Mdate(9:end),'Output/MBBSEW',...
    'MBBSEW Signal Decomposition', ...
    data.class) 


% Clear Temporary Variables
clear height i asset A N position TF 700 x0 y0 width

%% Previous Baz keep track 
% disp('***************************   Trend Quantity   **************************\n')
% % Improved signal and Trend quantity tracking
% [MBBS.W,MBBS.S,MBBS.L] = MODEL_MBBS(data.p, data.daily, 90, 20, 200, 63, 252, 'Quantity', 0.5);
% MBBS.NW = MBBS.W.*MBBS.S;
% [MBBS.R,MBBS.CumR,MBBS.Stats] = PortfolioStatistics(data.monthly(end-length(MBBS.W):end-1,:),...
%     MBBS.NW,MBBS.L,0.001);
% [MBBS.CorrelationAnalysis] = SharpeCorrelation(MBBS.R, data.monthly, 36,...
%     [0 ,0.1, 0.2], data.classNum);
% [MBBS.FACTOR, MBBS.AFACTOR] = factoranalysis(MBBS.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);

% disp('*************************** Trend Quantity with leverage **************************\n')
% % Improved signal and Trend quantity tracking
% [MBBSLeverage.W,MBBSLeverage.S,MBBSLeverage.L] = MODEL_MBBS(data.p, data.daily, 90, 20, 200, 63, 252, 'Quantity', 0.5, 0.1);
% MBBSLeverage.NW = MBBSLeverage.W.*MBBSLeverage.S;
% [MBBSLeverage.R,MBBSLeverage.CumR,MBBSLeverage.Stats] = PortfolioStatistics(data.monthly(end-length(MBBS.W)+1:end,:),...
%     MBBSLeverage.NW,MBBSLeverage.L,0.001);
% [MBBSLeverage.CorrelationAnalysis] = SharpeCorrelation(MBBSLeverage.R, data.monthly, 36,...
%     [0 ,0.1, 0.2], data.classNum);
% [MBBSLeverage.FACTOR, MBBSLeverage.AFACTOR] = factoranalysis(MBBSLeverage.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);

% disp('*************************** Forecast **************************\n')
% % Use of a garch model and simple trading rule to avoid crash
% [MBBS3.W,MBBS3.S,MBBS3.L,MBBS3.p1] = MODEL_MBBS(data.p, data.daily, 90, 20, 200, 63, 252, 'Forecast', 0.25,RWML); 
% MBBS3.AR = (1 - MBBS3.p1).*data.rf.monthly(end-length(MBBS3.p1)+1:end).*100;
% MBBS3.NW = MBBS3.W.*MBBS3.S.*MBBS3.p1;
% MBBS3.R = MBBSLeverage.L(2:end).*(MBBS.R.*MBBS3.p1(2:end) + data.rf.monthly(end-length(MBBS3.p1)+2:end).*(1 - MBBS3.p1(2:end)));
% MBBS3.CumR = cumprod(1+MBBS3.R)*100; % OK
% MBBS3.Sharpe = SharpeRatio(MBBS3.R, 0.01); % OK
% [MBBS3.FACTOR, MBBS3.AFACTOR] = factoranalysis(MBBS3.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);

% disp('*************************** Individual Trend Quantity **************************\n')
% % Improved signal and Trend quantity tracking
% [MBBS2.W,MBBS2.S,MBBS2.L] = MODEL_MBBS(data.p, data.daily, 90, 20, 200, 63, 252, 'IndQuantity', 0.5,0.1);
% MBBS2.NW = MBBS2.W.*MBBS2.S;
% [MBBS2.R,MBBS2.CumR,MBBS2.Stats] = PortfolioStatistics(data.monthly(end-length(MBBS.W)+1:end,:),...
%     MBBS2.NW,MBBS2.L,0.001);
% [MBBS2.CorrelationAnalysis] = SharpeCorrelation(MBBS2.R, data.monthly, 36,...
%     [0 ,0.1, 0.2], data.classNum);
% [MBBS2.FACTOR, MBBS2.AFACTOR] = factoranalysis(MBBS2.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);

% position = 1;
% srp = zeros (length(110:1:120),2);
% for D=110:1:120
% sign = max(D,63);
% data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
% data.Mdate = Date(data.daily,data.date ,MomLength+sign, 21);
% if mod(position,1)==0
%     fprintf('sensitivity %d over %d has been performed !\n',position, length(20:250));
% end
% % Improved signal and Trend quantity tracking
% [MBBS2.W,MBBS2.S,MBBS2.L] =  modelMBBS(data.p, data.daily, D, 90, 'tradingRule', 'noRule', 'weighting', 'riskParity');
% MBBS2.NW = MBBS2.W.*MBBS2.S;
% [MBBS2.R,MBBS2.CumR,MBBS2.Stats] = PortfolioStatistics(data.monthly,...
%     MBBS2.NW,MBBS2.L,0.001);
% % [MBBS2.R,MBBS2.CumR,MBBS2.Stats] = PortfolioStatistics(data.monthly(end-length(MBBSLeverage.W)+1:end,:),...
% %     MBBS2.NW,MBBS2.L,0.001);
% [MBBS2.CorrelationAnalysis] = SharpeCorrelation(MBBS2.R, data.monthly, 36,...
%     [0 ,0.1, 0.2], data.classNum);
% [MBBS2.FACTOR, MBBS2.AFACTOR] = factoranalysis(MBBS2.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);
% srp(position,1) = MBBS2.Stats{'Sharpe Ratio', 'Var1'};
% srp(position,2) = D;
% position = position + 1;
% end 
% disp('*************************** Signal with leverage ~ Equally Weighted **************************\n')
% % Improved signal and Trend quantity tracking
% [MBBSEW.W,MBBSEW.S,MBBSEW.L] = MODEL_MBBS(data.p, data.daily, 90, 20, 200, 63, 252, 'Signal', 0.5,0.1);
% MBBSEW.NW = MBBSEW.W.*MBBSEW.S;
% [MBBSEW.R,MBBSEW.CumR,MBBSEW.Stats] = PortfolioStatistics(data.monthly(end-length(MBBS.W)+1:end,:),...
%     MBBSEW.NW,MBBSEW.L,0.001);
% [MBBSEW.CorrelationAnalysis] = SharpeCorrelation(MBBSEW.R, data.monthly, 36,...
%     [0 ,0.1, 0.2], data.classNum);
% [MBBSEW.FACTOR, MBBSEW.AFACTOR] = factoranalysis(MBBSEW.R,data.fffactor.monthly, data.rf.monthly,...
%     data.AF.monthly.r);
