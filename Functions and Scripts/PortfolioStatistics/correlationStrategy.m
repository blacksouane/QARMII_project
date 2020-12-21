function [] = correlationStrategy(Names, varargin)

% Input Checking
numArgs = length(varargin);
numNames = length(Names);
assert(numNames == numArgs, 'Number of Names must be similar to number of time-series !')

% Input Extracting
minSize = 1000000;
for strategy = 1:numArgs
   temp = cell2mat(varargin(1, strategy));
   if minSize > length(temp)
       minSize = length(temp);
   end

end

timeSeries = zeros(minSize, numArgs);
for strategy = 1:numArgs
   temp = cell2mat(varargin(1, strategy));
   timeSeries(:, strategy) = temp(end-minSize+1:end, 1);
   clear temp
end

% Compute Correlation Matrix
corrMat = corrcoef(timeSeries); 

% Create Figure Results
f = figure('visible','on');
imagesc(corrMat)
x0=10;
y0=10;
width=1000;
height=600;
set(gcf,'position',[x0,y0,width,height])
set(gca, 'XTick', 1:numNames); % center x-axis ticks on bins
set(gca, 'YTick', 1:numNames); % center y-axis ticks on bins
set(gca, 'XTickLabel', Names); % set x-axis labels
set(gca, 'YTickLabel', Names); % set y-axis labels
colormap('jet'); % set the colorscheme
colorbar;  % enable colorbarcolormap('jet')
title('Correlation Matrix between strategies with risk parity')
print(f,'correlationMatrix', '-dpng', '-r1000')
end

