function [sumtable, sumtable2] = factoranalysis(R, FFm, rfm, AF)
% this function run regression for the factor analysis. We do it for the
% CAPM, 3factors and the full model with 6 factors, we compute on the
% excess return monthly. 

%   INPUT: 
% R : Vector of size TX1, ideally T=259 as we have 259 returns in MOM252
% the vector of factor is this size 
% FFM : is the matrix of the famafrench factor globaly
% rfm : is the risk free rate
% AF : is the other factors of interest, cross asset factors  
%      'GSCICommo', 'MSCIWORLD', 'MSCIEM', 'USDindex', 'GlobalBonds', 

%   OUTPUT:
% sumtable : it is a table that sum up all the regression results with the
% coefficient estimate and their pvalue. 
%
% sumtable2 : it is a table that sum up all the regression result with the
% pvalue for the specific factor 

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
model1 = fitlm(FFm(:,1),ER); % regression 
table(1,1:2) = model1.Coefficients.Estimate; % create the summary table for 1 factor 
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

%create the summary table with all the different model 
sumtable = array2table(table,'VariableNames',Names,'RowNames',...
    {'Coefficient CAPM','pValue CAPM','Coefficient FF 3F','pValue FF 3F',...
    'Coefficient FF 6F','pValue FF 6F'});

%% alternative factors
% store the names
Names2 = {'intercept','GSCICommo', 'MSCIWORLD', 'MSCIEM', 'USDindex', 'GlobalBonds'};

% adjust length 
if length(AF) > length(R)
    AF = AF(end-length(R)+1:end, :);
else
    R = R(end-length(AF)+1, :);
end

% compute excess return 
ER = R-rfm;
EAF = AF - rfm;

% Pre-allocate the memory
sumtable2 = zeros(2,6);

% Run regression  
model1 = fitlm(EAF,ER);

%store coefficient and pvalue 
sumtable2(1,:) = model1.Coefficients.Estimate;
sumtable2(2,:) = model1.Coefficients.pValue;
clear model1

% Summary table 
sumtable2 = array2table(sumtable2,'VariableNames',Names2,'RowNames',...
    {'Coefficient AF','pValue AF'});



end

