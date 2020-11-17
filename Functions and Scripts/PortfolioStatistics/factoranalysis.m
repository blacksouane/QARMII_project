function [sumtable, sumtable2] = factoranalysis(R, FFm, rfm, AF)
% this function run regression for the factor analysis. We do it for the
% CAPM, 3factors and the full model with 6 factors, we compute on the
% excess return monthly. 

%   INPUT: 
% R : Vector of size TX1, ideally T=259 as we have 259 returns in MOM252
% the vector of factor is this size 

%   OUTPUT:
% sumtable : it is a table ta sum up all the regression results with the
% coefficient estimate and their pvalue. 

%% Input & Parameters
Names = {'intercept', 'MktRF', 'SMB', 'HML', 'RMW', 'CMA', 'Mom'};

% we need to have same length vectors 
if length(FFm) > length(R)
FFm = FFm(end-length(R)+1:end, :);
rfm = rfm(end-length(R)+1:end, :);
else
R = R(end-length(FFm)+1, :);
end

% Compute excess return and start parameters
ER = R-rfm;
table = zeros(6,7);

%% 1 Factor Model
model1 = fitlm(FFm(:,1),ER);
table(1,1:2) = model1.Coefficients.Estimate;
table(2,1:2) = model1.Coefficients.pValue;
clear model1

%% 3 factor model
model1 = fitlm(FFm(:,1:3),ER);
table(3,1:4) = model1.Coefficients.Estimate;
table(4,1:4) = model1.Coefficients.pValue;
clear model1

%% 6 factor model 
model1 = fitlm(FFm,ER);
table(5,:) = model1.Coefficients.Estimate;
table(6,:) = model1.Coefficients.pValue;
clear model1

sumtable = array2table(table,'VariableNames',Names,'RowNames',...
    {'Coefficient CAPM','pValue CAPM','Coefficient FF 3F','pValue FF 3F',...
    'Coefficient FF 6F','pValue FF 6F'});

%% alternative factors
Names2 = {'intercept','GSCICommo', 'MSCIWORLD', 'MSCIEM', 'USDindex', 'GlobalBonds'};

if length(AF) > length(R)
AF = AF(end-length(R)+1:end, :);
else
R = R(end-length(AF)+1, :);
end
ER = R-rfm;
EAF = AF - rfm;
sumtable2 = zeros(2,6);

model1 = fitlm(EAF,ER);
sumtable2(1,:) = model1.Coefficients.Estimate;
sumtable2(2,:) = model1.Coefficients.pValue;
clear model1

sumtable2 = array2table(sumtable2,'VariableNames',Names2,'RowNames',...
    {'Coefficient AF','pValue AF'});

end

