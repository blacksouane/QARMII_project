%% SVM Sensitivity 2

%{

We need to re-run entire model, so we do it on another script.

%}

% Define Kernels try
kernels = {'rbf', 'polynomial'};
kernelsOrder = [2, 3];

% Define Length research
tsLength = [30, 40, 90 ,150, 200];

% %% Kernels Sensitivity
% disp('Kernel Sensitivity')
% svmKernelSensitivity = SVM_MODEL;  
% kernelNum = 1;
% data.monthly = MonthlyReturns(data.daily,svmKernelSensitivity.day+121, 21);
% data.Mdate = Date(data.daily,data.date ,svmKernelSensitivity.day+121, 21);
% kernelStats = zeros(1,4);
% featureStats = zeros(1,length(tsLength));
% for kernel = kernels
%     
%     if strcmp(kernel,'polynomial')
%         
%      for polynomialOrder = kernelsOrder
%          
%     svmKernelSensitivity.classificationSVM = fitcsvm(...
%         svmKernelSensitivity.Xtrain,...
%         svmKernelSensitivity.Ytrain, ...
%         'KernelFunction',string(kernel),...
%         'polynomialOrder', polynomialOrder,...
%         'Standardize','on',...
%         'CategoricalPredictors',[8, 9, 10, 11]); 
%     
%         % Back-testing the strategy
%         [svmKernelSensitivity.W, svmKernelSensitivity.S, svmKernelSensitivity.L] =...
%         SVM_Strategy(data.daily, 90, svmKernelSensitivity, ...
%         data.classNum, 0.2,'RiskParity');
%         
%         % Computing performance
%         svmKernelSensitivity.NW = svmKernelSensitivity.W.*svmKernelSensitivity.S;
%         [svmKernelSensitivity.R, svmKernelSensitivity.CumR, svmKernelSensitivity.Stats] =...
%             PortfolioStatistics(data.monthly(end-length(svmKernelSensitivity.S)+1:end,:),...
%             svmKernelSensitivity.NW,svmKernelSensitivity.L,0.001);
%         
%         % Storing the relevant data
%         kernelStats(1, kernelNum) = svmKernelSensitivity.Stats{'Sharpe Ratio', 'Var1'};
%         kernelNum = kernelNum + 1;
%      end
%      
%     else
%         
%     svmKernelSensitivity.classificationSVM = fitcsvm(...
%         svmKernelSensitivity.Xtrain,...
%         svmKernelSensitivity.Ytrain, ...
%         'KernelFunction',string(kernel),...
%         'Standardize','on',...
%         'CategoricalPredictors',[8, 9, 10, 11]);
%     
%     % Back-testing the strategy
%     [svmKernelSensitivity.W, svmKernelSensitivity.S, svmKernelSensitivity.L] =...
%     SVM_Strategy(data.daily, 90, svmKernelSensitivity, ...
%     data.classNum, 0.2,'RiskParity');
% 
%     % Computing performance
%     svmKernelSensitivity.NW = svmKernelSensitivity.W.*svmKernelSensitivity.S;
%     [svmKernelSensitivity.R, svmKernelSensitivity.CumR, svmKernelSensitivity.Stats] =...
%         PortfolioStatistics(data.monthly(end-length(svmKernelSensitivity.S)+1:end,:),...
%         svmKernelSensitivity.NW,svmKernelSensitivity.L,0.001);
% 
%     % Storing the relevant data
%     kernelStats(1, kernelNum) = svmKernelSensitivity.Stats{'Sharpe Ratio', 'Var1'};
%     end
% 
%     kernelNum = kernelNum + 1;
% end

%% Training Length
disp('Training Length')
%{ 

Here we need to compute back the entire preprocessing of the data

%}

kernelNum = 1;
featureNum = 1;
data.monthly = MonthlyReturns(data.daily,svmKernelSensitivity.day+121, 21);
data.Mdate = Date(data.daily,data.date ,svmKernelSensitivity.day+121, 21);
featureStats = zeros(length(kernels)+1,length(tsLength));

