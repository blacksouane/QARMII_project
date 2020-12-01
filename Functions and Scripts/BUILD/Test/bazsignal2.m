function [S] = bazsignal2(P,d,pw,sw)
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

%length data input is sw +d
S=[8,16,32]; % not lookback number, define the lambda, short term
L=[24,48,96]; % not lookback number, define the lambda, long term
lbda1 = (S-1)./S; % define both lambda for st and lt in loop for the total signal
lbda2 = (L-1)./L;

mm = min(d,pw);
[~,N] = size(P);
ewma1 = zeros(length(sw + mm), N);
ewma2 = zeros(length(sw + mm), N);
u_k = zeros (1,N,3);
for k = 1:3
    ewma1(1,:) = P(d,:).*(1-lbda1(k))+nanmean(P(1:d-1,:)).*lbda1(k);
    ewma2(1,:) = P(d,:).*(1-lbda2(k))+nanmean(P(1:d-1,:)).*lbda2(k);
    x_k(1,:) = ewma1(1,:)-ewma2(1,:);
    y_k(1,:) = x_k(1,:)./std(P(mm+1:d));
    position = 2;
    for i=d+1:sw+d
        ewma1(position,:) = P(i,:).*(1-lbda1(k))+ewma1(position-1,:).*lbda1(k);
        ewma2(position,:) = P(i,:).*(1-lbda2(k))+ewma2(position-1,:).*lbda2(k);
        x_k(position,:) = ewma1(position,:)-ewma2(position,:);
        y_k(position,:) = x_k(position,:)./std(P(i-mm+1:i));
        position = position + 1;
    end
    z_k = y_k(end,:)./nanstd(y_k);
    u_k(:,:,k) = (z_k.*exp((-z_k.^2)./4))./0.89;
end

S = (1/3).*(u_k(:,:,1)+u_k(:,:,2)+u_k(:,:,3));

end

