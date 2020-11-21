function [MODEL] = SharpeCorrelation(Returns,Price,Window, Regime, Class)


% Parameters
[N,~] = size(Returns);
MODEL.C = zeros(N-Window+1,1);
MODEL.C_Inter = zeros(N-Window+1,1);
MODEL.C_Intra = zeros(N-Window+1,4);
MODEL.S = zeros(N-Window+1,1);

if N ~= length(Price)
    X = length(Price);
    Price = Price(X-N:end,:);
end
% Loop Rolling Window
for balancing = Window:N
    
    % Index of available assets
    Ind = ~isnan(Price(balancing-Window+1, :)) ;
    
    % Average Pairwise correlation
    MODEL.C(balancing-Window+1) = sum(tril(corrcoef...
        (Price(balancing-Window+1:balancing,Ind)),-1),'all')...
        /(sum(Ind)*(sum(Ind)-1)/2);
    
    % Rolling Window Sharpe Ratio
    E_R = prod(Returns(balancing-Window+1:balancing) + 1)^(12/Window)  - 1 - 0.01;
    V = std(Returns(balancing-Window+1:balancing))*sqrt(12);
    MODEL.S(balancing-Window+1) = E_R/V;
    
end

% Correlation Regime and Sharpe Ratio
NumR = length(Regime);
MODEL.SR = zeros(2, NumR);
MODEL.SR(1, :) = Regime;
for re = 1:NumR
    if re == 1
        MODEL.SR(2, re) = mean(MODEL.S(MODEL.C<Regime(re+1)& MODEL.C>Regime(re))) ;
    elseif re == NumR
        MODEL.SR(2, re) = mean(MODEL.S(MODEL.C>Regime(re))) ;
    else
        MODEL.SR(2, re) = mean(MODEL.S(MODEL.C>Regime(re) & MODEL.C<Regime(re + 1))) ;
    end
end

% Correlation inter and intra class

% Inter Class
assetClass = zeros(length(Returns), 4);
for aC = 1:4
    temp = sum(Price(:, Class == aC),2,'omitnan')/sum(Class==aC);
    if size(assetClass(:, aC)) == size(temp(1:end))
        assetClass(:, aC) = temp(1:end);
    else
        assetClass(:, aC) = temp(2:end);
    end
end

for balancing = Window:N
    % Average Pairwise correlation
    MODEL.C_Inter(balancing-Window+1) = sum(tril(corrcoef...
        (assetClass(balancing-Window+1:balancing,:)),-1),'all')...
        /(4*(3-1)/2);
end

% Intra Class
for balancing = Window:N
    for aC = 1:4
        % Average Pairwise correlation
        MODEL.C_Intra(balancing-Window+1,aC) = sum(tril(corrcoef...
            (Price(balancing-Window+1:balancing,Class == aC)),-1),'all')...
            /(sum(Class== aC)*(sum(Class== aC)-1)/2);
        
    end
end

% Regressing results
% Construction regressor 
X=[MODEL.C,MODEL.C_Inter,MODEL.C_Intra];

% fitting the model 
reg = fitlm(X,MODEL.S);
MODEL.Reg = zeros(2,7);
MODEL.Reg(1,:) = reg.Coefficients.Estimate;
MODEL.Reg(2,:) = reg.Coefficients.pValue;
MODEL.Reg = array2table(MODEL.Reg,'VariableNames',{'intercept','All','Equity','Fx','Commo','FI','InClass'},'RowNames',...
    {'Coefficient SR','pValue SR'});

end

