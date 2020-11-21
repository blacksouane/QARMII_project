%% SVM Sensitivty Analysis

%{
We perform a sensitivity analysis on the SVM model:

There is not a lot of parameters to vary, mainly we will vary the trading
rule based on the "Posterior Probability" of the classifiation (i.e prior
multiplied by multivariate normal density).

We will make it vary from 0 (no rule) to 0.6 (high confidence) but will
yield too much concentrated allocation. Bigger than 0.6 confidence does not
yield usanle results.

%}

%% Parameters 

%Parameters 
P = 0:0.01:0.6;

%Pre-Allocating
SVM_MODEL_Risk.Sensivity.SR = zeros(length(P), 1);
SVM_MODEL_Risk.Sensivity.CR = zeros(length(P), 1);
%% Allocation

% Number of computation
Num = 1;
for PP = P 
  
    % Computing Model
    [SENSI_Risk.W, SENSI_Risk.S, SENSI_Risk.L] = ...
        SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, PP,'RiskParity');
    SENSI_Risk.NW = SENSI_Risk.W.*SENSI_Risk.S;
    [SENSI_Risk.R, SENSI_Risk.CumR, SENSI_Risk.Stats] =...
        PortfolioStatistics(data.monthly(end-length(SENSI_Risk.S)+1:end,:),...
    SENSI_Risk.NW,SENSI_Risk.L.',0.001);
    
    % Extracting Stats
    SVM_MODEL_Risk.Sensivity.SR(Num, 1) = SENSI_Risk.Stats{'Sharpe Ratio', 'Var1'};
    SVM_MODEL_Risk.Sensivity.CR(Num, 1) = SENSI_Risk.Stats{'Calmar Ratio', 'Var1'};
    disp(Num);
    Num = Num + 1;
end

% Handling NaN to plot results
SVM_MODEL_Risk.Sensivity.SR(isnan(SVM_MODEL_Risk.Sensivity.SR)) = 0;
SVM_MODEL_Risk.Sensivity.CR(isnan(SVM_MODEL_Risk.Sensivity.CR)) = 0;

% Ploting the results
f = figure('visible', 'on');
yyaxis left
plot(P, SVM_MODEL_Risk.Sensivity.SR); 
ylabel('Sharpe Ratio')
yyaxis right
plot(P,SVM_MODEL_Risk.Sensivity.CR); 
title('SVM statistics with varying trading rule')
xlabel('Confidence Threshold to enter into a position')
ylabel('Calmar Ratio')
print(f,'Output/SSA_Sensitivity_Component', '-dpng', '-r1000')


%% Presicion analysis

%{
We use two models :

1. Without any trading rule
2. With the original trading rule 

We will generate confuion matrix for both model and it will help us
understand the precision of the model.
%}

% Extract actual (realized) signal
SVM_MODEL_Risk.Precision.start = SVM_MODEL.day + 127 + 90;
SVM_MODEL_Risk.Precision.data = data.p(SVM_MODEL_Risk.Precision.start:end, :);
Y_true = SVM_MODEL_Risk.Precision.data(21:21:end, :) - SVM_MODEL_Risk.Precision.data(1:21:end-20,:);
Y_true(Y_true < 0) = -1;
Y_true(Y_true >= 0) = 1; 
Y_true(isnan(Y_true)) = 1;
SVM_MODEL_Risk.Precision.Y_true = Y_true; 

% Run Model without trading rule
[~, SVM_MODEL_Risk.Precision.S0, ~] = ...
   SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0,'RiskParity');
[~, SVM_MODEL_Risk.Precision.S20, ~] = ...
   SVM_Strategy(data.daily, 90, SVM_MODEL, data.classNum, 0.2,'RiskParity');

% Confusion Matrix
SVM_MODEL_Risk.Precision.C0 = confusionmat(reshape(SVM_MODEL_Risk.Precision.Y_true, [157*18, 1]), ...
    reshape(SVM_MODEL_Risk.Precision.S0(2:end,:),[157*18, 1]));
SVM_MODEL_Risk.Precision.C20 = confusionmat(reshape(SVM_MODEL_Risk.Precision.Y_true, [157*18, 1]), ...
    reshape(SVM_MODEL_Risk.Precision.S20(2:end,:),[157*18, 1]));

% Ploting
f = figure('visible', 'on');
confusionchart(SVM_MODEL_Risk.Precision.C0, {'+1', '-1'})
title('Confusion matrix of SVM classifier')
print(f,'Output/SVM_Classification0', '-dpng', '-r1000')

f = figure('visible', 'on');
confusionchart(SVM_MODEL_Risk.Precision.C20, {'+1','0' ,'-1'})
title('Confusion matrix of SVM classifier')
print(f,'Output/SVM_Classification20', '-dpng', '-r1000')