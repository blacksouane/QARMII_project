%% GUI DATA Processing

%{

We need to preprocess the data so the GUI doesn't need to perform the heavy lifting of the computations. Obviously, the main elements that we need are :

1. app.W = Weights of size [L X N X T]
2. app.S = Signals of size [L X N X Z]
3. app.L = Leverage of size [N X Z X T]

Where : 

- L = length of the longest strategy : the smallest one will be composed of zero up until they start.
- N = Number of assets in the universe.
- T = Number of different signals (probably 4)
- Z = Number of different weights (3)

To process the good strategy, the right timeline as well as the portfolio computations, we will need : 

1. app.initialVolatility = 10% → The initial volatility target. 
2. app.signalNames = {'signal_1', ..., 'signal_n'}
3. app.weightNames = {'weight_1', ..., 'weight_n'}
4. app.defaultFee = 10 → initial weights
5. app.dateFull = vector of date of size [L X 1]
6. app.firstDate = vector of size [1 X T] with the availability of the strategy


%}

% Parameters
minLength = min([length(MOM90RP.CumR), length(MOM252RP.CumR), length(MAVP.CumR), ...
    length(MBBSEWOQ.CumR), length(SSA_RP.CumR),length(SVM_MODEL_Risk.CumR)]);

%% Benchmark Building


netWeightBenchmark(:, :, 1) = MOM90EW.W(end-minLength+1:end,:);
netWeightBenchmark(:, :, 2) = MOM90VP.W(end-minLength+1:end,:);
netWeightBenchmark(:, :, 3) = MOM90RP.W(end-minLength+1:end,:);
leverageBenchmark(:, 1) = MOM90EW.L(end-minLength+1:end,:);
leverageBenchmark(:, 2) = MOM90VP.L(end-minLength+1:end,:);
leverageBenchmark(:, 3) = MOM90RP.L(end-minLength+1:end,:);


%% Strategies Loading

% Net Weights
cumulativeReturn(:, 1, 1) = MOM90EW.CumR(end-minLength+1:end);
cumulativeReturn(:, 1, 2) = MOM90VP.CumR(end-minLength+1:end);
cumulativeReturn(:, 1, 3) = MOM90RP.CumR(end-minLength+1:end);
cumulativeReturn(:, 2, 1) = MOM252EW.CumR(end-minLength+1:end);
cumulativeReturn(:, 2, 2) = MOM252VP.CumR(end-minLength+1:end);
cumulativeReturn(:, 2, 3) = MOM252RP.CumR(end-minLength+1:end);
cumulativeReturn(:, 3, 1) = MAEW.CumR(end-minLength+1:end); 
cumulativeReturn(:, 3, 2) = MAVP.CumR(end-minLength+1:end); 
cumulativeReturn(:, 3, 3) = MARP.CumR(end-minLength+1:end); 
cumulativeReturn(:, 4, 1) = MBBSEWOQ.CumR(end-minLength+1:end);
cumulativeReturn(:, 4, 2) = MBBSVPOQ.CumR(end-minLength+1:end);
cumulativeReturn(:, 4, 3) = MBBSRPOQ.CumR(end-minLength+1:end);
cumulativeReturn(:, 5, 1) = SSA_EW.CumR(end-minLength+1:end); 
cumulativeReturn(:, 5, 3) = SSA.CumR(end-minLength+1:end); 
cumulativeReturn(:, 5, 3) = SSA_RP.CumR(end-minLength+1:end); 
cumulativeReturn(:, 6, 1) = SVM_MODEL.CumR(end-minLength+1:end);
cumulativeReturn(:, 6, 2) = SVM_MODEL_EW.CumR(end-minLength+1:end); 
cumulativeReturn(:, 6, 3) = SVM_MODEL_Risk.CumR(end-minLength+1:end);  

