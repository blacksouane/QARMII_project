function  [f]= plotprice(Price,name,date)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
f=figure('visible','off');
plot(date,Price)
title(name)
end
