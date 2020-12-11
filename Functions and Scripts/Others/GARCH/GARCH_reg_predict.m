function [sigma_pred,reg_predict] = GARCH_reg_predict(ret_asset,length_reg,length_bear,days_predictvola,RM,length_pastvola)
% this function estimated a garch model with a certain amount of data,it
% also make a regression of the RWML return on the past variance of the
% market and an indicator of bear market 

%   INPUT: 
% ret_asset : is a vector of the index specif signal,
% length_reg : desire length for the regression to predist the return, 200
% length_bear : is the number of day of the long term EWMA like 100 days or 200
% days, need to be bigger or equal than PW
% days_predictvola : size of the moving std of the price, recommand in the paper 63 need
% to be smaller or equal to D2
% RM : size of the moving std of the yk, recommand in the paper 252
% length_pastvola : 

%   OUTPUT:
% sigma_pred : delta of the short term EWMA using D1 and long term EWMA using D2, size (T-D2+1)x3xN, 3 because we use 3 lambda
% reg_predict : is the x_k scale by the the std of P with rolling window PW, size (T-D2+1)x3xN, 3 because we use 3 lambda



%% GARCH + return prediction 
if nargin > 4
    %allocate memory
    X = zeros(length_reg,3);
    Y = zeros(length_reg,1);
    coeff_reg = zeros(length(ret_asset)-length_reg-length_bear-1,4);
    reg_predict = zeros(length(ret_asset)-length_reg-length_bear-1,1);
    pred = zeros(days_predictvola,1);
    sigma_pred = zeros(length(ret_asset)-length_reg-length_bear-1,1);
    
    for u=1:length(ret_asset)-length_reg-length_bear-1
        for i=u:length_reg+u-1
            past_ret = prod(1+RM(i:i+length_bear-1))-1;
            X(i,1) = 0;
            if past_ret < 0
                X(i,1) = 1;
            end 
            X(i,2) = var(RM(length_bear-length_pastvola+i:length_bear+i-1));
            X(i,3) = X(i,2)*X(i,1);
            Y(i,1) = ret_asset(length_bear+i);
        end
        model1 = fitlm(X,Y);
        coeff_reg(u,:) = model1.Coefficients.Estimate;
        II = prod(1+RM(length_reg+u:length_reg+length_bear+u-1))-1;
        vola_m = var(RM(length_bear-length_pastvola+length_reg+u:length_bear+length_reg+u-1));
        reg_predict(u,1) = predict(model1,[II,vola_m,vola_m*II]); % first prediction for 453 using 452 data known
    
    % GARCH 
        eps = ret_asset(u:u+length_reg+length_bear-1)-mean(ret_asset(u:u+length_reg+length_bear-1));
        options = optimset('fminunc'); 
        options.Display = 'off';
        [parameters,~, ht] = tarch(eps, 1,0,1,'NORMAL',[],[],options);
%       III = 0;
%       if eps(end)<=0
%           III = 1;
%       end
        pred(1,1) = parameters(1) + parameters(end)*ht(end) + parameters(2)*eps(end).^2;
        for i=2:days_predictvola
            pred(i,1)= parameters(1) +(parameters(2)+parameters(3))*pred(i-1,1);
        end
        sigma_pred(u,1) = pred(end,1);

    
%         if mod(u,100) == 0
%             fprintf('prediction %d over %d has been performed !\n',u, length(length_reg:length(ret_asset)-length_bear));
%         elseif u == 1
%             disp('starting\n')
%         end
    end
end

%% only garch 
if nargin <= 4
    pred = zeros(days_predictvola,1);
    sigma_pred = zeros(length(length_reg+length_bear:length(ret_asset)-1)-length_reg-length_reg,1);
    for u=length_reg+length_bear:length(ret_asset)-1  
        % GARCH 
        eps = ret_asset(u-length_reg-length_bear+1:u)-mean(ret_asset(u-(length_reg+length_bear)+1:u));
        options = optimset('fminunc'); 
        options.Display = 'off';
        [parameters,~, ht] = tarch(eps, 1,0,1,'NORMAL',[],[],options);
%        III = 0;
%        if eps(end)<=0
%           III = 1;
%        end
        pred(1,1) = parameters(1) + parameters(end)*ht(end) + parameters(2)*eps(end).^2;
        for i=2:days_predictvola
            pred(i,1)= parameters(1) +(parameters(2)+parameters(3))*pred(i-1,1);
        end
        sigma_pred(u-length_reg-length_bear+1,1) = pred(end,1);

        x = u-length_reg-length_bear+1;
        if mod(x,1) == 0 
            fprintf('prediction %d over %d has been performed !\n',x, length(length_reg+length_bear:length(ret_asset)-1));
        elseif x == 1
            fprintf('starting\n')
        elseif x == length(length_reg+length_bear:length(ret_asset)-1)
            fprintf('end\n')
        end
    end
end 
end

