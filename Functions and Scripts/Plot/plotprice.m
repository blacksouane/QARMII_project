function  [f]= plotprice(Price,name,date)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[~,N] = size(Price);

for i=1:N
    f=figure('visible','off');
    plot(date,Price(:,i))
    title(name(i))
end 
clear f
end

