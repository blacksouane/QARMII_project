% Converting foreign prices in usd prices by using the forex exchange in the dataset
data.p(:,2) = data.p(:,2).*data.p(:,9); % correct the nikkei position
data.p(:,4) = data.p(:,4).*data.p(:,8); % correct the eurostoxx position
data.p(:,5) = data.p(:,5).*data.p(:,7); % correction de SMI position
data.p(:,16) = data.p(:,16).*data.p(:,9); % correct the yen bond position
data.p(:,17) = data.p(:,17).*data.p(:,8); % correct the euro bond position
data.p(:,18) = data.p(:,18).*data.p(:,6); % correct the pound bond position

% Creating asset classes and reconstructing names
data.Temp = strings(size(data.names));
for asset = 1:18
    data.Temp(1, asset) = convertCharsToStrings(data.names{1,asset});
end
data.class=strings(size(data.names));
data.class(1:5) = 'Equity';
data.class(6:9) = 'Fx';
data.class(10:14) = 'Commo';
data.class(15:18) = 'FI';
data.names = data.Temp;
data.classNum = zeros(size(data.names));
data.classNum(data.class == 'Equity') = 1;
data.classNum(data.class == 'Fx') = 2;
data.classNum(data.class == 'Commo') = 3;
data.classNum(data.class == 'FI') = 4;
clear data.Temp

[data.daily, data.first] = ReturnNaN(data.p);
data.monthly = MonthlyReturns(data.daily, MomLength, 21);
data.Mdate = Date(data.daily,data.date ,MomLength, 21);

% plot the available asset
availablity = isfinite(data.p);
class = zeros(length(availablity),4);

for i = 1:length(availablity)
    class(i,1) = sum(availablity(i,1:5)) ;
    class(i,2) = sum(availablity(i,6:9)) ;
    class(i,3) = sum(availablity(i,10:14)) ;
    class(i,4) = sum(availablity(i,15:18)) ;
end

f = figure('visible','off');
area(data.date, class);
title('Availability of assets')
xlabel('Years')
ylabel('Number of available assets')
ylim([0 18])
x0=10;
y0=10;
width=700;
height=400;
set(gcf,'position',[x0,y0,width,height])
legend('Equity', 'Currencies', 'Commodities', 'Fixed Income','Location','bestoutside','Orientation','horizontal')
print(f,'Output/Availability', '-dpng', '-r1000')
clear availablity class f

plotprice(data.p,data.names, data.date)

%RWML = data.fffactor.daily(:,6)-data.rf.daily; %Momentum FamaFrench (Excess Return)
%RM = data.fffactor.daily(:,1); %Market (Excess Return)
clear y0 x0 width i height asset
disp('####################################################################');
disp('------------------ Processing the Data is Done ! -------------------');
disp('####################################################################');