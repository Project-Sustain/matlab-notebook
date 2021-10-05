%--------------------------------------------------------------------------
% MODEL DIAGNOSTIC
% References
% [1] Coles 2001 - "An introduction to statistical Modeling of Extreme Values" pag 110 
% [2] Katz 2013 -  "Extreme in a Changing Climate" Ch.2 - pag 24
% [3] Koutrouvelis 1991 - " Estimation in Pearson Type 3 distribution "
%--------------------------------------------------------------------------

function [OUT, DGN] = DIAGNOSTIC(OBS, OUT, RUNspec)

% OBS: observations
% OUT: parameter estimates

% Note: diagnostic done considering the set of parameter with the maximum
% value of posterior distribution 

D   = RUNspec.Dim;                  % Problem Dimension
L   = length(OBS);                  % Number of observations
CH  = OUT.CH( :, 1:D);              % Sets of Parameter
LK  = OUT.CH( :, end - 1);          % Log - likelihood
PST = OUT.CH( :, end);              % Log - Posterior

[ idxMAX, ~ ] = find( PST == max( PST ), 1, 'last');    % Location Maximum LogPosterior
theta         = CH( idxMAX, :);                         % Parameters Max LP
%--------------------------------------------------------------------------
% DIAGNOSTIC #1 - QUANTILE AND PROBABILITY PLOT
%--------------------------------------------------------------------------

