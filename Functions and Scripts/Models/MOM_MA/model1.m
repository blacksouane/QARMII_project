function [W,S,l,varargout] = model1(r, M, n, target,varargin) 
% Apply the trend following strategy with respect to the data and input parameters

% INPUT : 

% r : a NXP matrix of returns (N = period, P = Number of assets)
% M : Length of the momentum signal for the basic binary signal
% n : Length of the covariance/Std computing period
% target : A level of target volatility (e.g 10%)
% varargin: 
        % 2 : The signal taking method : "signal" and choose between
        % "Binary" and "MA"
        
        % 4 : We add the weighting scheme to the method : 
              % "weight" and choose between "EW", "RP" and "VP"
              
              
        % 6 : Only useful for "MA" signal : 
            %Input number 5 and 6 are short term and long term MA length
            %If length are not given, the function automatically choose
            %length.
            
        % 8 : Only useful for "MA" signal : 
               % "price" and a matrix of Price
               % if price are not given, they are reconstructed from the 
               % matrix of return
               
%OUTPUT: 

% W: Matrix of weight of the strategy (gross weights expect for "RP").

% l: Vector of portfolio Leverage so that we have a constant volatility
%    You can choose not to have the same volatility and therefore, you can
%    ignore the leverage vector but the function is obligated to compute
%    it.

% S: Matrix of signals. For the "RP" allocation, the signal however are
%   directly inside the weights

%varargout: 
%   MCR : The marginal contribution to risk of each asset for the "RP".

%% Input Checking and extraction
% Get desired strategy
if mod(size(varargin, 2), 2)~=0  %All input in varagin goes by 2.
        error('Cannot have an odd number of input arguments in varargin')
else 
    for input = 1:2:min(size(varargin, 2),4) %we just check that these are the right names
       if strcmp(varargin(input),'signal') || ...
               strcmp(varargin(input),'weight')

       else 
           error('varargin argument(s) are not available ones')
       end 
    end

end

% Analysing the elements in varargin and creating cases :
switch size(varargin, 2)
    
    case 0 %nothing is given, we choose the standard version of the strategy
      scheme = 'VP';
      signal = 'Binary';
    
    case 2 %No weighting scheme is given and so we choose only the signal
        
      scheme = 'VP';
      if strcmp(varargin(2),'Binary') || strcmp(varargin(2),'MA') || strcmp(varargin(2),'MomJump')
          
         signal = varargin(2);
         
      else
          error('Not a valid type of signal, choose between "Binary","MA" or "MomJump"');
      end
      
    case 4 % Both the signal and the weighting scheme are choosen by the user
        
       if strcmp(varargin(2),'Binary') || strcmp(varargin(2),'MA') || strcmp(varargin(2),'MomJump')
          
            signal = varargin(2);
         
            else
             error('Not a valid type of signal, choose between "Binary","MA" or "MomJump"');
       end
      
      if strcmp(varargin(4),'RP') || strcmp(varargin(4),'VP')|| strcmp(varargin(4),'EW')
          
            scheme = varargin(4);
         
            else
             error('Not a valid type of weighting scheme,... choose between "RP", "VP" and "EW"');
      end
      
      if strcmp(varargin(2),'MA') % if the user did not gave the length of the MA days
          
          delta = [21, 30];
          p = cumprod(r + 1, 1); 
      end
      
      if strcmp(varargin(4),'RP') && size(varargin,2) <= 4
          initial = 'VolParity';
      end
      
    case 6  %MA but no price are given, so we extract them from r or RP with choose gridsearch
        
       if ~strcmp(varargin(2),'MA') && ~strcmp(varargin(4),'RP')
           
           error('You give MA length but did not choose MA as a signal')
           
       else
           
           delta = cell2mat([varargin(5), varargin(6)]);
           signal = varargin(2);
           scheme = varargin(4);
           p = cumprod(r + 1, 1); 
           
       end
       
       if strcmp(varargin(4),'RP')
           disp('**************************Initializing Grid Search**************************');
           initial = cell2mat(varargin(6));
           disp(class(initial))
       end
       
    case 8 %Everything is given
             if ~strcmp(varargin(2),'MA')
           error('You give MA length but did not choose MA as a signal')
           
            else 
           delta = cell2mat([varargin(5), varargin(6)]);
           p = cell2mat(varargin(8));
           signal = varargin(2);
           scheme = varargin(4);
           initial = 'VolParity';
             end
    otherwise  %we cannot have another number of input in varagin
        error('You can choose between 0, 2, 4, 6 or 8 input in varargin')
end

%% Parameters Computations and setting
% Getting parameters
[T, A] = size(r);

f = zeros(1,A); %Vector having each first available return

    for i = 1:A
        f(i) = find (~ isnan(r(:,i)), 1);
    end

 % Preallocating the memory
  W = zeros(round((T - M)/21, 0), A); %Weights
  l = zeros(round((T - M)/21, 0), 1); %Leverage
  S = zeros(round((T - M)/21, 0), A); %Signal
  position = 1; %allow for monthly rebalancing
  
%% Strategy allocation

