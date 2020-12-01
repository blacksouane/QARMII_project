% make vary the level of the amount of trend in the signal 
MomLength = 252;
sign = max(D(2),63);
data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
data.Mdate = Date(data.daily,data.date ,MomLength+sign, 21);


trend = 0:0.1:0.8;
MBBS_Sensitivity.SR = zeros(length(trend),1);
MBBS_Sensitivity.CR = zeros(length(trend),1);

position = 1;
for qt = trend 

    [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, D(1), D(2), 90, 'tradingRule', 'overQuantity',...
    'weighting', 'riskParity','tradingTarget',qt);
    MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S;
    [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly(9:end,:),...
        MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);

    MBBS_Sensitivity.SR(position, 1) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'};
    MBBS_Sensitivity.CR(position, 1) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'};
    position = position + 1;
end 

f = figure('visible','on');
plot(trend, MBBS_Sensitivity.SR)
title('MBBS EW Sharpe Ratio with varying trend quantity')
xlabel('Threshold')
ylabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_Sharpe', '-dpng', '-r1000')

f = figure('visible','on');
plot(trend, MBBS_Sensitivity.CR)
title('MBBS EW Calmar ratio with varying trend quantity')
xlabel('Threshold')
ylabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_Sharpe', '-dpng', '-r1000')


%% vary long and short moving average 
% only the short term 
short = 150:10:300;

MBBS_Sensitivity.SR_ST = zeros(length(short),1);
MBBS_Sensitivity.CR_ST = zeros(length(short),1);

position = 1;
for st = short 
          sign = max(st,63);
          data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
          
    [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, 1, st, 90, 'tradingRule', 'overQuantity',...
    'weighting', 'riskParity','tradingTarget',0.5);
    MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S;
    [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly,...
        MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);

    MBBS_Sensitivity.SR_ST(position, 1) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'};
    MBBS_Sensitivity.CR_ST(position, 1) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'};
    position = position + 1;
end 

f = figure('visible','on');
plot(short, MBBS_Sensitivity.SR_ST)
title('MBBS EW Sharpe Ratio with varying Short term move')
xlabel('length of the short term EWMA')
ylabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_SharpeST', '-dpng', '-r1000')

f = figure('visible','on');
plot(short, MBBS_Sensitivity.CR_ST)
title('MBBS EW Calmar Ratio with varying Short term move')
xlabel('length of the short term EWMA')
ylabel('Calmar Ratio')
print(f,'Output/MBBS_Sensitivity_CalmarST', '-dpng', '-r1000')

%% Short and threshold
trend = 0.5:0.1:0.9;
short = 100:20:300;
MBBS_Sensitivity.SR_2 = zeros(length(trend),length(short));
MBBS_Sensitivity.CR_2 = zeros(length(trend),length(short));

position = 1;
pos = 1 ; 

for qt = trend 
    for st = short
        disp(position)
          sign = max(st,63);
          data.monthly = MonthlyReturns(data.daily, MomLength+sign, 21);
          
        [MBBS_Sensitivity.W,MBBS_Sensitivity.S,MBBS_Sensitivity.L] = modelMBBS(data.p, data.daily, D(1), st, 90, 'tradingRule', 'overQuantity',...
    'weighting', 'riskParity','tradingTarget',qt);
        MBBS_Sensitivity.NW = MBBS_Sensitivity.W.*MBBS_Sensitivity.S;
        [MBBS_Sensitivity.R,MBBS_Sensitivity.CumR,MBBS_Sensitivity.Stats] = PortfolioStatistics(data.monthly,...
            MBBS_Sensitivity.NW,MBBS_Sensitivity.L,0.001);

        MBBS_Sensitivity.SR_2(position, pos) = MBBS_Sensitivity.Stats{'Sharpe Ratio', 'Var1'};
        MBBS_Sensitivity.CR_2(position, pos) = MBBS_Sensitivity.Stats{'Calmar Ratio', 'Var1'};
        pos = pos + 1;
    end 
    position = position + 1;
    pos = 1;
end 

[X, Y] = meshgrid(short, trend);

f = figure('visible', 'on');
surf(X, Y, MBBS_Sensitivity.SR_2)
title('MBBS RP Sharpe Ratio with varying parameters')
ylabel('threshold')
xlabel('EWMA')
zlabel('Sharpe Ratio')
print(f,'Output/MBBS_Sensitivity_SHARPE_QTST', '-dpng', '-r1000')

f = figure('visible', 'on');
surf(X, Y, MBBS_Sensitivity.CR_2)
title('MBBS RP Calmar Ratio with varying parameters')
ylabel('threshold')
xlabel('EWMA')
zlabel('Calmar Ratio')
print(f,'Output/MBBS_Sensitivity_Calmar_QTST', '-dpng', '-r1000')

clear trend qt f short st X Y position pos