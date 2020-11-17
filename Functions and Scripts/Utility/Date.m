function monthdate = Date(returns, date, LengthSignal, LengthMonth)

%Computing Week Dates (For ploting)

monthdate=zeros(round((length(returns)-LengthSignal)/LengthMonth,0),1);
datetomonth = datenum(date);
a = LengthSignal+1;
b = round((length(returns)-LengthSignal)/LengthMonth,0);
for i=1:b
    monthdate(i) = datetomonth(a)+21; %ajouter 21 pck comme ca on a la date de fin du mois
    a = a + LengthMonth;
end
monthdate = datetime(monthdate,'ConvertFrom','datenum','InputFormat','dd-MMM-yyyy');
clear datetomonth;
clear i;
clear a;
clear b;

end
