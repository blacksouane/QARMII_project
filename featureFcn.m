function [X,Y,feature] = featureFcn(data,trainingRatio,trainingLength)

% Parameters
[N, A] = size(data.daily); 
trainLim = trainingRatio*N; 
jump = 21; 
day = 1;
position = 1;

% Extracting Features
while day + trainingLength + jump < trainLim

 %Extracting Training Data
 temp =  data.daily(day:day+trainingLength-1, :); 
 X(1, 1:A, position) = std(temp(1:trainingLength,1:A)); 
 X(2, 1:A, position) = mean(temp(1:trainingLength,1:A)); 
 X(3, 1:A, position) = skewness(temp(1:trainingLength,1:A));
 X(4, 1:A, position) = kurtosis(temp(1:trainingLength,1:A)); 
 X(5, 1:A, position) = mean(temp(1:trainingLength/3,1:A)); 
 X(6, 1:A, position) = mean(temp(trainingLength/3:trainingLength*2/3,1:A)); 
 X(7, 1:A, position) = mean(temp(trainingLength*2/3:trainingLength,1:A)); 
 X(8, 1:A, position) = data.classNum == 1;
 X(9, 1:A, position) = data.classNum == 2; 
 X(10, 1:A, position) = data.classNum == 3;
 X(11, 1:A, position) = data.classNum == 4;
 
 % Extracting Training Y Data
 temp = prod(data.daily(day+trainingLength:day+trainingLength+jump-1, :)+1) - 1;
 temp(temp>=0) = 1;
 temp(temp<0) = 0;
 Y(:,:,position) = temp;

 % Next month
 position = position + 1;
 day = day + 21;
end

% Reshaping data into 2 dimensional matrix
X = permute(X, [3, 2, 1]);
nExample = size(Y, 2)*size(Y, 3);
Y = reshape(Y, [nExample 1]);
X = reshape(X, [nExample 11]);

% Creating Feature structure
feature.nExample = nExample;
feature.predictorNames = {'Standard Error', 'Mean', 'Skewness', 'Kurtosis',...
    'Mean [0 1/3]', 'Mean [1/3 2/3]', 'Mean [2/3 1]', 'isEquity', ...
    'isFx', 'isCommo', 'isFI'};
feature.Interval = jump;
feature.trainLim = trainLim;
feature.lastObs = day + trainingLength;

end

