% Creating Data for the GUI
start = length(SVM_MODEL_Risk.CumR);
%% Signal

S = [MOM90VP.S(end-start:end, :), MOM252VP.S(end-start:end, :)...
    , MOMJUMPVP.S(end-start:end, :), MAVP.S(end-start:end, :)...
    , MBBS.S(end-start:end, :), SSA.S(end-start:end, :), SVM_MODEL.S];
S = reshape(S, [158, 18, 7]);

%% Weights

W = [MOM90VP.W(end-start:end, :), MOM90EW.W(end-start:end, :), MOM90RP.W(end-start:end, :)];
W = reshape(W, [158, 18, 3]);
%% Names
NS = ["S-T Momentum", "L-T Momentum", "9 - 12", "MA",...
    "EWMA", "SSA", "SVM"];
NW = ["EW", "Vol. Parity", "Risk Parity"]; 

%% Leverage

% We need to give the leverage to have a base constant vol, it will be a
% NumSignal X Num Weighting scheme matrix
L = zeros([7,3,length(MOM90VP.L(end-start:end, :))]);
L(1, 1, :) = MOM90EW.L(end-start:end, :);
L(1, 2, :) = MOM90VP.L(end-start:end, :);
L(1, 3, :) = MOM90RP.L(end-start:end, :);
L(2, 1, :) = MOM252EW.L(end-start:end, :);
L(2, 2, :) = MOM252VP.L(end-start:end, :);
L(2, 3, :) = MOM252RP.L(end-start:end, :);
L(3, 1, :) = MAEW.L(end-start:end, :);
L(3, 2, :) = MAVP.L(end-start:end, :);
L(3, 3, :) = MARP.L(end-start:end, :);
L(4, 1, :) = MOMJUMPEW.L(end-start:end, :);
L(4, 2, :) = MOMJUMPVP.L(end-start:end, :);
L(4, 3, :) = MOMJUMPRP.L(end-start:end, :);
L(5, 1, :) = MBBSEW.L(end-start:end, :);
L(5, 2, :) = MBBSLeverage.L(end-start:end, :); 
L(5, 3, :) = MBBSLeverage.L(end-start:end, :);
L(6, 1, :) = SSA_IndQuantity.L(end-start:end, :);
L(6, 2, :) = SSA_IndQuantity.L(end-start:end, :);
L(6, 3, :) = SSA_IndQuantity.L(end-start:end, :);
L(7, 1, :) = SVM_MODEL_EW.L;
L(7, 2, :) = SVM_MODEL.L;
L(7, 3, :) = SVM_MODEL_Risk.L;


%% Monthly Data
MR = data.monthly(end-start:end, :);
MD = data.Mdate(end-start:end, :);

V = 10; % Volatility Target

%Creating .mat file
save appData.mat start S W NS NW L MR MD V
clear start S W NS NW L MR MD V