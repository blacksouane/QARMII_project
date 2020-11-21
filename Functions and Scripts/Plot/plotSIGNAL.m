function [] = plotSIGNAL(S,C,DATE, PATH, varargin)

% Extract Parameters
[N, ~] = size(S); 
C_Names = unique(C); %Names of the classes
C_N = length(C_Names); %Number of class
N_IN = nargin; 

% Signal
S(S<0) = -1;
S(S>0) = 1;

% Computing Cumulative Signal by class
S_C = zeros(N, C_N); 
for c_A = 1:C_N
   S_C(:, c_A) =  sum(S(:, C == C_Names(c_A)), 2); 
end

% Managing Date / Weights Discrepancies
L_D = length(DATE);
L_W = length(S_C);
disp(L_D);
disp(L_W);
if L_D < L_W
    P_D = DATE;
    P_W = S_C(end - L_D + 1:end, :);
elseif L_D > L_W
    P_D = DATE(end-L_W + 1:end);
    P_W = S_C;
else
    P_D = DATE;
    P_W = S_C;
end

% Plot parameters
colormap winter
x0=10;
y0=10;
width=700;
height=400;
ylabel('Weights')
xlabel('date')

% Creating Object
f = figure('visible', 'on');
bar(P_D,P_W,'stacked')
set(gcf,'position',[x0,y0,width,height])
%TITLE
if N_IN > 4 
title(varargin{1})   
end
% LEGEND
if N_IN > 5
legend('Equity', 'Fx', 'Commo','FI','Location','bestoutside','Orientation','horizontal')
end

ylabel('Signal')
xlabel('date')
% OUTPUT 
if N_IN > 6
print(f,PATH,varargin{3}, '-r1000')
else
print(f,PATH, '-dpng', '-r1000')
end   




end

