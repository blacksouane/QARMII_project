function [s] = testbaz(DATA)

S=[8,16,32]; % not lookback number, define the lambda, short term
L=[24,48,96]; % not lookback number, define the lambda, long term
lbda1 = (S-1)./S; % define both lambda for st and lt in loop for the total signal
lbda2 = (L-1)./L;
P = DATA(2000-252-63+2:2000,:);
[T, N] = size (P);
d = 50;
position = 1;
ewma1 = zeros(length(d+13:T),N);
ewma2 = zeros(length(d+13:T),N);
uk = zeros(T-252-63+2,N,3);
x_k = zeros(253,18,3);
for k=1:3
    position = 2;
    ewma1(1, :) = P(d+13,:)*(1-lbda1(k))+nanmean(P(d+13-1:d-1,:))*lbda1(k);
    ewma2(1, :) = P(d+13,:)*(1-lbda2(k))+nanmean(P(d+13-1:d-1,:))*lbda2(k);
    for i = d+13:T
        ewma1(position, :) = P(i,:)*(1-lbda1(k))+ewma1(position-1,:).*lbda1(k);
        ewma2(position, :) = P(i,:)*(1-lbda2(k))+ewma2(position-1,:).*lbda2(k);
        position = position + 1;
    end
    x_k(:,:,k) = ewma1 - ewma2;
    
    rollstd = zeros(length(63:T),N);
    position = 1;
    for i =63:T
        rollstd(position, :) = nanstd(P(i-63+1:i,:));
        position = position + 1;
    end
    disp(size(rollstd))
    disp(size(x_k(:,:,k)))
    y_k = x_k(:,:,k)./rollstd;
    
    rollstdyk = zeros(length(252:length(y_k)),N);
    position = 1;
    for i =252:length(y_k)
        rollstdyk(position, :) = nanstd(y_k(i-252+1:i,:));
        position = position + 1;
    end
    z_k = y_k(252:end,:)./rollstdyk;
    uk(:,:,k) = (z_k.*exp((-z_k.^2)./4))./0.89;
end

s = (1/3).*(uk(:,:,1)+uk(:,:,2)+uk(:,:,3));

end

