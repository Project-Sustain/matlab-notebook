% ----------------------------------------------------------------------- %
%                                                                         %
%                                ProNEVA                                  %
%                                                                         %
% ----------------------------------------------------------------------- %
% Based on Ragno et al. "A Generalized Framework for Process-based 
% Nonstationary Extreme Value Analysis" [in prep.]

%----------------------------------------------------------------------
% READ DATA
%----------------------------------------------------------------------
file01 = fopen('US_Temp.txt');
text1  = textscan(file01, '%f');
fclose(file01);
OBS = text1{1}(:);
% Total Number of Observations
RUNspec.Nobs = length(OBS);   
%--------------------------------------------------------------------------
% DISTRIBUTION TYPE: GEV/GP
% -------------------------------------------------------------------------
% RUNspec.DISTR.Type
% (1) RUNspec.DISTR.Type = 'GEV'     Generalized Extreme Value Distribution
% (2) RUNspec.DISTR.Type = 'GP'      Generalized Pareto Distribution
% (3) RUNspec.DISTR.Type = 'P3'      Pearson Typer III
RUNspec.DISTR.Type  = 'GEV';

%----------------------------------------------------------------------
% STATISTICAL MODEL - STATIONARY/NON STATIONARY
%----------------------------------------------------------------------
% RUNspec.DISTR.Model
% (1) 'Stat' 
% (2) 'NonStat'
RUNspec.DISTR.Model = 'NonStat';

%--------------------------------------------------------------------------
% COVARIATE: TIME/USER DEFINED
%--------------------------------------------------------------------------
% RUNspec.COVtype: 
% (1) RUNspec.COV.type = 'Time'     
% (2) RUNspec.COV.type = 'User' 
if strcmp(RUNspec.DISTR.Model, 'NonStat' )
    RUNspec.COV.type = 'Time';
end


%--------------------------------------------------------------------------
% PARAMETERS ESTIMATION - BAYES & MCMC
%-------------------------------------------------------------------------- 
% PRIOR
% MCMC
% DIAGNOSTICS

%--------------------------------------------------------------------------
% OPTIONAL FEATURES
%--------------------------------------------------------------------------
% TETS
% PREDICTIVE DISTRIBUTION
% PLOTS
% SAVE

 