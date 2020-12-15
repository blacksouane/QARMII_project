%% MODEL 1

% *************************** MOMEMTUM 252 DAYS **************************
table2latex(MOM252VP.Stats, 'Output/Tables/MOM252VP.tex');
table2latex(MOM252VP.FACTOR, 'Output/Tables/MOM252VP_FACTOR.tex');
table2latex(MOM252VP.AFACTOR, 'Output/Tables/MOM252VP_AFACTOR.tex');
table2latex(MOM252EW.Stats, 'Output/Tables/MOM252EW.tex');
table2latex(MOM252EW.FACTOR, 'Output/Tables/MOM252EW_FACTOR.tex');
table2latex(MOM252EW.AFACTOR, 'Output/Tables/MOM252EW_AFACTOR.tex');
table2latex(MOM252RP.Stats, 'Output/Tables/MOM252RP.tex');
table2latex(MOM252RP.FACTOR, 'Output/Tables/MOM252RP_FACTOR.tex');
table2latex(MOM252RP.AFACTOR, 'Output/Tables/MOM252RP_AFACTOR.tex');
table2latex(MOM252RP.CorrelationAnalysis.CORR, 'Output/Tables/MOM252RP_CORR.tex');

% *************************** MOMEMTUM 90 DAYS **************************
table2latex(MOM90VP.Stats, 'Output/Tables/MOM90VP.tex');
table2latex(MOM90VP.FACTOR, 'Output/Tables/MOM90VP_FACTOR.tex');
table2latex(MOM90VP.AFACTOR, 'Output/Tables/MOM90VP_AFACTOR.tex');
table2latex(MOM90EW.Stats, 'Output/Tables/MOM90EW.tex');
table2latex(MOM90EW.FACTOR, 'Output/Tables/MOM90EW_FACTOR.tex');
table2latex(MOM90EW.AFACTOR, 'Output/Tables/MOM90EW_AFACTOR.tex');
table2latex(MOM90RP.Stats, 'Output/Tables/MOM90RP.tex');
table2latex(MOM90RP.FACTOR, 'Output/Tables/MOM90RP_FACTOR.tex');
table2latex(MOM90RP.AFACTOR, 'Output/Tables/MOM90RP_AFACTOR.tex');
table2latex(MOM90RP.CorrelationAnalysis.CORR, 'Output/Tables/MOM90RP_CORR.tex');

% *************************** MOMEMTUM jump 90 DAYS **************************
table2latex(MOMJUMPVP.Stats, 'Output/Tables/MOMJUMPVP.tex');
table2latex(MOMJUMPVP.FACTOR, 'Output/Tables/MOMJUMPVP_FACTOR.tex');
table2latex(MOMJUMPVP.AFACTOR, 'Output/Tables/MOMJUMPVP_AFACTOR.tex');
table2latex(MOMJUMPEW.Stats, 'Output/Tables/MOMJUMPEW.tex');
table2latex(MOMJUMPEW.FACTOR, 'Output/Tables/MOMJUMPEW_FACTOR.tex');
table2latex(MOMJUMPEW.AFACTOR, 'Output/Tables/MOMJUMPEW_AFACTOR.tex');
table2latex(MOMJUMPRP.Stats, 'Output/Tables/MOMJUMPRP.tex');
table2latex(MOMJUMPRP.FACTOR, 'Output/Tables/MOMJUMPRP_FACTOR.tex');
table2latex(MOMJUMPRP.AFACTOR, 'Output/Tables/MOMJUMPRP_AFACTOR.tex');
table2latex(MOMJUMPRP.CorrelationAnalysis.CORR, 'Output/Tables/MOMJUMPRP_CORR.tex');

% *************************** Moving Average ***************************
table2latex(MAVP.Stats, 'Output/Tables/MAVP.tex');
table2latex(MAVP.FACTOR, 'Output/Tables/MAVP_FACTOR.tex');
table2latex(MAVP.AFACTOR, 'Output/Tables/MAVP_AFACTOR.tex');
table2latex(MAEW.Stats, 'Output/Tables/MAEW.tex');
table2latex(MAEW.FACTOR, 'Output/Tables/MAEW_FACTOR.tex');
table2latex(MAEW.AFACTOR, 'Output/Tables/MAEW_AFACTOR.tex');
table2latex(MARP.Stats, 'Output/Tables/MARP.tex');
table2latex(MARP.FACTOR, 'Output/Tables/MARP_FACTOR.tex');
table2latex(MARP.AFACTOR, 'Output/Tables/MARP_AFACTOR.tex');
table2latex(MARP.CorrelationAnalysis.CORR, 'Output/Tables/MARP_CORR.tex');

