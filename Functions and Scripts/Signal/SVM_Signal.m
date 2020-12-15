function [S] = SVM_Signal(data, Model, C, T)

% get the size of assets
[~, A] = size(data);

% pre-allocate the memory 
features = zeros(A, 11);

% compute the features as X for the model 
features(:,1)= std(data);
features(:,2)= mean(data);
features(:,3)= skewness(data);
features(:,4)= kurtosis(data);
features(:,5)= mean(data(1:round(length(data)/3,0), :)); % acceleration for the mean, mean for the first 30 day 
features(:,6)= mean(data(round(length(data)/3,0) + 1:2*round(length(data)/3,0), :)); % mean in the middle of the window
features(:,7)= mean(data(2*round(length(data)/3,0) + 1:end, :)); % mean at the end of the window
features(:,8)= C==1; % asset classes indicator
features(:,9)= C==2;
features(:,10)= C==3;
features(:,11)= C==4;

% make prediction from the model to get the signal 
[S,score] = predict(Model, features);

%adjustement
S(S==0) = -1; 
S = S.';
score = abs(score(:, 1).'); % compute the score 
% score = (1 + score)./2;
% disp(size(score))
% disp(score);
S(score<T) = 0; % if the score is below the threshold do nothing 

% % check
% checkModel = fitSVMPosterior(Model); 
% disp(checkModel.ScoreTransform(score))

end

