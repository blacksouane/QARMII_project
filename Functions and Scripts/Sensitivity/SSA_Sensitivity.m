%% Sensitivity Analysis SSA MODEL

%{
This script perform a sensitivity analysis on the SSA MODEL.

Three parameters will vary and we will look at the Sharpe and Calmar ratio: 

       - Length of signal reconstruction.
       - Trading rule threshold.
       - Component Number extracted

Indeed, the base model reconstruct the first components for 45 days and
extract the trend from it. Therefore, we will see the impact of a longer
reconstruction and different threshold on the trading rule (individual
quantity).

The component number should not be better with bigger than one "number"
because the first components extract most of the trend that we can use. 

Changing the trading rule threshold will not yield a clear conclusion and
we will observe the results empirically

Reducing and increasing the signal should act like a momentum length. A
higher one will take time to return and therefore having massive crash
whereas a smaller one could miss the trend.
%}
%% Parameters and grid 
SSA.MomLength = 45;
SSA.LatentDim = 1;
data.monthly = MonthlyReturns(data.daily,SSA.MomLength, 21);
data.Mdate = Date(data.daily,data.date ,SSA.MomLength, 21);

%Parameters
N = 45:15:225;
V = 0.1:0.1:0.7;

LD = 1;
SSA_IndQuantity.SR = zeros(length(N), length(V));
SSA_IndQuantity.CR = zeros(length(N), length(V));

%% Computing allocation
REC_pos = 1; 
COMP_pos = 1; 
for REC = N
    
    for COMP = V
        
        % Computing the model
        [SSA_Sensibility.W,SSA_Sensibility.S,SSA_Sensibility.L] = ...
            SSA_TF(data.p, data.daily, LD, REC, 'IndQuantity', COMP, 0.1);
        SSA_Sensibility.NW = SSA_Sensibility.W.*SSA_Sensibility.S;
        [SSA_Sensibility.R,SSA_Sensibility.CumR,SSA_Sensibility.Stats] = PortfolioStatistics(data.monthly,...
            SSA_Sensibility.NW(2:end,:),SSA_Sensibility.L(2:end),0.001);
        
        % Extracting Sharpe Ratio
        SSA_IndQuantity.SR(REC_pos, COMP_pos) = SSA_Sensibility.Stats{'Sharpe Ratio', 'Var1'};
        SSA_IndQuantity.CR(REC_pos, COMP_pos) = SSA_Sensibility.Stats{'Calmar Ratio', 'Var1'};
        COMP_pos = COMP_pos + 1;
    end
    
    REC_pos = REC_pos + 1; 
    COMP_pos = 1;
end

% Construct Plot components
[X, Y] = meshgrid(N, V);

