function [] = AREAWEIGHTS(W,C,DATE,PATH,varargin)
%{
INPUT:
        W : Weights of the strategy
        C : Asset Class names (or numbers)
        PATH : Output path for the plot
%}

%% INPUT
% Extract Parameters
[N, ~] = size(W); 
C_Names = unique(C); %Names of the classes
C_N = length(C_Names); %Number of class
N_IN = nargin; 

% Normalizing Weights
W = W./sum(abs(W), 2);

% Computing Cumulativ Weights by class
W_C = zeros(N, C_N); 
for c_A = 1:C_N
   W_C(:, c_A) =  sum(W(:, C == C_Names(c_A)), 2); 
end
%W_C = W_C./sum(abs(W_C),2);

% Managing Date / Weights Discrepancies
L_D = length(DATE);
L_W = length(W_C);
disp(L_D);
disp(L_W);
if L_D < L_W
    P_D = DATE;
    P_W = W_C(end - L_D + 1:end, :);
elseif L_D > L_W
    P_D = DATE(end-L_W + 1:end);
    P_W = W_C;
else
    P_D = DATE;
    P_W = W_C;
end

%% Creating the figure object

f = figure('visible','on');
area(P_D, P_W)
% TITLE
if N_IN > 4
title(varargin{1})
end
% PARAMETERS
colormap winter
x0=10;
y0=10;
width=700;
height=400;
set(gcf,'position',[x0,y0,width,height])
% LEGEND
if N_IN > 5
legend(unique(varargin{2}),'Location','bestoutside','Orientation','horizontal')
end
ylabel('Weights')
xlabel('date')
% OUTPUT 
if N_IN > 6
print(f,PATH,varargin{3}, '-r1000')
else
print(f,PATH, '-dpng', '-r1000')
end   

end