% Here we compute the choice of the user using the value given by : 
% switch case
if strcmp(signal,'Binary') && strcmp(scheme,'VP') % Momentum252, and volatility parity 
    
    
    for time = M+1:21:T  %We rebalance every month starting after the first
                         %momentum signal.
                         
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = volparity(toCompute);
        
        % Compute the signals
        S(position,Ind) = binsignal(r(time - M:time, Ind));
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
        
        % Indicating where is the allocation 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end

    
elseif strcmp(signal,'Binary') && strcmp(scheme,'RP') % Momentum252, and Risk parity
    
        MCR = zeros(round((T - M)/21, 0), A);
        CORR = zeros(round((T - M)/21, 0), 1);
        
    for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute the signal
        S(position,Ind) = binsignal(r(time - M:time, Ind));
        
        % Computing initial allocation
        NW = volparity(toCompute);%.*S(position,Ind);
        
        % Compute Weights
        [W(position, Ind), MCR(position,Ind)] = riskparity(toCompute,  n, target,NW, initial);
        
        % Compute Leverage
        W_l = W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
        
        % Indicating where is the allocation
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next Rebalancing 
        position = position + 1;
    end
    
        varargout{1} = MCR;
        varargout{2} = CORR;
        
elseif strcmp(signal,'Binary') && strcmp(scheme,'EW') % Momentum252, and Equally weighted
    
     for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);
        
        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = 1/size(Ind,2);
        
        % Compute the signals
        S(position,Ind) = binsignal(r(time - M:time, Ind));
        
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
        
        % Indicating where is the allocation
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end
    
elseif strcmp(signal,'MA') && strcmp(scheme,'VP') % Moving average, and volatility parity
    
    for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = volparity(toCompute);
        
        % Compute the signals
        S(position,Ind) = MAsignal(p(1:time, Ind),delta(1), delta(2));
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
    
        % Indicating where is the allocation
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, 260);
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end

elseif strcmp(signal,'MA') && strcmp(scheme,'RP') % Moving average, and Risk parity

        MCR = zeros(round((T - M)/21, 0), A);
        
    for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute the signals
        S(position,Ind) = MAsignal(p(time - M:time, Ind),delta(1), delta(2));
        
        NW = volparity(toCompute);%.*S(position,Ind);
        
        % Compute Weights
        [W(position, Ind), MCR(position,Ind)] = riskparity(toCompute,  n, target, NW,initial);
        
        % Compute Leverage
        W_l = W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
    
        % Indicate where the allocation is 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end
    
        varargout{1} = MCR;
        
elseif strcmp(signal,'MA') && strcmp(scheme,'EW') % Moving average, and equally weighted
    
    for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);
        
        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = 1/size(Ind,2);
        
        % Compute the signals
        S(position,Ind) = MAsignal(p(time - M:time, Ind),delta(1), delta(2));
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
    
        % Indicate where the allocation is 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end
    
elseif strcmp(signal,'MomJump') && strcmp(scheme,'VP') % Momentum with last 3 months signal and vol. parity 
    
    
    for time = M+1:21:T  %We rebalance every month starting after the first
                         %momentum signal.
                         
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = volparity(toCompute);
        
        % Compute the signals
        S(position,Ind) = binsignal(r(time - M+1:time-M + 90, Ind));
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
    
        % Indicate where the allocation is 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end

    
elseif strcmp(signal,'MomJump') && strcmp(scheme,'RP') % Momentum with last 3 months signal and Risk parity 
    
        MCR = zeros(round((T - M)/21, 0), A);
        
    for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);

        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute the signal
        S(position,Ind) = binsignal(r(time - M+1:time- M + 90, Ind));
        
        % Computing initial allocation
        NW = volparity(toCompute);%.*S(position,Ind)
        
        % Compute Weights
        [W(position, Ind), MCR(position,Ind)] = riskparity(toCompute,  n, target,NW, initial);
        
        % Compute Leverage
        W_l = W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
        
        % Indicate where the allocation is 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end
    
        varargout{1} = MCR;
    
elseif strcmp(signal,'MomJump') && strcmp(scheme,'EW') % Momentum with last 3 months signal and equally weighted 
    
     for time = M+1:21:T
        
        % Find index of available assets at time "time"
        available = f <= time - M; 
        Ind = find(available==1);
        
        % Define returns to compute weights
        toCompute = r(time - n:time, Ind);
        
        % Compute Weights
        W(position, Ind) = 1/size(Ind,2);
        
        % Compute the signals
        S(position,Ind) = binsignal(r(time - M+1:time- M + 90, Ind));
        
        % Compute Leverage
        W_l = S(position,Ind).*W(position, Ind);
        C_l = cov(toCompute);
        l(position) = target / (sqrt(W_l*C_l*W_l.')*sqrt(252));
    
        % Indicate where the allocation is 
        if mod(position,10) == 0 
           fprintf('Allocation %d over %d has been performed !\n',position, length(M+1:21:T));
        elseif position == 1
            disp('Optimisation is starting\n')
        end
        
        % Next rebalancing
        position = position + 1;
    end
else 
    error('Matlab Error 01') %Undefined Error 
    
    
end

end

