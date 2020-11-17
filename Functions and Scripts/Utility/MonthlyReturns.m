function [MonthReturn] = MonthlyReturns(Returns,LengthSignal,LengthMonth)
% Monthly Returns
%   Function Computing monthly returns. 

%Setting up parameters
Returns = Returns + 1; %To aggregate returns
asset = size(Returns,2); 

%Computing monthly returns
MonthReturn = zeros(round((length(Returns)-LengthSignal)/LengthMonth,0)-1,asset);
position = 1;

for i = LengthSignal+1:LengthMonth:(length(Returns)-LengthMonth)
    for j = 1:asset
    MonthReturn(position,j) = prod(Returns(i+2:i+LengthMonth-1,j))-1; % add +2 because we take +2 return of the month to compute the signal 
    end
    position = position + 1;
end

end