% *************************** All Models  *************************** 
table2latex(rows2vars(Model1_stats), 'Output/Tables/model1.tex');

%% MBBS MODEL

% *************************** Training  *************************** 
% table2latex(MBBS.Stats, 'Output/Tables/MBBS.tex')
% table2latex(MBBS.FACTOR, 'Output/Tables/MBBS_FACTOR.tex');
% table2latex(MBBS.AFACTOR, 'Output/Tables/MBBS_AFACTOR.tex');

% *************************** MBBSVPNR  *************************** 
table2latex(MBBSVPNR.Stats, 'Output/Tables/MBBSVPNR.tex')
table2latex(MBBSVPNR.FACTOR, 'Output/Tables/MBBSVPNR_FACTOR.tex');
table2latex(MBBSVPNR.AFACTOR, 'Output/Tables/MBBSVPNR_AFACTOR.tex');
table2latex(MBBSVPNR.CorrelationAnalysis.CORR, 'Output/Tables/MBBSVPNR_CORR.tex');
%{
% *************************** GARCH  *************************** 
table2latex(MBBS3.Stats, 'Output/Tables/MBBS3.tex')
table2latex(MBBS3.FACTOR, 'Output/Tables/MBBS3_FACTOR.tex');
table2latex(MBBS3.AFACTOR, 'Output/Tables/MBBS3_AFACTOR.tex');
%}

% *************************** MBBSRPNR  *************************** 
table2latex(MBBSRPNR.Stats, 'Output/Tables/MBBSRPNR.tex')
table2latex(MBBSRPNR.FACTOR, 'Output/Tables/MBBSRPNR_FACTOR.tex');
table2latex(MBBSRPNR.AFACTOR, 'Output/Tables/MBBSRPNR_AFACTOR.tex');
table2latex(MBBSRPNR.CorrelationAnalysis.CORR, 'Output/Tables/MBBSRPNR_CORR.tex');


% *************************** MBBSEWNR *************************** 
table2latex(MBBSEWNR.Stats, 'Output/Tables/MBBSEWNR.tex')
table2latex(MBBSEWNR.FACTOR, 'Output/Tables/MBBSEWNR_FACTOR.tex');
table2latex(MBBSEWNR.AFACTOR, 'Output/Tables/MBBSEWNR_AFACTOR.tex');
table2latex(MBBSEWNR.CorrelationAnalysis.CORR, 'Output/Tables/MBBSEWNR_CORR.tex');

% *************************** MBBSVPOQ  *************************** 
table2latex(MBBSVPOQ.Stats, 'Output/Tables/MBBSVPOQ.tex')
table2latex(MBBSVPOQ.FACTOR, 'Output/Tables/MBBSVPOQ_FACTOR.tex');
table2latex(MBBSVPOQ.AFACTOR, 'Output/Tables/MBBSVPOQ_AFACTOR.tex');
table2latex(MBBSVPOQ.CorrelationAnalysis.CORR, 'Output/Tables/MBBSVPOQ_CORR.tex');

% *************************** MBBSRPOQ  *************************** 
table2latex(MBBSRPOQ.Stats, 'Output/Tables/MBBSRPOQ.tex')
table2latex(MBBSRPOQ.FACTOR, 'Output/Tables/MBBSRPOQ_FACTOR.tex');
table2latex(MBBSRPOQ.AFACTOR, 'Output/Tables/MBBSRPOQ_AFACTOR.tex');
table2latex(MBBSRPOQ.CorrelationAnalysis.CORR, 'Output/Tables/MBBSRPOQ_CORR.tex');


