function [Return,CumulativeReturn,Stat_table] = PortfolioStatistics(GeneralReturn,NetWeights,Leverage, varargin)

% Computing the returns of the strategy
if size(varargin) == 1 
[CumulativeReturn,Return] = StrategyReturn(Leverage,NetWeights,GeneralReturn, 'fees', 'on',varargin(1));
else
[CumulativeReturn,Return] = StrategyReturn(Leverage,NetWeights,GeneralReturn, 'fees', 'off'); 
end

% Computing the turnover
AverageTurnover = turnover(GeneralReturn,NetWeights);

% Computing the annualized mean
Mean = prod(Return+1)^(1/(length(Return)/12))-1;

% Computing the annualized volatility
Vol = std(Return)*sqrt(12);

% Computing the Sharpe Ratios
Sharpe = SharpeRatio(Return,0.01);

% Computing the Maximum DrawDown
MaxDrawDown = MDD(Return);

% Computing the Calmar Ratio
Calmar = Mean/MaxDrawDown;

% Computing the Kurtosis
Kurt = kurtosis(Return);

% Computing the Skewness
Skew = skewness(Return);

% Compute the average normalize HH 
hh = HH(NetWeights,Leverage);

Stat_table = array2table([Mean;Vol;Kurt;Skew;AverageTurnover;...
    Sharpe;Calmar;MaxDrawDown;hh],'RowNames',{'Annualized Mean','Annualized Volatility',...
    'Kurtosis','Skewness','Average Monthly Turnover','Sharpe Ratio','Calmar Ratio'...
    'Maximum DrawDown','HH*'});

end

