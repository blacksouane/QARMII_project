function [CumulativeReturns,Return] = StrategyReturn(Leverage,NetWeights,Returns, varargin)

% Function computing the retursn of a strategy
Returns(isnan(Returns)) = 0;

%Pre-allocating for speed
Return = zeros(length(Leverage)-1,1);

%Computing the returns
for i = 1:length(Leverage)-1
    Return(i) = Leverage(i).*NetWeights(i,:)*Returns(i,:)';
end

if strcmp(varargin(2),'on')

    %Pre-allocating for speed
    d = zeros(length(Leverage)-1,1);
    
    if size(varargin) > 2
        rate = varargin(3); % Bp given by the user
    else
        rate = 0.001; % 10 Bp if not given
    end
    
    % We compute the difference in weights
    d(1, 1) = sum(abs(NetWeights(1, :)));
    d(2:end, 1) = sum(abs(NetWeights(2:end-1, :) - NetWeights(1:end-2,:)),2);
    
    % We calculate the fee in bp
    f = d.*Leverage(1:end-1)*rate;
    Return = (1+Return).*(1 - f) - 1; 
    
end

    %Computing the cumulative returns
    CumulativeReturns = cumprod(1+Return).*100;
    

end

