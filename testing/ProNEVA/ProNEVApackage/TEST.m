%--------------------------------------------------------------------------
%                   MANN KENDALL AND WHITE TEST
%--------------------------------------------------------------------------

function [ TST ] = TEST( X, Y, RUNspec )

alpha = 0.05;
     
% Mann Kendall Trend Test
if strcmp(RUNspec.DISTR.Model, 'NonStat')
    if strcmp(RUNspec.COV.Type, 'Time')        
        [ H , p_value ] = Mann_Kendall( Y, alpha );
            else
        [ H , p_value ] = HypSLOPE( X, Y, alpha );
    end
else
    [ H , p_value ] = Mann_Kendall( Y, alpha );
end

TST.MK.H        = H;
TST.MK.p_value  = p_value;

% White Test       
[ H , p_value ] = WHITEtest(X, Y, alpha);

TST.WT.H        = H;
TST.WT.p_value  = p_value; 
        

end


%% ---------------------- MANN KENDALL MONOTONIC TREND --------------------
% MK test:
% H0 = no monotonic trend
% ref [1]: Mann, H. (1945). Nonparametric Tests Against Trend. Econometrica, 
% 13(3), 245-259. doi:10.2307/1907187
% ref [2]: http://vsp.pnnl.gov/help/Vsample/Design_Trend_Mann_Kendall.htm
%--------------------------------------------------------------------------

function [ H , p_value ] = Mann_Kendall( V, alpha )

% H: test result
%   H = 1 : H0 rejected
%	H = 0 : H0 not rejected

% V : vector of observations
% alpha: Level of Significance for the trend test

V     = reshape( V , length(V) , 1 );       % Vector of Observations
alpha = alpha/2;                            % Level of Significance
n     = length(V);                          % Number of Observations      
S     = 0;                                  % Initializing Statistics  

% Compute S: positive differences minus the number of negative difference
% S = sum_i (sum_j ( sign( Xi - Xj ) ) ); 
for i = 1 : n - 1
   for j = i + 1 : n 
      S= S + sign(V(j)-V(i)); 
   end
end

VarS = (n*(n-1)*(2*n+5))/18;                % Variance of S 
StdS = sqrt(VarS);                          % Standard Deviation of S

% Compute Z based on S
% Z ~ N( 0, 1 )
if S >= 0
   Z = ( ( S-1 ) / StdS )*(S~=0);           
else
   Z = ( S+1 ) / StdS;
end

p_value = 2*( 1 - normcdf( abs(Z),0,1 ) );  % Two-tailed test     

Za = norminv( 1-alpha ,0 , 1 );             % Threshold   
H  = abs( Z ) > Za;                         % Result Test Statistic  
end

%% ----------------------------- WHITE TEST -------------------------------
% y = ax + b + e

% [ http://medovikov.me/examples/MATLAB-Diagnostic-Testing-Example.html ]

% White, H. (1980). A heteroskedasticity-consistent covariance matrix
% estimator and a direct test for heteroskedasticity. Econometrica: Journal
% of the Econometric Society, 48(4), 817â€“838.

% Engle, R. "Autoregressive Conditional Heteroscedasticity with Estimates
% of the Variance of United Kingdom Inflation. Econometrica. Vol. 96, 1988,
% pp. 893-920.

% Durbin, J., and Watson, G., "Testing for Serial Correlation in
%  Least-Squares Regression," Biometrika, vol. 38, 1951, pp. 159 - “171.

%-------------------------------------------------------------------------
function [H, p_v] = WHITEtest(X, Y, alpha)
% Y := observations 
% X := independemt variable

% Solve: Y = BX + res

Nobs = length(Y);               % number of data
Xind = [ones(size(X,1),1) X];   % include intercept
Bhat = Xind\Y;                  % estimate of the coefficient
Ysim = Xind*Bhat;               % simulations
RES2 = (Y - Ysim).^2;           % squared residual


% Auxiliary regression : apply a quadratic regression to the square residuals
% RES2 = AXres + Eres
% Xres = [ones(size(X,1),1) X X.^2];
% Ahat = Xres\RES2;

Xres = [ones(size(X,1),1) X X.^2];
Ahat = Xres\RES2;


% Calculate R2 for the residuals
% R2 = ESSr / TSSr
TSSr = sum( ( RES2 - mean(RES2) ).^2 );             % Total sum of squares (proportional to the variance of the data):
ESSr = sum( ( Xres*Ahat - mean(RES2) ).^2 );        % Regression sum of squares, also called the explained sum of squares
R2   = ESSr/TSSr;

% White Test : LM = n*R2
% follow a CHI2, w/ dof = p - 1
% p : number of parameter for the auxiliary regression
LM  = Nobs*R2; 

% CHI test
p   = size(Xres,2);     % n. param aux regress
dof = p - 1;            % dof 

z   = chi2inv(1-alpha, dof);      % critical value
p_v = 1 - chi2cdf(LM, dof);     % p_value
H   = LM > z;                   % 1 - test rejected
end

%% ------------------- HYPOTHESIS TEST SLOPE ------------------------------
% Y = Bhat*X + A 
% H0 := Btrue = 0;
% t = ( Bhat(1) - Btrue ) / SE, t ~ t-student w/ dof = n - 2  
% x = tinv(p,nu) | p : probability, nu : degrees of freedom 
% For SE: [1] http://stattrek.com/regression/slope-test.aspx?Tutorial=AP , [2] http://www.statisticshowto.com/find-standard-error-regression-slope/
% [REF] Shumway, RH and Stoffer D.S, Time series analysis and its
% applications with R example. Springerlink 2010. pag. 50 
function [ H, p_v ] = HypSLOPE( X, Y, alpha )

Nobs  = length(Y);              % N of observations
MX    = [ X ones( Nobs,1 ) ];	% Matrix of Xs
Bhat  = MX \ Y;                 % Extimated LR coefficients
Btrue = 0;                      % True value of the slope

% SE = sqrt(sum( Yobs - Ysim )^2/(n - 2)) / sqrt(sum( xi - mean(x))^2 )
RES2 = (Y - MX*Bhat)'*(Y - MX*Bhat);         % Residuals
DEN2 = (X - mean(X))'*(X - mean(X));
SE   = sqrt(RES2/(Nobs-2))/sqrt(DEN2);       % Standard Error 
t    = (Bhat(1) - Btrue)/SE;                 % Test Statistic
dof  = Nobs - 2;                             % Degrees of freedom (Linear model)
z    = tinv( 1 - alpha, dof );               % Threshold for t - student distribution
p_v  = 1 - tcdf( t , dof );                  % p - value
H    = abs( t ) > z;                         % Test result

end








