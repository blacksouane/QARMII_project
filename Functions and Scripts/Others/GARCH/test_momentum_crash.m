%% momentum crash 
% we have to predict return of the momentum do it with the market
% volatility of FF and market of FF for try 
% with this we can make a rule like if the vola increase and the expected
% return is negative we go in the risk free asset 



% bear market indicator, it is a dummy, if the past 12 months return is
% negative I_b = 1, 0 otherwise
% compute the historical volatility over the past 126 days 
%daily 
x = GARCH_reg_predict(RWML(1:452),200,251,5);
w = tradingrule_garch(x,0.018,0.022,0.027,0.032,0.357);
x = sqrt(x);
y = find(x>=0.02);
z = cumprod(1+RWML(453:end));
figure()
yyaxis left
plot(x,'r','LineWidth',2)
yline(0.015, 'LineWidth',2)
yline(0.02, 'LineWidth',2)
yline(0.025, 'LineWidth',2)
yline(0.03, 'LineWidth',2)
yline(0.035, 'LineWidth',2)
hold on
yyaxis right
plot(cumprod(1+RWML(453:end)),'b','LineWidth',2)
hold on 
yyaxis right
plot(cumprod(1+RWML(453:end)),'b','LineWidth',0.5)

% trading rule 
perfor = zeros(length(1:length(sigma_pred)),1);
w = zeros(length(1:length(sigma_pred)),1);
for i=1:length(sigma_pred)
w(i,1) = 1;
if x(i,1)>0.018 && x(i,1)<=0.022
    w(i,1) = 0.9;
elseif x(i,1)>0.022 && x(i,1)<=0.027
    w(i,1) = 0.65;
elseif x(i,1)>0.027 && x(i,1)<=0.032
    w(i,1) = 0.55;
elseif x(i,1)>0.032 && x(i,1)<=0.357
    w(i,1) = 0.35;
elseif x(i,1)>0.0357
    w(i,1) = 0.2;
end
perfor(i,1) = w(i,1).*RWML(453+i)+(1-w(i,1)).*data.rf.daily(453+i);
end

figure()
plot(data.date(453+2:end),cumprod(1+perfor))
hold on 
plot(data.date(453+2:end),cumprod(1+RWML(454:end)))

%monthly
length_reg = 200;
length_bear = 252;
length_pastvola = 126;
X = zeros(length_reg,3);
Y = zeros(length_reg,1);
coeff_reg = zeros(round((length(RWML)-length_reg-length_bear-1)/21),4);
reg_predict = zeros(round((length(RWML)-length_reg-length_bear-1)/21),1);
sigma_pred = zeros(round((length(RWML)-length_reg-length_bear-1)/21),1);
position = 1;
for u=1:21:length(RWML)-length_reg-length_bear-1
    for i=u:length_reg+u-1
        past_ret = prod(1+RM(i:i+length_bear-1))-1;
        X(i,1) = 0;
        if past_ret < 0
            X(i,1) = 1;
        end 
        X(i,2) = var(RM(length_bear-length_pastvola+i:length_bear+i-1));
        Y(i,1) = RWML(length_bear+i);
        X(i,3) = X(i,2)*X(i,1);
    end
    model1 = fitlm(X,Y);
    coeff_reg(position,:) = model1.Coefficients.Estimate;
    II = prod(1+RM(length_reg+u:length_reg+length_bear+u-1))-1;
    vola_m = var(RM(length_bear-length_pastvola+length_reg+u:length_bear+length_reg+u-1));
    reg_predict(position,1) = predict(model1,[II,vola_m,vola_m*II]); % first prediction for 453 using 452 data known
    
    % GARCH 
    eps = RWML(u:u+length_reg+length_bear-1)-mean(RWML(u:u+length_reg+length_bear-1));
    options = optimset('fminunc'); 
    options.Display = 'off';
    [parameters,~, ht] = tarch(eps, 1,1,1,[],[],[],options);
    III = 0;
    if eps(end)<=0 
        III = 1;
    end
    sigma_pred(position,1) = parameters(1) + parameters(end)*ht(end) + (parameters(2)+parameters(3)*III)*eps(end).^2;
    
    if mod(u,10) == 0 
        fprintf('prediction %d over %d has been performed !\n',position, round((length(RWML)-length_reg-length_bear-1)/21));
    elseif u == 1
        disp('starting\n')
    end
    position = position + 1;
end
figure()
plot(sqrt(sigma_pred),'r','LineWidth',2)
hold on
plot(reg_predict,'b','LineWidth',0.5)
weight_pre = (reg_predict./(10.*sigma_pred)); % lambda=10
perf = weight_pre.*data.fffactor.monthly(end-250+1:end,6)./100+(1-weight_pre).*data.rf.monthly(end-250+1:end);
figure()
plot(cumprod(1+perf))
figure()
plot(data.date(454:end),-data.fffactor.daily(453:end,6)./100,'k','LineWidth',0.3)
hold on 
plot(data.date(455:end),sqrt(sigma_pred),'r','LineWidth',0.9)
yline(0.025)
yline(-0.025)

figure()
plot(reg_predict)
yline(0)

