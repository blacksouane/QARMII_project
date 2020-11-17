function [avg_HH] = HH(w,l)
%this function compute the average normlize Herfindahl-Hirschmann index for
%a portfolio 
%   INPUT: 
% w : matrix of net weight size TxN including some zero weight if the asset is
% not available 
% l :leverage ratio size Tx1

%   OUTPUT:
% avg_HH : is the average of the HH ratio among time, it is the normalize
% ratio

N = sum(w~=0,2);
weight = w.*l;
HH = sum(weight.^2,2);
HH_s = (HH-1./N)./(1-1./N);
avg_HH = mean(HH_s);

end

