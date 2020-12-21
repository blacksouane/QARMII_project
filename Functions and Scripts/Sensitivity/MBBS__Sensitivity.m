%{
this script perform a sensitivity analysis on the model MBBS with
volatility parity with trend quantity at 0.7. 

To measure the impact of the parameters we will inspect the sharpe and
calmar ratio. 

the parameters that vary are : 
    1. responseScale parameter
    2. Lambda
    3. both parameters

We do not change the length of the moving average as it is weighted
exponentially, the impact of changing the length is almost null

the rescale response is initially set in Baz al. at 0.89 an enter in the
rescale function R(z_k) in their paper. we test for a range from 0.5 to 1.2

lambda is the forgetting factor, it is initially set as a matrix 2 by 3 and
a multiple of 8. we decide to test for different value from 2 to 15. 

%}
D = 300; % set the length of the exponentiel moving average 
%% ResponseScale parameter varying 
disp('####################################################################');
disp('---------------- Starting the sensitivity for MBBS -----------------');
disp('####################################################################');

% recompute the date
MomLength = 252;
sign = max(D,63);
data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
data.Mdate = Date(data.daily,data.date ,MomLength+sign, 21);

% set the range for the ResponseScale parameter
RS = 0.5:0.1:1.2; 
MBBS_Sensitivity.SR = zeros(length(RS),1); % Store the sharpe with varying parameter 
MBBS_Sensitivity.CR = zeros(length(RS),1); % Store the calmar with varying parameter

position = 1;
for qt = RS 

    [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, D, 90,...
        'tradingRule', 'overQuantity','weighting', 'volParity','tradingTarget',0.7,...
        'responseScale',qt); % here is the varying parameter qt 
    MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S; % compute the net weights
    [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly,... % compute stats
        MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);

    MBBS_Sensitivity.SR(position, 1) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'}; % store the corresponding sharpe
    MBBS_Sensitivity.CR(position, 1) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'}; % store the corresponding Calmar
    %disp(MBBS_Sensitivity.Stats{'Annualized Volatility', 'Var1'});
    position = position + 1;
end 

%plot the result in term of Sharpe
f = figure('visible','on');
plot(RS, MBBS_Sensitivity.SR)
title('MBBS V.Parity O.Trend Sharpe ratio')
xlabel('responseScale')
ylabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_Sharpe', '-dpng', '-r1000')

%plot the result in term of Calmar
f = figure('visible','on');
plot(RS, MBBS_Sensitivity.CR)
title('MBBS V.Parity O.Trend Calmar ratio')
xlabel('responseScale')
ylabel('Calmar Ratio')
print(f,'Output/MBBS_Sensitivity_Calmar', '-dpng', '-r1000')


%% Lambda/ forgetting parameter varying
% set the range for the forgetting factor 
U = 4:12;

% pre-allocating the memory
MBBS_Sensitivity.SR_ST = zeros(length(U),1); % Store the sharpe with varying parameter 
MBBS_Sensitivity.CR_ST = zeros(length(U),1); % Store the calmar with varying parameter 

position = 1;
for st = U 
   
    [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, D, 90,...
        'tradingRule', 'overQuantity', 'weighting', 'volParity','tradingTarget',0.7,...
        'memory',st); % st is the changing forgetting parameter
    MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S; % compute the net weight 
    
    % compute the performance
    [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly,...
        MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);
    
    % store the sharpe and calmar ratio with the corresponding parameter
    MBBS_Sensitivity.SR_ST(position, 1) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'};
    MBBS_Sensitivity.CR_ST(position, 1) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'};
    position = position + 1;
end 

%plot the result sharpe
f = figure('visible','on');
plot(U, MBBS_Sensitivity.SR_ST)
title('MBBS V.Parity O.Trend Sharpe ratio with \lambda varying')
xlabel('\lambda')
ylabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_SharpeL', '-dpng', '-r1000')

%plot the result for the calmar
f = figure('visible','on');
plot(U, MBBS_Sensitivity.CR_ST)
title('MBBS V.Parity O.Trend Calmar ratio with \lambda varying')
xlabel('\lambda')
ylabel('Calmar Ratio')
print(f,'Output/MBBS_Sensitivity_CalmarL', '-dpng', '-r1000')

%% ResponseScale and lambda paramter varying 
RS = 0.5:0.1:1.2; % set the possible amount of RS 
U = 2:15; % set possible length of moving average 

% pre allocate the memory
MBBS_Sensitivity.SR_2 = zeros(length(RS),length(U)); %Sharpe 
MBBS_Sensitivity.CR_2 = zeros(length(RS),length(U)); %Calmar 

%set initial position 
position = 1;
pos = 1 ; 

for qt = RS % loop for the rescale parameter 
    for st = U % loop for lambda
        disp(position) % indicator where we are 
        %compute weight 
        [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, D, 90,...
        'tradingRule', 'overQuantity', 'weighting', 'volParity','tradingTarget',0.7,...
        'memory',st,'responseScale',qt);
        MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S; %net weight 
        [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly,...
            MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);
        
        % Store the sharpe and the calmar with the corresponding combination 
        MBBS_Sensitivity.SR_2(position, pos) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'};
        MBBS_Sensitivity.CR_2(position, pos) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'};
        pos = pos + 1;
    end
    position = position + 1; % Change the columns, new rescale parameter
    pos = 1; % reser pos to start again at 1
end

[X, Y] = meshgrid(U, RS); % require for the surface figure

%plot the result in a surface for sharpe 
f = figure('visible', 'on');
surf(X, Y, MBBS_Sensitivity.SR_2)
title('MBBS V.Parity O.Trend Sharpe \lambda and responseScale')
ylabel('responseScale')
xlabel('\lambda')
zlabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_SHARPE_LU', '-dpng', '-r1000')

%plot the result in a surface for calmar 
f = figure('visible', 'on');
surf(X, Y, MBBS_Sensitivity.CR_2)
title('MBBS V.Parity O.Trend Calmar \lambda and responseScale')
ylabel('responseScale')
xlabel('\lambda')
zlabel('Calmar Ratio')
print(f,'Output/MBBS_Sensitivity_Calmar_LU', '-dpng', '-r1000')

clear trend qt f U st X Y position pos