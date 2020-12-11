% This code import the data and create the vector use in the script
%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 22);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:V5912";

% Specify column names and types
opts.VariableNames = ["Date", "CMESP500INDEXCONTINUOUSSETTPRICE", "OSXNIKKEI225INDEXCONTINUOUSSETTPRICE", "CMEEMININASDAQ100CONTINUOUSSETTPRICE", "EUREXEUROSTOXX50CONTINUOUSSETTPRICE", "EUREXSMICONTINUOUSSETTPRICE", "CMESTERLINGCOMPCONTINUOUSSETTPRICE", "CMESWISSFRANCCOMPCONTINUOUSSETTPRICE", "CMEEUROCOMPCONTINUOUSSETTPRICE", "CMEEMINIJAPANESEYENCONTINUOUSSETTPRICE", "LondonBrentCrudeOilIndexUBBLPRICEINDEX", "CSCECOCOACONTINUOUSSETTPRICE", "CBTCORNCOMPCONTINUOUSSETTPRICE", "CMXGOLD100OZCONTINUOUSSETTPRICE", "CSCESUGAR11CONTINUOUSSETTPRICE", "CBT10YRSUSTNOTECOMPCONTINUOUSSETTPRICE", "SGXDT10YRJGBCONTINUOUSSETTPRICE", "EUREXEUROBUNDCONTINUOUSSETTPRICE", "LIFFELONGGILTCONTINUOUSSETTPRICE", "MSCIWORLDUTOTRETURNIND", "MSCIEMUTOTRETURNIND", "SPGSCICommodityTotalReturnRETURNINDOFCL"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "CMEEMININASDAQ100CONTINUOUSSETTPRICE", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date", "InputFormat", "");

% Import the data
QARMDATAII = readtable("Data/QARMDATAII.xlsx", opts, "UseExcel", false);

%% Creating the vector and parameters we will use :
Names = QARMDATAII.Properties.VariableNames;
data.p = table2array(QARMDATAII(1:end,2:end-3));
data.names = Names(2:end-3);
data.date = datetime(table2array(QARMDATAII(1:end,1)));
% data.factor1.p = table2array(QARMDATAII(1:end,end-2:end));
% data.factor1.names = Names(end-2:end);
clear opts
clear QARMDATAII
clear Names

%% import factor daily 
opts = spreadsheetImportOptions("NumVariables", 8);

% Specify sheet and range
opts.Sheet = "Feuil1";
opts.DataRange = "A2:H5702";

% Specify column names and types
opts.VariableNames = ["VarName1", "MktRF", "SMB", "HML", "RMW", "CMA", "Mom", "RF"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "VarName1", "InputFormat", "");

% Import the data
daillff = readtable("Data/daillff2.xlsx", opts, "UseExcel", false);

Names = daillff.Properties.VariableNames;
data.fffactor.daily = table2array(daillff(:,2:end-1))./100;
data.fffactor.names = Names(2:end-1);
data.fffactor.date = datetime(table2array(daillff(1:end,1)));
data.rf.daily = table2array(daillff(:,end))./(100.*252);
clear daillff
clear Names

%%
%% adjust daily price to fama french
opts = spreadsheetImportOptions("NumVariables", 1);

% Specify sheet and range
opts.Sheet = "Feuil1";
opts.DataRange = "K11:K5933";

% Specify column names and types
opts.VariableNames = "VarName11";
opts.VariableTypes = "datetime";

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";

% Specify variable properties
opts = setvaropts(opts, "VarName11", "InputFormat", "");

% Import the data
daillff1 = readtable("Data/daillff.xlsx", opts, "UseExcel", false);

datetodelete = table2array(daillff1);
toDelete = datenum(datetodelete);
numdate = datenum(data.date);
idx=zeros(209,1);

for i=1:length(toDelete)
    idx(i,1) = find(numdate(:)==toDelete(i)==1);
end

data.p(idx,:) = [];
data.date(idx) = [];

clear toDelete
clear daillff1
clear datetodelete
clear i
clear idx
clear numdate
clear opts

%% fama french monthly 
% Specify sheet and range
opts = spreadsheetImportOptions("NumVariables", 8);

opts.Sheet = "Feuil1";
opts.DataRange = "A2:H358";

% Specify column names and types
opts.VariableNames = ["VarName1", "MktRF", "SMB", "HML", "RMW", "CMA", "Mom", "RF"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "VarName1", "InputFormat", "");

% Import the data
monthlyff = readtable("Data/monthlyFF2.xlsx", opts, "UseExcel", false);
data.fffactor.monthly = table2array(monthlyff(:,2:end-1))./100;
data.fffactor.monthlydate = datetime(table2array(monthlyff(1:end,1)));
data.rf.monthly = table2array(monthlyff(:,end))./1200;
%% Clear temporary variables
clear opts
clear monthlyff

%% Other factor daily and monthly 
opts = spreadsheetImportOptions("NumVariables", 6);

% Specify sheet and range
opts.Sheet = "Daily";
opts.DataRange = "A2:F5654";

% Specify column names and types
opts.VariableNames = ["Date", "SPGSCICommodityTotalReturnRETURNINDOFCL", "MSCIWORLDUPRICEINDEX", "MSCIEMUPRICEINDEX", "USDOLLARINDEXCLOSETRADEWEIGHTED", "WDFTSEWGBIWORLDTOTALRETURNU"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "Date", "InputFormat", "");

% Import the data
FactorAnalysis2 = readtable("Data/FactorAnalysis2.xlsx", opts, "UseExcel", false);

Names = FactorAnalysis2.Properties.VariableNames;
data.AF.daily.p = table2array(FactorAnalysis2(1:end,2:end));
data.AF.names = Names(2:end);
data.AF.daily.date = datetime(table2array(FactorAnalysis2(2:end,1)));
clear opts
clear FactorAnalysis2
clear Names
clear opts

data.AF.daily.r = data.AF.daily.p(2:end,:)./data.AF.daily.p(1:end-1,:)-1;
%% Monthly
opts = spreadsheetImportOptions("NumVariables", 6);

% Specify sheet and range
opts.Sheet = "Monthly";
opts.DataRange = "A2:F359";

% Specify column names and types
opts.VariableNames = ["Date", "SPGSCICommodityTotalReturnRETURNINDOFCL", "MSCIWORLDUPRICEINDEX", "MSCIEMUPRICEINDEX", "USDOLLARINDEXCLOSETRADEWEIGHTED", "WDFTSEWGBIWORLDTOTALRETURNU"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "Date", "InputFormat", "");

% Import the data
FactorAnalysis2S1 = readtable("Data/FactorAnalysis2.xlsx", opts, "UseExcel", false);

data.AF.monthly.p = table2array(FactorAnalysis2S1(1:end,2:end));
data.AF.monthly.date = datetime(table2array(FactorAnalysis2S1(1:end,1)));
clear opts
clear FactorAnalysis2S1
clear opts

data.AF.monthly.r = data.AF.monthly.p(2:end,:)./data.AF.monthly.p(1:end-1,:)-1;

disp('####################################################################');
disp('------------------ Importing the Data is Done ! --------------------');
disp('####################################################################');