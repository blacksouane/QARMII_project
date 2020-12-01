function [crossVal] = svmCrossVal(model, kFold)

% Define cross validated model
crossVal.partitionedModel = crossval(model.classificationSVM, 'KFold', kFold);

% Compute validation predictions
[crossVal.validationPredictions, crossVal.validationScores] = kfoldPredict(crossVal.partitionedModel);

% Compute validation accuracy
crossVal.validationAccuracy = 1 - kfoldLoss(crossVal.partitionedModel, 'LossFun', 'ClassifError');

end