% Plotting Sharpe Ratio
f = figure('visible', 'on');
surf(X, Y, SSA_IndQuantity.SR.')
title('SSA Signal Sharpe Ratio with varying parameters')
xlabel('Length')
ylabel('Trading Rule Threshold')
zlabel('Sharpe Ratio')
print(f,'Output/SSA_Sensitivity_Sharpe', '-dpng', '-r1000')

% Plotting Calmar Ratio
f = figure('visible', 'on');
surf(X, Y, SSA_IndQuantity.CR.')
title('SSA Signal Calmar Ratio with varying parameters')
xlabel('Length')
ylabel('Trading Rule Threshold')
zlabel('Calmar Ratio Ratio')
print(f,'Output/SSA_Sensitivity_Calmar', '-dpng', '-r1000')

% Saving last parameters and clearing memory
SSA_IndQuantity.N = N;
SSA_IndQuantity.V = V;
SSA_IndQuantity.MESH_X = X;
SSA_IndQuantity.MESH_Y = Y;

%% Changing Principal Component
V_PC = 1:10; 
SSA_IndQuantity.SR_PC = zeros(1, length(V_PC));
SSA_IndQuantity.CR_PC = zeros(1, length(V_PC));
for PCA = V_PC
        % Computing the model
        [SSA_Sensibility.W,SSA_Sensibility.S,SSA_Sensibility.L] = ...
        SSA_TF(data.p, data.daily, PCA, 45, 'IndQuantity', 0.5, 0.1);
        SSA_Sensibility.NW = SSA_Sensibility.W.*SSA_Sensibility.S;
        [SSA_Sensibility.R,SSA_Sensibility.CumR,SSA_Sensibility.Stats] = PortfolioStatistics(data.monthly,...
        SSA_Sensibility.NW(2:end,:),SSA_Sensibility.L(2:end),0.001);
    
        % Extract Stats
        SSA_IndQuantity.SR_PC(1, PCA) = SSA_Sensibility.Stats{'Sharpe Ratio', 'Var1'};
        SSA_IndQuantity.CR_PC(1, PCA) = SSA_Sensibility.Stats{'Calmar Ratio', 'Var1'};
end

% Handling NaN to plot results
SSA_IndQuantity.SR_PC(isnan(SSA_IndQuantity.SR_PC)) = 0;
SSA_IndQuantity.CR_PC(isnan(SSA_IndQuantity.CR_PC)) = 0;

% Ploting the results
f = figure('visible', 'on');
yyaxis left
plot(V_PC,SSA_IndQuantity.SR_PC); 
ylabel('Sharpe Ratio')
yyaxis right
plot(V_PC,SSA_IndQuantity.CR_PC); 
title('SSA Signal Calmar Ratio with component extraction')
xlabel('Component Number')
ylabel('Calmar Ratio')
print(f,'Output/SSA_Sensitivity_Component', '-dpng', '-r1000')

%% Component + Length
REC_pos = 1; 
COMP_pos = 1; 
SSA_IndQuantity.SR_2 = zeros(length(N), length(V_PC));
SSA_IndQuantity.CR_2 = zeros(length(N), length(V_PC));

for REC = N
    
    for COMP = V_PC
        
        % Computing the model
        [SSA_Sensibility.W,SSA_Sensibility.S,SSA_Sensibility.L] = ...
            SSA_TF(data.p, data.daily, COMP, REC, 'IndQuantity', 0.5, 0.1);
        SSA_Sensibility.NW = SSA_Sensibility.W.*SSA_Sensibility.S;
        [SSA_Sensibility.R,SSA_Sensibility.CumR,SSA_Sensibility.Stats] = PortfolioStatistics(data.monthly,...
            SSA_Sensibility.NW(2:end,:),SSA_Sensibility.L(2:end),0.001);
        
        % Extracting Sharpe Ratio
        SSA_IndQuantity.SR_2(REC_pos, COMP_pos) = SSA_Sensibility.Stats{'Sharpe Ratio', 'Var1'};
        SSA_IndQuantity.CR_2(REC_pos, COMP_pos) = SSA_Sensibility.Stats{'Calmar Ratio', 'Var1'};
        COMP_pos = COMP_pos + 1;
    end
    
    REC_pos = REC_pos + 1; 
    COMP_pos = 1;
end

% Construct Plot components
[X, Y] = meshgrid(N, V_PC);
SSA_IndQuantity.SR_2(isnan(SSA_IndQuantity.SR_2)) = 0;
SSA_IndQuantity.CR_2(isnan(SSA_IndQuantity.CR_2)) = 0;

% Plotting Sharpe Ratio
f = figure('visible', 'on');
surf(X, Y, SSA_IndQuantity.SR_2.')
title('SSA Signal Sharpe Ratio with varying parameters')
xlabel('Length')
ylabel('Component')
zlabel('Sharpe Ratio')
print(f,'Output/SSA_Sensitivity_SHARPE_Component', '-dpng', '-r1000')

% Plotting Calmar Ratio
f = figure('visible', 'on');
surf(X, Y, SSA_IndQuantity.CR_2.')
title('SSA Signal Calmar Ratio with varying parameters')
xlabel('Length')
ylabel('Component')
zlabel('Calmar Ratio Ratio')
print(f,'Output/SSA_Sensitivity_Calmar_Component', '-dpng', '-r1000')

clear SSA_Sensibility N V REC_pos COMP_pos REC COMP f X Y PCA