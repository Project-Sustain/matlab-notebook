%-------------------------------------------------------------------------
%                           RUN ProNEVA w/o GUI
%-------------------------------------------------------------------------
%
%Reference Publication: Ragno E, AghaKouchak A, Cheng L, Sadegh M, 2019,
%A Generalized Framework for Process-informed Nonstationary Extreme
%Value Analysis, Advances in Water Resources, in revision.
%
% ProNEVA MATLAB code is developed by Elisa Ragno University of California, Irvine
%
% For questions and permissions, please contact Amir AghaKouchak
% (amir.a@uci.edu) or Elisa Ragno (E.Ragno@tudelft.nl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Disclaimer:} The Process-informed Nonstationary Extreme Value Analysis
%(ProNEVA) software package is provided `as is' without any endorsement
%made and without warranty of any kind, either express or implied. While
%we strive to ensure that ProNEVA is accurate, no guarantees for the
%accuracy of the codes, output information and figures are made. ProNEVA
%codes and outputs can only be used at your own discretion and risk and
%with agreement that you will be solely responsible for any damage and that
%the authors and their affiliate institutions accept no responsibility for errors or omissions
%in ProNEVA codes, outputs, figures, and documentation. In no event shall
%the authors, developers or their affiliate institutions be liable to you
%or any third parties for any special, direct, indirect or consequential
%damages and financial risks of any kind, or any damages whatsoever,
%resulting from, arising out of or in connection with the use of ProNEVA.
%The user of ProNEVA agrees that the codes and algorithms are subject to
%change without notice.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Erease previous messages
clc;

% DO NOT EDIT
currentDIR = pwd();                     % Current Directory     
cd('ProNEVApackage');                   % Open Folder w/ ProNEVA Source codes
save('currentDIR.mat', 'currentDIR')    % Save Original Directory 

%% (1) EDIT - LOAD DATA
%fileOBS = fopen('C:\Users\Elisa Ragno\Desktop\data\FersonQmax1980_2010.txt'); %You can use full path 
fileOBS = fopen('../US_Temp.txt');
% DO NOT EDIT 
textOBS  = textscan(fileOBS, '%f');
fclose(fileOBS);
OBS = textOBS{1}(:);

%% (2) EDIT - DISTRIBUTION TYPE
% RUNspec.DISTR.Type
% (i)   RUNspec.DISTR.Type = 'GEV'     Generalized Extreme Value Distribution
% (ii)  RUNspec.DISTR.Type = 'GP'      Generalized Pareto Distribution
% (iii) RUNspec.DISTR.Type = 'P3'      Pearson Typer III

RUNspec.DISTR.Type = 'GEV';

%% (3) EDIT - MODEL TYPE
% 'Stat'    : Stationary Analysis
% 'NonStat' : Nonstationary Analysis

RUNspec.DISTR.Model = 'NonStat';

if strcmp(RUNspec.DISTR.Model, 'NonStat')
    
    %% EDIT - COVARIATE TYPE
    % RUNspec.COVtype: 
    % (i)  RUNspec.COV.type = 'Time'     
    % (ii) RUNspec.COV.type = 'User' 
    RUNspec.COV.Type = 'Time';
    
    if strcmp(RUNspec.COV.Type, 'User')
        
        %% EDIT - SELECT FILE COVARIATE
        fileCOV = fopen('C:\Users\Elisa Ragno\Desktop\data\US_CO2_covariate_for_US_Temp.txt');
        % DO NOT EDIT 
        textCOV  = textscan(fileCOV, '%f');
        fclose(fileCOV);
        RUNspec.COV.X = textCOV{1}(:);
    end
end

%--------------------------------------------------------------------------
%
%% (4)       UNCOMMENT and EDIT if RUNspec.DISTR.Type = 'GEV'  
%
%--------------------------------------------------------------------------

%% Edit PRIOR
% (i)   'Uniform': parm1 = min   | parm2 = max
% (ii)  'Normal' : parm1 = mean  | parm2 = std
% (iii) 'Gamma'  : parm1 = shape | parm2 = scale

% Location - MU: 
RUNspec.PRIOR.MUdistr = 'Normal'; 
RUNspec.PRIOR.MUparm1 = mean(OBS);
RUNspec.PRIOR.MUparm2 = std(OBS);

% Scale - SI:
RUNspec.PRIOR.SIdistr = 'Normal';  
RUNspec.PRIOR.SIparm1 = 0;
RUNspec.PRIOR.SIparm2 = 5;

% Shape - XI:
RUNspec.PRIOR.XIdistr = 'Normal'; 
RUNspec.PRIOR.XIparm1 = 0; 
RUNspec.PRIOR.XIparm2 = 0.2;

% DO NOT EDIT
if strcmp(RUNspec.DISTR.Model, 'Stat')
    
    RUNspec.NS.MU = 'none';
    RUNspec.NS.SI = 'none';
    RUNspec.NS.XI = 'none';
else
    %% EDIT TREND  'NonStat' case
    % TREND LOCATION
    % 'none' | 'Linear' | 'Quadratic' | 'Exponential'
    RUNspec.NS.MU = 'Linear';
    % TREND SCALE
    % 'none' | 'Linear' | 'Quadratic'  
    RUNspec.NS.SI = 'none';
    % TREND SHAPE
    % 'none' | 'Linear' 
    RUNspec.NS.XI = 'none';

end


%--------------------------------------------------------------------------
%
%% (4)        UNCOMMENT AND EDIT if RUNspec.DISTR.Type = 'GP'  
%
%--------------------------------------------------------------------------
% %% EDIT GP THRESHOLD
% % RUNspec.THtype: (i) 'Const' | (ii) 'QR' - Quantile Regression
% RUNspec.THtype = 'Const';
% % RUNspec.THp: p-quantile for threshold definition [0 1]
% RUNspec.THp    = 0.98;
% % RUNspec.NobsY: Observations in a year
% RUNspec.NobsY  = 1;
% 
% %% EDIT PRIOR
% % (i)   'Uniform': parm1 = min   | parm2 = max
% % (ii)  'Normal' : parm1 = mean  | parm2 = std
% % (iii) 'Gamma'  : parm1 = shape | parm2 = scale
% 
% % Scale
% RUNspec.PRIOR.SIdistr = 'Normal';
% RUNspec.PRIOR.SIparm1 = 0;
% RUNspec.PRIOR.SIparm2 = 10;
% 
% % Shape
% RUNspec.PRIOR.XIdistr = 'Normal'; 
% RUNspec.PRIOR.XIparm1 = 0; 
% RUNspec.PRIOR.XIparm2 = 0.2; 
% 
% % DO NOT EDIT
% if strcmp(RUNspec.DISTR.Model, 'Stat')
%     
%     RUNspec.NS.MU = 'none';
%     RUNspec.NS.SI = 'none';
%     RUNspec.NS.XI = 'none';
% else
%     %% EDIT TREND  'NonStat' case
%     % TREND SCALE
%     % 'none' | 'Linear' | 'Quadratic'  
%     RUNspec.NS.SI = 'Linear';
%     % TREND SHAPE
%     % 'none' | 'Linear' 
%     RUNspec.NS.XI = 'none';
% 
% end


%--------------------------------------------------------------------------
%                      
%% (4)         UNCOMMENT and EDIT if RUNspec.DISTR.Type = 'P3'  
%
%--------------------------------------------------------------------------

%% Edit PRIOR
% (i)   'Uniform': parm1 = min   | parm2 = max
% (ii)  'Normal' : parm1 = mean  | parm2 = std
% (iii) 'Gamma'  : parm1 = shape | parm2 = scale

% % Location - MEAN: 
% RUNspec.PRIOR.MUdistr = 'Normal'; 
% RUNspec.PRIOR.MUparm1 = mean(OBS);
% RUNspec.PRIOR.MUparm2 = std(OBS);
% 
% % Scale - STANDARD DEVIATION:
% RUNspec.PRIOR.SIdistr = 'Normal';  
% RUNspec.PRIOR.SIparm1 = 0;
% RUNspec.PRIOR.SIparm2 = 10;
% 
% % Shape - SKWENESS:
% RUNspec.PRIOR.XIdistr = 'Normal'; 
% RUNspec.PRIOR.XIparm1 = 0; 
% RUNspec.PRIOR.XIparm2 = 0.2;
% 
% % DO NOT EDIT
% if strcmp(RUNspec.DISTR.Model, 'Stat')
%     
%     RUNspec.NS.MU = 'none';
%     RUNspec.NS.SI = 'none';
%     RUNspec.NS.XI = 'none';
% else
%     %% EDIT TREND  'NonStat' case
%     % TREND LOCATION
%     % 'none' | 'Linear' | 'Quadratic' | 'Exponential'
%     RUNspec.NS.MU = 'Linear';
%     % TREND SCALE
%     % 'none' | 'Linear' | 'Quadratic'  
%     RUNspec.NS.SI = 'none';
%     % TREND SHAPE
%     % 'none' | 'Linear' 
%     RUNspec.NS.XI = 'none';
% 
% end

%% (5) EDIT - MCMC AND EXTRA OPTIONS

% MCMC
% Number of Chains
RUNspec.Nchain  = 4;
% Number of Iterations
RUNspec.maxIT   = 10000;
% Burn-in period
RUNspec.brn     = 9000;
% Return Period
RUNspec.RP      = 100;

% Extra Options 
% 'Y': Yes - 'N': No
% Save Results? 'Y' /'N'
EXTRAS.saveRES  = 'Y';
% Run Mann-Kendall and White Tests? 'Y'/'N'
EXTRAS.RunTests = 'Y';
% Plot Return Level? 'Y'/'N'
EXTRAS.PlotRL   = 'Y';

% Save user Inputs
save('USER_INPUT.mat', 'OBS','RUNspec', 'EXTRAS');

%% (6) RUN ProNEVA
ProNEVA(OBS, RUNspec, EXTRAS)           


