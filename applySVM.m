function [portfolio, classifier] = applySVM(data, varargin)
tic
%% Input Parsing
%Create Parser Object
svmParser = inputParser;

% Define Weighting Scheme Parameters
defaultWeighting = 'volParity';
validWeighting = {'EW','volParity', 'riskParity'};
checkWeighting = @(x) any(validatestring(x, validWeighting));

% Define TradingRuleLevel parameters
defaultTradingLevel = 0.2; 
checkTradingLevel = @(x) isnumeric(x) && (x >= 0) && (x <= 1);

% Define volTarget parameters
defaultVolTarget = 0.1; 
checkVolTarget = @(x) isnumeric(x);
defaultClassifier = 1;
% Create Parsing Structure
svmParser.StructExpand = false;
addRequired(svmParser, 'data');
addOptional(svmParser, 'classifier', defaultClassifier);
addParameter(svmParser, 'weight', defaultWeighting, checkWeighting);
addParameter(svmParser, 'tradingTarget', defaultTradingLevel, checkTradingLevel);
addParameter(svmParser, 'volTarget', defaultVolTarget, checkVolTarget);

% Parse the inputs
parse(svmParser, data, varargin{:})
%% Training or using the model
% Test if we need to train the model
if isnumeric(svmParser.Results.classifier)
    disp('Training the support vector machine model')
    classifier = trainSVM(data, 0.4, 90);
    disp('Training finished, starting to perform Back-test')
else
    classifier = svmParser.Results.classifier;
    disp('The algorithm is already trained, starting to perform Back-test')
end

%% Back Test
% Parameters
portfolio.start = classifier.features.lastObs + 1;
portfolio.dailyData = data.daily(portfolio.start:end, :);
portfolio.signalLength = 90; 
[portfolio.numDay, portfolio.numAsset] = size(portfolio.dailyData);

% Find first available data
portfolio.firstData = zeros(1,portfolio.numAsset); 

    for i = 1:portfolio.numAsset
        portfolio.firstData(i) = find (~ isnan(portfolio.dailyData(:,i)), 1);
    end
 
% Preallocating memory
portfolio.numMonth = round((portfolio.numDay - portfolio.signalLength-1)/21, 0);
W = zeros(portfolio.numMonth, portfolio.numAsset);
S = W; 
L = zeros(portfolio.numMonth, 1);
position = 1;
% Allocating the loop
for time = portfolio.signalLength+1:21:portfolio.numDay

% Find index of available assets at time "time"
available = portfolio.firstData <= time - portfolio.signalLength; 
Ind = available==1;

% Define returns and prices to compute weights and signals
R_T = portfolio.dailyData(time-portfolio.signalLength+1:time,Ind);

% Compute Grosse Weights
if strcmp(svmParser.Results.weight,'volParity')
W(position, Ind) = volparity(R_T);

elseif strcmp(svmParser.Results.weight,'riskParity') 
initial = volparity(R_T);
[W(position, Ind), ~] = riskparity(R_T,  portfolio.signalLength-1, 0.1,...
    initial, 'vol');

else % equally weighted
W(position, Ind) = 1/sum(available);  

end

% Compute Signal
[S(position, Ind)] = SVM_Signal(R_T,classifier.classificationSVM, data.classNum, ...
    svmParser.Results.tradingTarget);

% We are taking leverage to get a constant running Volatility
W_T = W(position, Ind).*S(position, Ind);
L(position) = 0.1 / (sqrt(W_T*cov(R_T)*W_T.')*sqrt(252));
position = position + 1;  

end

portfolio.W = W;
portfolio.S = S; 
portfolio.L = L; 
portfolio.NW = portfolio.S.*portfolio.W; 

toc
end

