%% SVM PIPELINE

%{

This script perform the two tasks of our pipeline:

    a. Feature Extraction
    b. Classifier training

The first part is done on a monthly rolling window to extract, based on a 90
days time series, the following features :

    1. Mean
    2. Volatility
    3. Skewness
    4. Kurtosis
    5. Proxy of acceleration by dividing the time-series into three 30 days
    one and computing their respective mean
    6. One Hot encode variables for the belonging to an asset class.

And we compute the return on the 90 previous days to generate the +1/-1
signal. 

This yields :
    % X = Number of properties X Number of Asset X Number Position
    % y = 1 X Number of position ( 1 if positive, 0 if negative)

We can then lauch the model to learn how to classify the data into a binary
signal.

Worth noticing that part of the process was first implemented in matlab
classification learner (typically the cross-validation) and is not present
here to simplify the process.
%}


% If there is an existing model, it deletes it to retrain the it.
if exist('SVM_MODEL','var')
    clear SVM_MODEL
end

 % Define input parameters
 SVM_MODEL.M = 90; %length of the time series from which we extract the features.
 SVM_MODEL.N = 21; %length of the position we are taking into the asset
 SVM_MODEL.TrainingRatio = 0.4;
 SVM_MODEL.Data =  data.daily;
 [N, A] = size(SVM_MODEL.Data);

 
%% 1. Feature Extractions
    
 % Extracting the features
 day = 1;
 position = 1;
 while day + SVM_MODEL.M+SVM_MODEL.N < SVM_MODEL.TrainingRatio*N
 
 %Extracting Training Data
 SVM_MODEL.X(1:SVM_MODEL.M,1:A,position) =  ...
     SVM_MODEL.Data(day:day+SVM_MODEL.M-1, :);
 SVM_MODEL.Xtrain(1, 1:A, position) = ...
     std(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); 
 SVM_MODEL.Xtrain(2, 1:A, position) = ...
     mean(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); 
 SVM_MODEL.Xtrain(3, 1:A, position) = ...
     skewness(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); 
 SVM_MODEL.Xtrain(4, 1:A, position) = ...
     kurtosis(SVM_MODEL.X(1:SVM_MODEL.M,1:A,position)); 
 SVM_MODEL.Xtrain(5, 1:A, position) = ...
     mean(SVM_MODEL.X(1:SVM_MODEL.M/3,1:A,position)); 
 SVM_MODEL.Xtrain(6, 1:A, position) = ...
     mean(SVM_MODEL.X(SVM_MODEL.M/3:SVM_MODEL.M*2/3,1:A,position)); 
 SVM_MODEL.Xtrain(7, 1:A, position) = ...
     mean(SVM_MODEL.X(SVM_MODEL.M*2/3:SVM_MODEL.M,1:A,position)); 
 SVM_MODEL.Xtrain(8, 1:A, position) = data.classNum == 1; 
 SVM_MODEL.Xtrain(9, 1:A, position) = data.classNum == 2; 
 SVM_MODEL.Xtrain(10, 1:A, position) = data.classNum == 3;
 SVM_MODEL.Xtrain(11, 1:A, position) = data.classNum == 4;
 
 % Processing Y Training Data
 Y = prod(SVM_MODEL.Data...
     (day+SVM_MODEL.M:day+SVM_MODEL.M+SVM_MODEL.N-1, :)+1) - 1;
 SVM_MODEL.Ytrain_NonBin(:,:,position) = Y;
 Y(Y>=0) = 1;
 Y(Y<0) = 0;
 SVM_MODEL.Ytrain(:,:,position) = Y;

 % Go on to the next set of returns
 day = day+21;
 position = position + 1; 
 end
 
 % Extracting necessary variables
 SVM_MODEL.day = day;
 
% We need to reshape our data to only "contain" one training asset
SVM_MODEL.Xtrain = permute(SVM_MODEL.Xtrain, [3 2 1]);
SVM_MODEL.Nexample = size(SVM_MODEL.Ytrain,2)*size(SVM_MODEL.Ytrain,3);
SVM_MODEL.Ytrain = reshape(SVM_MODEL.Ytrain, [SVM_MODEL.Nexample 1]);
SVM_MODEL.Ytrain_NonBin = reshape( SVM_MODEL.Ytrain_NonBin, [SVM_MODEL.Nexample 1]);
SVM_MODEL.Xtrain = reshape(SVM_MODEL.Xtrain, [SVM_MODEL.Nexample 11]);


%% 2. Training the model

SVM_MODEL.classificationSVM = fitcsvm(...
    SVM_MODEL.Xtrain,...
    SVM_MODEL.Ytrain, ...
    'KernelFunction','rbf',...
    'Standardize','on',...
    'CategoricalPredictors',[8, 9, 10, 11]);
    