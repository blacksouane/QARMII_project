% ----------------------------------------------------------------------- %
% Function table2latex(T, filename) converts a given MATLAB(R) table into %
% a plain .tex file with LaTeX formatting.                                %
%                                                                         %
%   Input parameters:                                                     %
%       - T:        MATLAB(R) table. The table should contain only the    %
%                   following data types: numeric, boolean, char or string.
%                   Avoid including structs or cells.                     %
%       - filename: (Optional) Output path, including the name of the file.
%                   If not specified, the table will be stored in a       %
%                   './table.tex' file.                                   %  
% ----------------------------------------------------------------------- %
%   Example of use:                                                       %
%       LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};             %
%       Age = [38;43;38;40;49];                                           %
%       Smoker = logical([1;0;1;0;1]);                                    %
%       Height = [71;69;64;67;64];                                        %
%       Weight = [176;163;131;133;119];                                   %
%       T = table(Age,Smoker,Height,Weight);                              %
%       T.Properties.RowNames = LastName;                                 %
%       table2latex(T);                                                   %                                       
% ----------------------------------------------------------------------- %
%   Version: 1.1                                                          %
%   Author:  Victor Martinez Cagigal                                      %
%   Date:    09/10/2018                                                   %
%   E-mail:  vicmarcag (at) gmail (dot) com                               %
% ----------------------------------------------------------------------- %
function table2latex(T, filename)
    
    % Error detection and default parameters
    if nargin < 2
        filename = 'table.tex';
        fprintf('Output path is not defined. The table will be written in %s.\n', filename); 
    elseif ~ischar(filename)
        error('The output file name must be a string.');
    else
        if ~strcmp(filename(end-3:end), '.tex')
            filename = [filename '.tex'];
        end
    end
    if nargin < 1, error('Not enough parameters.'); end
    if ~istable(T), error('Input must be a table.'); end
    
    % Parameters
    n_col = size(T,2);
    col_spec = [];
    for c = 1:n_col, col_spec = [col_spec 'l']; end
    col_names = strjoin(T.Properties.VariableNames, ' & ');
    row_names = T.Properties.RowNames;
    if ~isempty(row_names)
        col_spec = ['l' col_spec]; 
        col_names = ['& ' col_names];
    end
    
    % Writing header
    fileID = fopen(filename, 'w');
    fprintf(fileID,'\\begin{table}[H]\n');
    fprintf(fileID,'\\centering\n');
    fprintf(fileID, '\\begin{tabular}{%s}\n', col_spec);
    fprintf(fileID, '\\hline\hline \n');
    fprintf(fileID, '%s \\\\ \n', col_names);
    fprintf(fileID, '\\hline \n');
    
    % Writing the data
    try
        for row = 1:size(T,1)
            temp{1,n_col} = [];
            for col = 1:n_col
                value = T{row,col};
                if isstruct(value), error('Table must not contain structs.'); end
                while iscell(value), value = value{1,1}; end
                if isinf(value), value = '$\infty$'; end
                temp{1,col} = num2str(value);
            end
            if ~isempty(row_names)
                temp = [row_names{row}, temp];
            end
            fprintf(fileID, '%s \\\\ \n', strjoin(temp, ' & '));
            clear temp;
        end
    catch
        error('Unknown error. Make sure that table only contains chars, strings or numeric values.');
    end
    
    % Constructing Caption
    strFile = string(filename(1:end-4));
    
    % Signal Name
    if contains(strFile,'MA')
        signName = 'Moving Average Cross-over';
    elseif contains(strFile,'MOM')
        if contains(strFile,'JUMP')
            signName = 'Momentum Jump';
        elseif contains(strFile, '90')
            signName = 'Momentum 90 days';
        elseif contains(strFile, '252')
            signName = 'Momentum 252 days';
        else   
            signName = 'undefined signal';
        end
    elseif contains(strFile,'MBBS')
        signName = 'EWMA Crossover';
    elseif contains(strFile, 'SVM')
        signName = 'Support Vector Machine';
    elseif contains(strFile, 'SSA')
        signName = 'Singular Sprectal Analysis';
    else 
        signName = 'OTHER TYPE OF TABLES:TO CHANGE !!! ';
    end
    
    % Type of table name
    if contains(strFile, 'AFACTOR')
        tableName = 'Correlation analysis with major indices of';
    elseif contains(strFile, 'FACTOR')
        tableName = 'Factor Analysis of';
    elseif contains(strFile, 'CORR')
        tableName = 'Correlation study of';
    else
        tableName = 'Descriptive Statistics of';
    end
    
    % Weighting Scheme Name
        if contains(strFile, 'Risk') || contains(strFile, 'RP') || contains(strFile,'RISK')
        weightName = 'risk parity';
    elseif contains(strFile, 'EW')
        weightName = 'equally weighted';
    elseif contains(strFile, 'VP')
        weightName = 'volatility parity';
    else
        weightName = 'volatility parity';
        end
    
    captionName = append('\\caption{',tableName, ' the ', signName, ' signal with a ',...
        weightName, ' weighting scheme.}\n');
    % Closing the file
    fprintf(fileID, '\\hline\n');
    fprintf(fileID, '\\end{tabular}\n');
    fprintf(fileID, captionName);
    fprintf(fileID, '\\label{%s}\n', filename(15:end-4));
    fprintf(fileID, '\\end{table}');
    fclose(fileID);
end