for featuresLength = tsLength

    disp(tsLength(1, featureNum))
    
    if exist('svmFeaturesSensitivity','var')
        clear svmFeaturesSensitivity
    end

    svmFeaturesSensitivity.N = 21; 
    svmFeaturesSensitivity.TrainingRatio = 0.4;
    svmFeaturesSensitivity.Data =  data.daily;
    [N, A] = size(svmFeaturesSensitivity.Data);

    % Extracting the features
     svmFeaturesSensitivity.M = featuresLength;
     day = 1;
     position = 1;
     while day + svmFeaturesSensitivity.M+svmFeaturesSensitivity.N < svmFeaturesSensitivity.TrainingRatio*N

         %Extracting Training Data
         svmFeaturesSensitivity.X(1:svmFeaturesSensitivity.M,1:A,position) =  ...
             svmFeaturesSensitivity.Data(day:day+svmFeaturesSensitivity.M-1, :);
         svmFeaturesSensitivity.Xtrain(1, 1:A, position) = ...
             std(svmFeaturesSensitivity.X(1:svmFeaturesSensitivity.M,1:A,position)); 
         svmFeaturesSensitivity.Xtrain(2, 1:A, position) = ...
             mean(svmFeaturesSensitivity.X(1:svmFeaturesSensitivity.M,1:A,position)); 
         svmFeaturesSensitivity.Xtrain(3, 1:A, position) = ...
             skewness(svmFeaturesSensitivity.X(1:svmFeaturesSensitivity.M,1:A,position)); 
         svmFeaturesSensitivity.Xtrain(4, 1:A, position) = ...
             kurtosis(svmFeaturesSensitivity.X(1:svmFeaturesSensitivity.M,1:A,position)); 
         svmFeaturesSensitivity.Xtrain(5, 1:A, position) = ...
             mean(svmFeaturesSensitivity.X(1:round(svmFeaturesSensitivity.M/3,0),1:A,position)); 
         svmFeaturesSensitivity.Xtrain(6, 1:A, position) = ...
             mean(svmFeaturesSensitivity.X(round(svmFeaturesSensitivity.M/3,0):round(svmFeaturesSensitivity.M*2/3,0),1:A,position)); 
         svmFeaturesSensitivity.Xtrain(7, 1:A, position) = ...
             mean(svmFeaturesSensitivity.X(round(svmFeaturesSensitivity.M*2/3,0):svmFeaturesSensitivity.M,1:A,position)); 
         svmFeaturesSensitivity.Xtrain(8, 1:A, position) = data.classNum == 1; 
         svmFeaturesSensitivity.Xtrain(9, 1:A, position) = data.classNum == 2; 
         svmFeaturesSensitivity.Xtrain(10, 1:A, position) = data.classNum == 3;
         svmFeaturesSensitivity.Xtrain(11, 1:A, position) = data.classNum == 4;

         % Processing Y Training Data
         Y = prod(svmFeaturesSensitivity.Data...
             (day+svmFeaturesSensitivity.M:day+svmFeaturesSensitivity.M+svmFeaturesSensitivity.N-1, :)+1) - 1;
         Y(Y>=0) = 1;
         Y(Y<0) = 0;
         svmFeaturesSensitivity.Ytrain(:,:,position) = Y;

         % Go on to the next set of returns
         day = day+21;
         position = position + 1; 
     end

     % Extracting necessary variables
     svmFeaturesSensitivity.day = day;

    % We need to reshape our data to only "contain" one training asset
    svmFeaturesSensitivity.Xtrain = permute(svmFeaturesSensitivity.Xtrain, [3 2 1]);
    svmFeaturesSensitivity.Nexample = size(svmFeaturesSensitivity.Ytrain,2)*size(svmFeaturesSensitivity.Ytrain,3);
    svmFeaturesSensitivity.Ytrain = reshape(svmFeaturesSensitivity.Ytrain, [svmFeaturesSensitivity.Nexample 1]);
    svmFeaturesSensitivity.Xtrain = reshape(svmFeaturesSensitivity.Xtrain, [svmFeaturesSensitivity.Nexample 11]);
    
    for kernel = kernels
        disp(kernel)
     if strcmp(kernel,'polynomial')
        
         for polynomialOrder = kernelsOrder
            fprintf('of order %', polynomialOrder)
        svmFeaturesSensitivity.classificationSVM = fitcsvm(...
            svmFeaturesSensitivity.Xtrain,...
            svmFeaturesSensitivity.Ytrain, ...
            'KernelFunction', string(kernel),...
            'polynomialOrder', polynomialOrder,...
            'Standardize','on',...
            'CategoricalPredictors',[8, 9, 10, 11]); 

            % Back-testing the strategy
            [svmFeaturesSensitivity.W, svmFeaturesSensitivity.S, svmFeaturesSensitivity.L] =...
            SVM_Strategy(data.daily, featuresLength, svmFeaturesSensitivity, ...
            data.classNum, 0.2,'RiskParity');

            % Computing performance
            lenMax = min(length(svmFeaturesSensitivity.S), length(data.monthly));
            svmFeaturesSensitivity.NW = svmFeaturesSensitivity.W.*svmFeaturesSensitivity.S;
            [svmFeaturesSensitivity.R, svmFeaturesSensitivity.CumR, svmFeaturesSensitivity.Stats] =...
                PortfolioStatistics(data.monthly(end-lenMax+1:end,:),...
                svmFeaturesSensitivity.NW(end-lenMax+1:end,:),svmFeaturesSensitivity.L(end-lenMax+1:end,:),0.001);

            % Storing the relevant data
            featureStats(kernelNum, featureNum) = svmFeaturesSensitivity.Stats{'Sharpe Ratio', 'Var1'};
            kernelNum = kernelNum + 1;
         end
     
    else
        
        svmFeaturesSensitivity.classificationSVM = fitcsvm(...
            svmFeaturesSensitivity.Xtrain,...
            svmFeaturesSensitivity.Ytrain, ...
            'KernelFunction',string(kernel),...
            'Standardize','on',...
            'CategoricalPredictors',[8, 9, 10, 11]);

        % Back-testing the strategy
        [svmFeaturesSensitivity.W, svmFeaturesSensitivity.S, svmFeaturesSensitivity.L] =...
        SVM_Strategy(data.daily, featuresLength, svmFeaturesSensitivity, ...
        data.classNum, 0.2,'RiskParity');

        % Computing performance
        svmFeaturesSensitivity.NW = svmFeaturesSensitivity.W.*svmFeaturesSensitivity.S;
        [svmFeaturesSensitivity.R, svmFeaturesSensitivity.CumR, svmFeaturesSensitivity.Stats] =...
            PortfolioStatistics(data.monthly(end-length(svmFeaturesSensitivity.S)+1:end,:),...
            svmFeaturesSensitivity.NW,svmFeaturesSensitivity.L,0.001);

        % Storing the relevant data
        featureStats(kernelNum, featureNum) = svmFeaturesSensitivity.Stats{'Sharpe Ratio', 'Var1'};
     end

        kernelNum = kernelNum + 1;

    end
    kernelNum = 1;
    featureNum = featureNum + 1;
end

kernelNames = {'rbf','Quadratic','Cubic'};
f = figure('visible', 'on');
bar(categorical([30, 45, 90, 150, 200]), featureStats.')
title('SVM strategy with different kernels and features')
ylabel('Sharpe Ratio')
xlabel('Features Length')
legend(kernelNames,'location', 'southoutside','Orientation','horizontal')
print(f,'Output/svmKernelSensibility', '-dpng', '-r1000')



% f = figure('visible','on');
% bar(kernelNames, kernelStats)
% title('SVM strategy with different kernels')
% ylabel('Sharpe Ratio')
% xlabel('Kernels')
% print(f,'Output/svmKernelSensibility', '-dpng', '-r1000')
% 
% f = figure('visible','on');
% bar(categorical([30, 45, 90, 150, 200]), featureStats)
% title('SVM strategy with different feature length')
% ylabel('Sharpe Ratio')
% xlabel('Feature Length')
% print(f,'Output/svmFeaturesSensibility', '-dpng', '-r1000')