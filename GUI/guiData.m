%% Compute and structure the data for the GUI 

%{

For each strategy, we need :

1. Signal
2. Weights
3. Leverage

%}

%% Signals

% We need to use the smaller model so we have the same amount of data
minSize = length(SVM_MODEL.S); 

GUI.S(:, :, 1) = MBBSEW.S(end-minSize+1:end, :);
GUI.S(:, :, 2) = SSA.S(end-minSize+1:end, :);
GUI.S(:, :, 3) = SVM_MODEL.S(end-minSize+1:end, :);


%% Weights

GUI.W(:, :, 1) = SVM_MODEL_EW.W(end-minSize+1:end, :); 
GUI.W(:, :, 2) = SVM_MODEL.W(end-minSize+1:end, :);
GUI.W(:, :, 3) = SVM_MODEL_Risk.W(end-minSize+1:end, :);


%% Leverage (9)

GUI.L(:, 1, 1) = MBBSEW.L(end-minSize+1:end, :);
GUI.L(:, 1, 2) = MBBSLeverage.L(end-minSize+1:end, :);
GUI.L(:, 1, 3) = MBBSLeverage.L(end-minSize+1:end, :);
GUI.L(:, 2, 1) = SSA_EW.L(end-minSize+1:end, :);
GUI.L(:, 2, 2) = SSA.L(end-minSize+1:end, :);
GUI.L(:, 2, 3) = SSA_RP.L(end-minSize+1:end, :);
GUI.L(:, 3, 1) = SVM_MODEL_EW.L(:, end-minSize+1:end).';
GUI.L(:, 3, 2) = SVM_MODEL.L(:, end-minSize+1:end).';
GUI.L(:, 3, 3) = SVM_MODEL_Risk.L(:, end-minSize+1:end).';

% Date Vector
GUI.D = data.Mdate(end-minSize+1:end, :);
GUI.V = 0.1;

% Names
GUI.NW = ["Equally Weighted", "Volatility Parity", "Risk Parity"];
GUI.NS = ["EWMA", "SSA", "SVM"];

% asset returns
GUI.R = data.monthly(end-minSize+1:end, :);

% Load and delete
save GUI/appData.mat minSize GUI
clear GUI minSize