switch RUNspec.DISTR.Type

    %----------------------------- GEV and P3 ----------------------------- 
    case { 'GEV', 'P3' } 
       
        %--------------------- Define vectors mu, si, xi ------------------
        switch RUNspec.DISTR.Model
            
            case 'Stat'  
                
                mu = repmat( theta( 3 ), L, 1 );
                si = repmat( exp( theta( 2 ) ), L, 1 );
                xi = repmat( theta( 1 ), L, 1 );
                
                checkQP = 'Y';      % Index for P3 Quantile and Probability Plot
            
            case 'NonStat'
                
                t   = RUNspec.COV.X;                % Covariate
               
                checkQP = 'Y';       % Index for P3 Quantile and Probability Plot

                idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;     % First Column containing MU's Coefficients
                idxS = RUNspec.NS.CoeffXI;                          % First Column containing SI's Coefficients
                
                %------------------ MU - Location / Mean ------------------
                switch RUNspec.NS.MU

                    case 'none'
                        mu = repmat( theta(idxM + 1 ), L, 1 );
                    case 'Linear'
                        mu = theta( idxM + 2 ).*t + theta( idxM + 1 );
                    case 'Quadratic'
                        mu = theta( idxM + 3 ).*t.^2 + theta( idxM + 2 ).*t + theta( idxM + 1 );
                    case 'Exponential'
                        mu = theta( idxM + 1 ).*exp( theta( idxM + 2 ).*t );
                end

                %------------------ SI - Scale / Std ----------------------        
                switch RUNspec.NS.SI 
                    case 'none'
                        si = exp( repmat( theta( idxS + 1 ), L, 1 ) );
                    case 'Linear'
                        si = exp( theta( idxS + 2 ).*t + theta( idxS + 1 ) );
                    case 'Quadratic'
                        si = exp( theta( idxS + 3).*t.^2 + theta( idxS + 2).*t + theta( idxS + 1) );
                end

                %------------------ XI - Shape / Skewness -----------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi = repmat( theta( 1 ), L, 1 );
                    case 'Linear'
                        xi = theta( 2 ).*t + theta( 1 ) ;
                        % Index for P3 Quantile and Probability Plot
                        % if checkQP = 'N' the check cannot be performed
                        checkQP = 'N';
                end
        end
       
        %------------------ (1) GEV  - Gumbel Transformation --------------
        % Gumbel Transformed Z: Z = 1/xi(t) * log( 1 + xi(t)*(X - mu(t))/si(t) )
        % PROBABILITY PLOT - ref:[1]
        % Plot Pairs: [ i/(n+1), exp(-exp(- Z(i))) ], where Z(1) > Z(2) > ... > Z(n)
        % QUANTILE PLOT - ref: [1] 
        % Plot Pairs: [ Z(i), - log( - log( i/(n+1))) ], where Z(1) > Z(2) > ... > Z(n)

        if strcmp( RUNspec.DISTR.Type , 'GEV') 
            
            FZ = @(X, xi, si, mu) (1./xi).*(log( 1 +  xi.*(X - mu)./si) );      
            
            Z = FZ( OBS, xi, si, mu );      % Transformed Observations Standard Gumbel
            OUT.Z = Z;                      % Save Transformed Observations

            [~, iZ] = sort(Z);              
            EX = ( 1:L )'./( L+1 );         % Empirical Probability         
            TX = exp( -exp ( - Z(iZ)));     % Theoretical Probability

            TZ  = - log( - log ( EX ) );    % Theoretical Quantile

            RES = TZ - Z(iZ);                % RESIDUALS
	        
            % PLOT
            FIG = QQPLOT( EX, TX, TZ, Z, iZ ); 

            
        %--------- (2) LOG PEARSON TYPE III - Gamma transformation --------
        % only if skewness is constant Ref [3]
        % PROBABILITY PLOT - ref:[3]
        % Pearson Type III distribution : P3( alpha, beta, tau ) 
        % Gamma Transformed: 
        % Z = ( X - tau )/beta ~ Standard Gamma ( scale = 1, shape = alpha ) 
        % gamcdf(x,a,b) | x : obs | a = shape | b = scale
        
        elseif strcmp( checkQP ,'Y' )
            
            alpha = 4 ./ ( xi.^2 );             % Shape:    alpha = 4 / ( gammaX^2 )
            beta  = ( si .* xi )./2;            % Scale:    beta  = ( sigmaX * gammaX )/2
            tau   = mu - 2*si./xi;              % Location: tau   = muX - 2*sigmaX/gammaX
           
            FZ = @(X, beta, tau) ( X - tau )./ beta;
            
            Z  = FZ(OBS, beta, tau);            % Transformed Variables
            OUT.Z = Z;                          % Save transformed observations
            
            [~, iZ] = sort(Z);                  % Sort Z values

            EX = ( 1:L )'./( L+1 );             % Empirical Probability    
            TX = gamcdf( Z(iZ), alpha(1), 1 );	% Theoretical Probability
            TZ = gaminv( EX, alpha(1), 1 );     % Theoretical Quantile

            RES = TZ - Z(iZ);                   % RESIDUALS
            
            % PLOT
            FIG = QQPLOT( EX, TX, TZ, Z, iZ ); 
           
        end

    %--------------------------------- GP ---------------------------------

    case 'GP'
        %------------------- Define vectors  si, xi -----------------------
        switch RUNspec.DISTR.Model
            case 'Stat'
                si = repmat( exp( theta( 2 ) ), L, 1 );
                xi = repmat( theta( 1 ), L, 1 );
            
            case 'NonStat'
                
                
                t   = RUNspec.COV.X;                % Covariate
                idxS = RUNspec.NS.CoeffXI;      % First Column containing SI's Coefficients
                
                %--------------------- SI - Scale / Std -------------------        
                switch RUNspec.NS.SI 
                    case 'none'
                        si = exp( repmat( theta( idxS + 1 ), L, 1 ) );
                    case 'Linear'
                        si = exp( theta( idxS + 2 ).*t + theta( idxS + 1 ) );
                    case 'Quadratic'
                        si = exp( theta( idxS + 3).*t.^2 + theta( idxS + 2).*t + theta( idxS + 1) );
                end

                %------------------ XI - Shape / Skewness -----------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi = repmat( theta( 1 ), L, 1 );
                    case 'Linear'
                        xi = theta( 2 ).*t + theta( 1 ) ;
                end
        end
        %------------------ GP(3) Exponential Trasformation ---------------
        % [ref 1 & 2] : Z transformed value
        % Zt = 1/xi(t) * log( 1 + xi(t)*(Yt - u(t))/si(t) ), where Y = Yt - u --> excesses 
        % PROBABILITY PLOT ( ref:[1]- pag 111):
        % Plot Pairs: [ i/(n+1), 1 - exp( - Z(i) ) ], Z(1) > Z(2) > ... > Z(n)
        % QUANTILE PLOT ( ref:[1]- pag 111):
        % Plot Pairs: [ Z(i), - log( 1 - i/(n+1) ) ], Z(1) > Z(2) > ... > Z(n)
        
        FZ    = @(Y, xi, si) (1./xi).*(log( 1 +  xi.*Y./si) );  
        
        Z     = FZ(OBS, xi, si);            % Transformed Variables
        OUT.Z = Z;                          % Save Transformed Variables
        
        [ ~, iZ ] = sort( Z );              % Sort Z values
        
        EX = ( 1:L )'./( L+1 );             % Empirical Probability 
        TX = 1 - exp( - Z( iZ ) );          % Theoretical Probability
        
        TZ  = - log( 1 - EX );              % Theoretical Quantile
        
        RES = TZ - Z(iZ);                  % Residual using Theoretical Quantile 
        
        % PLOT
        FIG = QQPLOT( EX, TX, TZ, Z, iZ ); 

end

%------------------------------------------------------------------
% DIAGNOSTIC #2 - KS test using random generated test
%------------------------------------------------------------------

Nt = 1e04;      % Nt: number of repetition

