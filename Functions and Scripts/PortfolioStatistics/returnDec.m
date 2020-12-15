% Compute return Decomposition and creates plots and tables

%{

We use five strategies: 

1. Momentum 252
2. Momentum 90
3. EWMA crossover
4. SSA
5. SVM

%}

% Compute decomposition
decReturn.names = {'momentum 252', 'MA', 'EWMA crossover', 'SSA', 'SVM'};
decReturn.classNames = {'Equity', 'Fx', 'Commo', 'Fixed In.'};
decReturn.contribution = zeros(4, 5);
decReturn.precision = zeros(4, 5); 
[decReturn.contribution(:, 1),decReturn.precision(:, 1)] = ...
    ReturnDecomposition(MOM252RP.NW,...
    data.monthly(end-length(MOM252RP.NW)+1:end,:),data.classNum);
[decReturn.contribution(:, 2),decReturn.precision(:, 2)] =...
    ReturnDecomposition(MARP.NW,...
    data.monthly(end-length(MARP.NW)+1:end,:),data.classNum);
[decReturn.contribution(:, 3),decReturn.precision(:, 3)] =...
    ReturnDecomposition(MBBSRPOQ.NW,...
    data.monthly(end-length(MBBSRPOQ.NW)+1:end,:),data.classNum);
[decReturn.contribution(:, 4),decReturn.precision(:, 4)] =...
    ReturnDecomposition(SSA_RP.NW,...
    data.monthly(end-length(SSA_RP.NW)+2:end,:),data.classNum);
[decReturn.contribution(:, 5),decReturn.precision(:, 5)] =...
    ReturnDecomposition(SVM_MODEL_Risk.NW,...
    data.monthly(end-length(SVM_MODEL_Risk.NW)+1:end,:),data.classNum);


% Displaying Results
X = categorical(decReturn.names);
X = reordercats(X,decReturn.names);
f = figure('visible','on');
x0=10;
y0=10;
width=800;
height=400;
set(gcf,'position',[x0,y0,width,height])
tiledlayout(1,2);
nexttile
bar(X, decReturn.contribution,'stacked')
title('Performance contribution')
ylabel('Contribution %')
ylim([-0.05 1.05])
nexttile
bar(X, decReturn.precision)
title('Frequency of positive returns')
ylabel('Frequency %')
legend(decReturn.classNames,'location','eastoutside');
print(f,'Output/decompositionReturn', '-dpng', '-r1000')
