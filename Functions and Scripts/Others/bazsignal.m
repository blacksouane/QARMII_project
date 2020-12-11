function [sig, x_k, y_k, z_k, u_k] = bazsignal(P,D1,D2,PW,SW)
% this function compute the CTA signal based on the paper Baz

%   INPUT: 
% P : is a vector of price size TxN, need D2+SW-1 length of price as input
% D1 : is the number of day of the short term EWMA like 20 days or 50 days
% D2 : is the number of day of the long term EWMA like 100 days or 200
% days, need to be bigger or equal than PW
% PW : size of the moving std of the price, recommand in the paper 63 need
% to be smaller or equal to D-1
% SW : size of the moving std of the yk, recommand in the paper 252

%   OUTPUT:
% x_k : delta of the short term EWMA using D1 and long term EWMA using D2, size (T-D2+1)x3xN, 3 because we use 3 lambda
% y_k : is the x_k scale by the the std of P with rolling window PW, size (T-D2+1)x3xN, 3 because we use 3 lambda
% z_k : is the y_k scaled by the std of past 252 rolling std of length,
% size is reduct because larger SW=252, keep only the full rolling window,
% size is (T-D2-SW+2)x3xN
% u_k is all the zk put in a scaled function 
% sig is the weighted average of the 3 u_k for each lambda, size
% (T-D2-SW+2)xN


S=[8,16,32]; % not lookback number, define the lambda, short term
L=[24,48,96]; % not lookback number, define the lambda, long term

[T, N] = size(P);

x_k = zeros((T-D2+1),length(S), N); % preallocate the memorey
y_k = zeros((T-D2+1),length(S), N); % size from total legnth deduct the longest ewma like d2 = 200
z_k = zeros((T-D2-SW+2),length(S), N); % for zk we have to normalize by SW as there are 2 time scale time we do +2
u_k = zeros((T-D2-SW+2),length(S), N);
sig = zeros((T-D2-SW+2),N);

for k=1:N
    for i =1:3
        lbda1 = (S(i)-1)/S(i); % define both lambda for st and lt in loop for the total signal
        lbda2 = (L(i)-1)/L(i);

        EWMA1 = zeros(T-D1,1); % pre allocate the memory
        EWMA1(1,1) = nanmean(P(1:D1,k)); % first value of the EWMA is the standard SMA
        EWMA2 = zeros(T-D2,1); % same as above
        EWMA2(1,1) = nanmean(P(1:D2,k));

        j = 2;

        for t=(D1+1):T
            EWMA1(j,1) = P(t,k)*(1-lbda1)+lbda1*EWMA1(j-1,1); %compute the following EWMA ST
            j = j + 1;
        end

        j = 2;
        
        for t=(D2+1):T
            EWMA2(j,1) = P(t,k)*(1-lbda2)+lbda2*EWMA2(j-1,1);%compute the following EWMA LT
            j = j + 1;
        end
    
        x_k(:,i,k) = EWMA1((D2-D1+1):end) - EWMA2(:); % compute the difference of EWMA ST-LT 
        std_price = movstd(P((D2+1-PW):end,k), PW,'Endpoints','discard'); % need to scale by std of price length 63 take 
        %only full window
        
        y_k(:,i,k) = x_k(:,i)./std_price; % scaling by the std of the past 63 prices
        std_yk = movstd(y_k(:,i,k), SW,'Endpoints','discard');
        
        z_k(:,i,k) = y_k(SW:end,i,k)./std_yk;
        u_k(:,i,k) = (z_k(:,i,k).*exp((-(z_k(:,i,k).^2))./4))./0.89;
    end

    sig(:,k) = (1/3)*nansum(u_k(:,:,k),2); % total signal 
    
end
end

