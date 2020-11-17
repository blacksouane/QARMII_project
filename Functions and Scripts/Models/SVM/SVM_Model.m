% SVM PIPELINE

% We use "Support Vector Machine" algorithm to extract a +1/-1 Signal for
% each assets

%% Checking if the model exist

% If the model exist, we delete it because it cannot run again due to the reshaping
if exist('SVM_MODEL','var')
    clear SVM_MODEL
end

%% 1. Feature Extractions

%% Parameters
%a. We need "map" X% of our return on a rolling window to train them
 
 % parameters
 SVM_MODEL.M = 90; %length of our momentum
 SVM_MODEL.N = 21; %length of the position we are taking into the asset
 SVM_MODEL.TrainingRatio = 0.4;
 SVM_MODEL.Data =  data.daily;
 [N, A] = size(SVM_MODEL.Data);
 
 
%% Training Data

% From there I Get:
    % X = Number of properties X Number of Asset X Number Position
    % y = 1 X Number of position ( 1 if positive, 0 if negative)
    
 % Extracting the features
 day = 1;
 position = 1;
 while day + SVM_MODEL.M+SVM_MODEL.N < SVM_MODEL.TrainingRatio*N
 
 %Extracting Training Data
 SVM_MODEL.X(1:SVM_MODEL.M,1:A,position) =  SVM_MODEL.Data(day:day+SVM_MODEL.M-1, :); %We taxe M X A data of returns
 SVM_MODEL.Xtrain(1, 1:A, position) = std(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); %Std
 SVM_MODEL.Xtrain(2, 1:A, position) = mean(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); %Mean
 SVM_MODEL.Xtrain(3, 1:A, position) = skewness(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); %Skewness
 SVM_MODEL.Xtrain(4, 1:A, position) = kurtosis(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); %Kurtosis
 SVM_MODEL.Xtrain(5, 1:A, position) = mean(SVM_MODEL.X(1:SVM_MODEL.M/3,1:A,position)); %Last Mean
 SVM_MODEL.Xtrain(6, 1:A, position) = mean(SVM_MODEL.X(SVM_MODEL.M/3:SVM_MODEL.M*2/3,1:A,position)); %Middle Mean
 SVM_MODEL.Xtrain(7, 1:A, position) = mean(SVM_MODEL.X(SVM_MODEL.M*2/3:SVM_MODEL.M,1:A,position)); %Old Mean
 SVM_MODEL.Xtrain(8, 1:A, position) = data.classNum == 1; %Equity
 SVM_MODEL.Xtrain(9, 1:A, position) = data.classNum == 2; 
 SVM_MODEL.Xtrain(10, 1:A, position) = data.classNum == 3;
 SVM_MODEL.Xtrain(11, 1:A, position) = data.classNum == 4;
 
 % Extracting Training Y Data
 Y = prod(SVM_MODEL.Data(day+SVM_MODEL.M:day+SVM_MODEL.M+SVM_MODEL.N-1, :)+1) - 1;
 Y(Y>=0) = 1;
 Y(Y<0) = 0;
 SVM_MODEL.Ytrain(:,:,position) = Y;
 
 % Looping the while
 day = day + 21; % I go month by month
 position = position + 1; % Change the position of the data
 end
 SVM_MODEL.day = day;
 
 position = 1; %Set back the position
 for TF = day+1:21:N-SVM_MODEL.M-SVM_MODEL.N
     
 % Extracting Testing X data
 SVM_MODEL.X_T(1:SVM_MODEL.M,1:A,position) =  SVM_MODEL.Data(TF:TF+SVM_MODEL.M-1, :);
 SVM_MODEL.Xtest(1, 1:A, position) = std(SVM_MODEL.X_T(1:SVM_MODEL.M,1:A,position));
 SVM_MODEL.Xtest(2, 1:A, position) = mean(SVM_MODEL.X_T(1:SVM_MODEL.M,1:A,position));
 SVM_MODEL.Xtest(3, 1:A, position) = skewness(SVM_MODEL.X_T(1:SVM_MODEL.M,1:A,position));
 SVM_MODEL.Xtest(4, 1:A, position) = kurtosis(SVM_MODEL.X_T(1:SVM_MODEL.M,1:A,position));
 SVM_MODEL.Xtest(5, 1:A, position) = mean(SVM_MODEL.X_T(1:SVM_MODEL.M/3,1:A,position));
 SVM_MODEL.Xtest(6, 1:A, position) = mean(SVM_MODEL.X_T(SVM_MODEL.M/3:SVM_MODEL.M*2/3,1:A,position));
 SVM_MODEL.Xtest(7, 1:A, position) = mean(SVM_MODEL.X_T(SVM_MODEL.M*2/3:SVM_MODEL.M,1:A,position));
 SVM_MODEL.Xtest(8, 1:A, position) = data.classNum == 1; %Equity
 SVM_MODEL.Xtest(9, 1:A, position) = data.classNum == 2; 
 SVM_MODEL.Xtest(10, 1:A, position) = data.classNum == 3;
 SVM_MODEL.Xtest(11, 1:A, position) = data.classNum == 4;

 
 % Extracting Testing Y data
 Y = prod(SVM_MODEL.Data(TF+SVM_MODEL.M:TF+SVM_MODEL.M+SVM_MODEL.N, :)+1) - 1; % enelve le -1 the model.n
 Y(Y>=0) = 1;
 Y(Y<0) = 0;
 SVM_MODEL.Ytest(:,:,position) = Y;    
 position = position + 1; 
 
 end
clear Y day


% We need to reshape our data to only "contain" one training asset
SVM_MODEL.Xtest = permute(SVM_MODEL.Xtest, [3 2 1]);
SVM_MODEL.Xtrain = permute(SVM_MODEL.Xtrain, [3 2 1]);
SVM_MODEL.Nexample = size(SVM_MODEL.Ytrain,2)*size(SVM_MODEL.Ytrain,3); 
SVM_MODEL.Ytrain = reshape(SVM_MODEL.Ytrain, [SVM_MODEL.Nexample 1]);
SVM_MODEL.Xtrain = reshape(SVM_MODEL.Xtrain, [SVM_MODEL.Nexample 11]);
SVM_MODEL.Ntest = size(SVM_MODEL.Ytest,2)*size(SVM_MODEL.Ytest,3); 
SVM_MODEL.Ytest = reshape(SVM_MODEL.Ytest, [SVM_MODEL.Ntest 1]);
SVM_MODEL.Xtest = reshape(SVM_MODEL.Xtest, [SVM_MODEL.Ntest 11]);

%% 2. Training the model
SVM_MODEL.Model = fitcsvm(SVM_MODEL.Xtrain, SVM_MODEL.Ytrain, ...
    'KernelFunction','rbf','Standardize','on');
 
%% 3. Test the model
[SVM_MODEL.label, SVM_MODEL.score] = predict(SVM_MODEL.Model, SVM_MODEL.Xtest);

SVM_MODEL.NUM = sum(SVM_MODEL.label)/SVM_MODEL.Ntest;
SVM_MODEL.NUMY = sum(SVM_MODEL.Ytrain)/SVM_MODEL.Nexample;