% Net Weights
returnMonth(:, 1, 1) = MOM90EW.R(end-minLength+1:end);
returnMonth(:, 1, 2) = MOM90VP.R(end-minLength+1:end);
returnMonth(:, 1, 3) = MOM90RP.R(end-minLength+1:end);
returnMonth(:, 2, 1) = MOM252EW.R(end-minLength+1:end);
returnMonth(:, 2, 2) = MOM252VP.R(end-minLength+1:end);
returnMonth(:, 2, 3) = MOM252RP.R(end-minLength+1:end);
returnMonth(:, 3, 1) = MAEW.R(end-minLength+1:end); 
returnMonth(:, 3, 2) = MAVP.R(end-minLength+1:end); 
returnMonth(:, 3, 3) = MARP.R(end-minLength+1:end); 
returnMonth(:, 4, 1) = MBBSEWOQ.R(end-minLength+1:end);
returnMonth(:, 4, 2) = MBBSVPOQ.R(end-minLength+1:end);
returnMonth(:, 4, 3) = MBBSRPOQ.R(end-minLength+1:end);
returnMonth(:, 5, 1) = SSA_EW.R(end-minLength+1:end); 
returnMonth(:, 5, 3) = SSA.R(end-minLength+1:end); 
returnMonth(:, 5, 3) = SSA_RP.R(end-minLength+1:end); 
returnMonth(:, 6, 1) = SVM_MODEL.R(end-minLength+1:end);
returnMonth(:, 6, 2) = SVM_MODEL_EW.R(end-minLength+1:end); 
returnMonth(:, 6, 3) = SVM_MODEL_Risk.R(end-minLength+1:end);

% Net Weights
turnover( 1, 1) = MOM90EW.Stats{'Average Monthly Turnover','Var1'};
turnover( 1, 2) = MOM90VP.Stats{'Average Monthly Turnover','Var1'};
turnover( 1, 3) = MOM90RP.Stats{'Average Monthly Turnover','Var1'};
turnover( 2, 1) = MOM252EW.Stats{'Average Monthly Turnover','Var1'};
turnover( 2, 2) = MOM252VP.Stats{'Average Monthly Turnover','Var1'};
turnover( 2, 3) = MOM252RP.Stats{'Average Monthly Turnover','Var1'};
turnover( 3, 1) = MAEW.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 3, 2) = MAVP.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 3, 3) = MARP.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 4, 1) = MBBSEWOQ.Stats{'Average Monthly Turnover','Var1'};
turnover( 4, 2) = MBBSVPOQ.Stats{'Average Monthly Turnover','Var1'};
turnover( 4, 3) = MBBSRPOQ.Stats{'Average Monthly Turnover','Var1'};
turnover( 5, 1) = SSA_EW.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 5, 3) = SSA.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 5, 3) = SSA_RP.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 6, 1) = SVM_MODEL.Stats{'Average Monthly Turnover','Var1'};
turnover( 6, 2) = SVM_MODEL_EW.Stats{'Average Monthly Turnover','Var1'}; 
turnover( 6, 3) = SVM_MODEL_Risk.Stats{'Average Monthly Turnover','Var1'};
%% Helper Building

initialVolatility = 0.1;
signalNames = ["Momentum S-T", "Momentum L-T", "Moving Average", "EWMA", "SSA", "SVM"];
weightNames = ["Equally Weighted", "Volatility Parity", "Risk Parity"];
statsName = SVM_MODEL_Risk.Stats.Properties.RowNames;
defaultFee = 10;
dateMonthGui = data.Mdate(end-minLength-1:end-2);
dataMonthly = data.monthly(end-minLength-1:end-2, :);

%% Create Variable

% Load and delete
save GUI/appData.mat minLength netWeightBenchmark leverageBenchmark ...
    cumulativeReturn returnMonth initialVolatility signalNames weightNames ...
    defaultFee dateMonthGui dataMonthly statsName turnover
clear minLength netWeightBenchmark leverageBenchmark ...
    cumulativeReturn returnMonth initialVolatility signalNames weightNames ...
    defaultFee dateMonthGui dataMonthly statsName turnover