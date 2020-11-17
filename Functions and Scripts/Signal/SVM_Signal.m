function [S] = SVM_Signal(data, Model, C, T)

[~, A] = size(data);
features = zeros(A, 11);

features(:,1)= std(data);
features(:,2)= mean(data);
features(:,3)= skewness(data);
features(:,4)= kurtosis(data);
features(:,5)= mean(data(1:30, :));
features(:,6)= mean(data(31:60, :));
features(:,7)= mean(data(61:90, :));
features(:,8)= C==1;
features(:,9)= C==2;
features(:,10)= C==3;
features(:,11)= C==4;

[S,score] = predict(Model, features);
S(S==0) = -1;
S = S.';
score = abs(score(:, 1).');
S(score<T) = 0; 

end

