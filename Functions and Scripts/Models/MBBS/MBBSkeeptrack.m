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