% *************************** MBBSEWOQ *************************** 
table2latex(MBBSEWOQ.Stats, 'Output/Tables/MBBSEWOQ.tex')
table2latex(MBBSEWOQ.FACTOR, 'Output/Tables/MBBSEWOQ_FACTOR.tex');
table2latex(MBBSEWOQ.AFACTOR, 'Output/Tables/MBBSEWOQ_AFACTOR.tex');
table2latex(MBBSEWOQ.CorrelationAnalysis.CORR, 'Output/Tables/MBBSEWOQ_CORR.tex');

% *************************** MBBS *************************** 
table2latex(rows2vars(MBBS_stats), 'Output/Tables/MBBS_stats.tex');
table2latex(MBBS_corrregime,  'Output/Tables/MBBS_corrregime.tex');

%% SSA

% *************************** SSA - Volatility Parity *************************** 
table2latex(SSA.Stats, 'Output/Tables/SSA.tex')
table2latex(SSA.FACTOR, 'Output/Tables/SSA_FACTOR.tex');
table2latex(SSA.AFACTOR, 'Output/Tables/SSA_AFACTOR.tex');
table2latex(SSA.CorrelationAnalysis.CORR, 'Output/Tables/SSA_CORR.tex');

% *************************** SSA - Vol with quantity trend  *************************** 
table2latex(SSA_RP.Stats, 'Output/Tables/SSA_RP.tex')
table2latex(SSA_RP.FACTOR, 'Output/Tables/SSA_RP_FACTOR.tex');
table2latex(SSA_RP.AFACTOR, 'Output/Tables/SSA_RP_AFACTOR.tex');
table2latex(SSA_RP.CorrelationAnalysis.CORR, 'Output/Tables/SSA_RP_CORR.tex');


% *************************** SSA - Vol with individual quantity trend  ******************
table2latex(SSA_EW.Stats, 'Output/Tables/SSA_EW.tex')
table2latex(SSA_EW.FACTOR, 'Output/Tables/SSA_EW_FACTOR.tex');
table2latex(SSA_EW.AFACTOR, 'Output/Tables/SSA_EW_AFACTOR.tex');
table2latex(SSA_RP.CorrelationAnalysis.CORR, 'Output/Tables/SSA_EW_CORR.tex');

% *************************** SSA - Summary table ******************************
table2latex(rows2vars(SSA_stats), 'Output/Tables/SSA_stats.tex');

%% Support Vector Machine

% *************************** SVM - Volatility Parity *********************
table2latex(SVM_MODEL.Stats, 'Output/Tables/SVM_MODEL.tex')
table2latex(SVM_MODEL.FACTOR, 'Output/Tables/SVM_MODEL_FACTOR.tex');
table2latex(SVM_MODEL.AFACTOR, 'Output/Tables/SVM_MODEL_AFACTOR.tex');
table2latex(SVM_MODEL.CorrelationAnalysis.CORR, 'Output/Tables/SVM_VP_CORR.tex');

% *************************** SVM - Risk Parity  *************************** 
table2latex(SVM_MODEL_Risk.Stats, 'Output/Tables/SVM_MODEL_Risk.tex')
table2latex(SVM_MODEL_Risk.FACTOR, 'Output/Tables/SVM_MODEL_Risk_FACTOR.tex');
table2latex(SVM_MODEL_Risk.AFACTOR, 'Output/Tables/SVM_MODEL_Risk_AFACTOR.tex');
table2latex(SVM_MODEL_Risk.CorrelationAnalysis.CORR, 'Output/Tables/SVM_RP_CORR.tex');


% *************************** SVM - EW  *************************** 
table2latex(SVM_MODEL_EW.Stats, 'Output/Tables/SVM_MODEL_EW.tex')
table2latex(SVM_MODEL_EW.FACTOR, 'Output/Tables/SVM_MODEL_EW_FACTOR.tex');
table2latex(SVM_MODEL_EW.AFACTOR, 'Output/Tables/SVM_MODEL_EW_AFACTOR.tex');
table2latex(SVM_MODEL_EW.CorrelationAnalysis.CORR, 'Output/Tables/SVM_EW_CORR.tex');


% *************************** SVM - Summary table ******************************
table2latex(rows2vars(SVM_stats), 'Output/Tables/SVM_stats.tex');