function [WF, MCR] = riskparity(r, n, T,Y,varargin)

%[~,B] = size(Y);
%Setting the unused parameters of the optimisation
A = []; %No linear constraint
b = []; %No linear constraint
Aeq = []; %No Bounds on the linear constraint
beq = []; %No Bounds on the linear constraint
lb = []; %No Bounds on the weights
ub = []; %No Bounds on the weights
warning ( 'off' , 'MATLAB:nearlySingularMatrix')

% Setting the objective function
fun = @(x) - sum(log(x));

% Finding the n days covariance matrix
CovMat = cov(r(end-n:end, :)); 

% Options of the optimisation
options = optimoptions('fmincon','Display','off',...
    'algorithm','sqp','FiniteDifferenceType','central',...
    'OptimalityTolerance',1e-11);

if strcmp(varargin(1), 'gridsearch') | size(varargin) == 0
    
    % Implementing a gridsearch over a initial pair of Negative-Positive
    % starting weights

    t = 1;
    [~, ZZ] = size(Y);


    for negative = -2.51:0.5:-0.01

        i = 1;

        for positive = 0.01:0.5:2.55

            %we set the initial value
            Init = ones(size(Y));

            for asset = 1:ZZ
                if Y(asset) <= 0
                    Init(asset) = negative;
                else
                    Init(asset) = positive;
                end
            end

            % Optimizing the month's weights 
            [x,z] = fmincon(@(x) fun(x),Init,A,b,Aeq,beq,lb,ub,...
                @(x) volConst(x,T,CovMat),options);

            if i ~= 1
              if z < fval
                  W = x; 
                  fval = z; 
              end
            else
               W = x;
               fval = z;
            end

           i = i + 1;

        end

      if t ~= 1

          if fval < Fval

              Fval = fval;
              WF = W;
          end

      else
          WF = W; 
          Fval = fval; 
      end


      t = t + 1;

    end
    
else
    
    % Optimizing the month's weights 
    [WF] = fmincon(@(x) fun(x),Y,A,b,Aeq,beq,lb,ub,...
    @(x) volConst(x,T,CovMat),options);

end
     MCR =  (WF'.*(CovMat*WF')/(WF*CovMat*WF'))'.*100;
end