% Generate and Teset Nt time series from (xi, si, mu)

for i = 1 : Nt

    switch RUNspec.DISTR.Type
        case 'GEV'
            RND = gevrnd( xi, si, mu );
        case 'GP'
            RND = gprnd( xi ,si , 0 );
        case 'P3'
            if strcmp( checkQP ,'Y' ) 
                RND = gamrnd( alpha, 1 );
            else
                RND = zeros(L,1);
            end
    end            
    % KS Test decision for H0 (Matlab Documentation), H = 1 test rejects H0 at the 5% significance level; H = 0 otherwise
    % Test statistic ks2stat: D* = max_x[ (F1(x) - F2(x))]
    tmp = kstest2(OBS, RND);
    % Store in Matrix
    DGN.KS.HH(i,1) = tmp;

end
% Rejection rate of the Null - Hypothesis (H0) of equal distribution
DGN.KS.RJrate = sum(DGN.KS.HH)/Nt *100;

%------------------------------------------------------------------
% DIAGNOSTIC #3 - Akaike Information Content (AIC)
%------------------------------------------------------------------
% AIC = 2 * Dim - 2 * LogLikelihood
DGN.AIC =  2 * ( D - LK(idxMAX) );

%------------------------------------------------------------------
% DIAGNOSTIC #4 - Bayesian Information Criterion
%------------------------------------------------------------------
% BIC = D * ln(n) - 2 * LogLikelihood
DGN.BIC = D*log(L) - 2*LK(idxMAX) ;

%------------------------------------------------------------------
% DIAGNOSTIC #5 - Calculate root mean square error (RMSE) 
%------------------------------------------------------------------
% RES calculated using Standardized Values
DGN.RMSE = sqrt(mean(RES'*RES));
OUT.RES = RES;

%--------------------------------------------------------------------------
% DIAGNOSTIC #6 - Nash–Sutcliffe model Efficiency Coefficient
%--------------------------------------------------------------------------
% NSE = 1 is perfect match
DGN.NSE = 1 - sum( RES'*RES )/sum( (Z - mean(Z)).^2 );

end


%% Probability and Quantile Plot 
function FIG = QQPLOT( EX, TX, TZ, Z, iZ  )

FIG = figure;

%---------------------- (1) PROBABILITY PLOT ------------------------------

subplot(5,2,[3,5,7])
hold on 
box on
sl = line([0 1], [0 1]);
set(sl, 'LineStyle', '-', 'Color', [.8 0 0], 'LineWidth', 2)

try
    pp = scatter(EX, TX, 40, 'MarkerEdgeColor',[.8 .8 .8],'MarkerEdgeAlpha', .4,...
              'MarkerFaceColor',[.5 .5 .5], 'MarkerFaceAlpha', .4, 'LineWidth',1);
catch
    pp = scatter(EX, TX, 40, 'MarkerEdgeColor',[.8 .8 .8],...
        'MarkerFaceColor',[.5 .5 .5],'LineWidth',1);
end

% Add labels
hTitle = title('Probability Plot');
hXLabel = xlabel('Empirical');
hYLabel = ylabel('Theoretical');
            
% Adjust font
set(gca, 'FontName', 'Helvetica', 'FontSize', 12)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'color',[.3 .3 .3], 'fontweight', 'normal')

% Adjust axes properties
set(gca, 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3],...
    'LineWidth', 1);

%------------------------- (2) QUANTILE PLOT ------------------------------

subplot(5,2, [4,6,8])
hold on 
box on

aMIN = min( min(Z(iZ)), min(TZ) );
aMAX = max( max(Z(iZ)), max(TZ) );

sl = line([aMIN  aMAX], [aMIN  aMAX]);
set(sl, 'LineStyle', '-', 'Color', [.8 0 0], 'LineWidth', 2)

try
    qq = scatter(Z(iZ), TZ, 40, 'MarkerEdgeColor',[.8 .8 .8],'MarkerEdgeAlpha', .4,...
              'MarkerFaceColor',[.5 .5 .5], 'MarkerFaceAlpha', .4, 'LineWidth',1);
catch
    qq = scatter(Z(iZ), TZ, 40, 'MarkerEdgeColor',[.8 .8 .8],...
        'MarkerFaceColor',[.5 .5 .5],'LineWidth',1);
end

xlim([aMIN  aMAX]);
ylim([aMIN  aMAX]);

hTitle = title('Quantile Plot');
hXLabel = xlabel('Empirical');
hYLabel = ylabel('Theoretical');
            
% Adjust font
set(gca, 'FontName', 'Helvetica', 'FontSize', 12)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'color',[.3 .3 .3], 'fontweight', 'normal');

% Adjust axes properties
set(gca, 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3],...
    'LineWidth', 1);
end

