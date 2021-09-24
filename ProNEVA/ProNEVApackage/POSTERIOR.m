%--------------------------------------------------------------------------
% POSTERIOR DISTRIBUTION 
%--------------------------------------------------------------------------

function [OUT] = POSTERIOR(Z, DATA, RUNspec)

% D: problem dimensionality
% Z: structure w/ proposed parameters
% DATA: observations

% [OUT] = [ POSTERIOR PDF | MAX LIKELIHOOD ] 

C = size(Z,1);          % number of chains

% Initialize matrices 
logPST = -inf*ones(C,1);    % Log Posterior 
logLK  = -inf*ones(C,1);    % Log Likelihood

% Check Validity GP
checkGP  = @(Y, xi, si) ( 1 + xi.*(Y./si) ) > 0 ;

% Check Validity GEV 
checkGEV = @(Y, xi, si, mu) ( 1 + xi.*(Y - mu)./si ) > 0 ;

% Check Validity P3 in P3pdf

switch RUNspec.DISTR.Type
%--------------------------------------------------------------------------    
%   CASE GEV distribution - xi, si, mu   
%   CASE PEARSON TYPE III distribution - mean, std, skweness   
%--------------------------------------------------------------------------    
    case { 'GEV', 'P3' } 
        L = RUNspec.Nobs;      % Length data
            
        % GEV: exp( -(1 + (xi/si)*(x-mu))^(-1/xi) ) defined for: (1 + xi(data-mu)/sigma) > 0
        
        % Posterior for each chain
        for i = 1 : C

            switch RUNspec.DISTR.Model
                
                case 'Stat'
                    
                    xi = repmat( Z(i,1), L, 1); 
                    si = exp( repmat( Z(i,2), L, 1 ) );
                    mu = repmat( Z(i,3), L, 1 );
                
                case 'NonStat'
                    
                    t = RUNspec.COV.X;      % Vector of covariates
                    
                    idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;     % First Column containing MU's Coefficients
                    idxS = RUNspec.NS.CoeffXI;                          % First Column containing SI's Coefficients
                    
                    % MU - Location / Mean 
                    switch RUNspec.NS.MU

                        case 'none'
                            mu = repmat( Z(i, idxM + 1), L, 1 );
                        case 'Linear'
                            mu = Z(i,idxM + 2).*t + Z(i,idxM + 1);
                        case 'Quadratic'
                            mu = Z(i,idxM + 3).*t.^2 + Z(i,idxM + 2).*t + Z(i,idxM + 1);
                        case 'Exponential'
                            mu = Z(i,idxM + 1).*exp( Z(i,idxM + 2).*t );
                    end

                    % SI - Scale / Std         
                    switch RUNspec.NS.SI 
                        case 'none'
                            si = exp( repmat( Z(i, idxS + 1), L, 1 ) );
                        case 'Linear'
                            si = exp( Z(i,idxS + 2).*t + Z(i,idxS + 1) );
                        case 'Quadratic'
                            si = exp( Z(i,idxS + 3).*t.^2 + Z(i,idxS + 2).*t + Z(i,idxS + 1) );
                    end

                    % XI - Shape / Skewness       
                    switch RUNspec.NS.XI
                        case 'none'
                            xi = repmat( Z(i,1), L, 1 );
                        case 'Linear'
                            xi = Z(i,2).*t + Z(i,1);                       
                        case 'Quadratic'
                            xi = Z(i,3).*t.^2 + Z(i,2).*t + Z(i,1);
                        case 'Exponential'
                            xi = Z(i,1).*exp( Z(i,2).*t );
                    end                    
            end
            
            % GEV
            if strcmp(RUNspec.DISTR.Type, 'GEV')
                check   = checkGEV( DATA, xi, si, mu ) > 0 ;
                checkXI = xi < 1/2 ;
                if sum(check) == L && sum( checkXI ) == L
                    
                    [PR] = PRIOR( RUNspec, Z(i, :));                    % Prior
                    LK   = gevpdf(DATA, xi, si, mu);                    % Likilihood
                    
                    logLK(i,1)  = sum( log( LK ) );                     % Log Likelihood
                    logPST(i,1) = logLK(i,1) + sum( log( PR ) );        % Posterior 

                end
            else % PEARSON
                
                [PR] = PRIOR( RUNspec, Z( i , : ));             % Prior        
                LK   = P3pdf( DATA, xi, si, mu );        % Likelihood
                
                logLK(i,1)  = sum( log( LK ) );                 % Log Likelihood
                logPST(i,1) = logLK(i,1) + sum( log( PR ) );	% Posterior 
 
            end

        end
        
        [ OUT ] = [ logLK, logPST ] ;
        
%--------------------------------------------------------------------------    
%   CASE GP distribution - xi, si    
%--------------------------------------------------------------------------                
    case 'GP'
        
        L = RUNspec.Nex;    % Number of Excess
        
        % p = gpcdf(X,k,sigma,theta) : Prob of X
        % k tail index (shape) | sigma: scale | theta: threshold (location) 
        % Posterior for each chain
        for i = 1 : C

            switch RUNspec.DISTR.Model
                
                case 'Stat'
                    
                    xi = Z(i,1); 
                    si = exp( Z(i,2) );
                
                case 'NonStat'
                    
                    t = RUNspec.COV.X;      % Vector of covariates
                    
                    % First Column containing SI's Coefficients
                    idxS = RUNspec.NS.CoeffXI;
                    
                    % Scale - si          
                    switch RUNspec.NS.SI
                        case 'none'
                            si = exp( Z(i,idxS + 1) );
                        case 'Linear'
                            si = exp( Z(i,idxS + 2).*t + Z(i,idxS + 1) );
                        case 'Quadratic'
                            si = exp( Z(i,idxS + 3).*t.^2 + Z(i,idxS + 2).*t + Z(i,idxS + 1) );
                    end

                    % Shape - xi           
                    switch RUNspec.NS.XI 
                        case 'none'
                            xi = Z(i,1);
                        case 'Linear'
                            xi = Z(i,2).*t + Z(i,1);
                        case 'Quadratic'
                            xi = Z(i,3).*t.^2 + Z(i,2).*t + Z(i,1);
                        case 'Exponential'
                            xi = Z(i,1).*exp( Z(i,2).*t );
                    end
                    
            end
 
            check = checkGP( DATA, xi, si ) > 0 ;
            
            if sum(check) == L
                 
                [PR] = PRIOR( RUNspec, Z( i,: ) );              % Prior 
                LK   = gppdf(DATA, xi, si, 0);                  % Likelihood ( GP thr = 0, DATA == Excesses)  
                
                logLK(i,1)  = sum( log( LK ) );                 % Log Likelihood
                logPST(i,1) = logLK(i,1) + sum( log( PR ) );	% Posterior 
            end

        end
        
        [ OUT ] = [ logLK, logPST ];
end
end

%-------------------------------------------------------------------------%
%                             PEARSON TYPE III                            %
%-------------------------------------------------------------------------%
% REFERENCES:
% [1] Griffis & Stedinger, "Log-Pearson Type III and its application in 
% FFA I and II", (2007), Journal of Hydrological Engineering, ASCE

% P3 - PDF: 
% P3 - Parameters
% Shape:    alpha = 4 / ( gammaX^2 )
% Scale:    beta  = ( sigmaX * gammaX )/2
% Location: tau   = muX - 2*sigmaX/gammaX
% [ muX, sigmaX, gammaX ] : first 3 moments

% 1/ ( |beta| * Gamma(alpha) ) * ( (X - tau) / beta )^( alpha-1 )*exp(- (X - tau)/beta )
% for alpha > 0, ( X - tau )/beta > 0, Gamma(alpha) : complete gamma function

% LP3 - X = log(Q) 
% logs used: ln or log10

function [ PDF ] = P3pdf( X, gammaX, sigmaX, muX )

L = length(X);

% Evaluate parameter of the distribution:

% Shape:    alpha = 4 / ( gammaX^2 )
alpha = 4 ./ ( gammaX.^2 );

% Scale:    beta  = ( sigmaX * gammaX )/2
beta  = ( sigmaX .* gammaX )./2;

% Location: tau   = muX - 2*sigmaX/gammaX
tau   = muX - 2.*sigmaX./gammaX;

% ( X - tau )/beta > 0 
check = ( X - tau )./beta;

if ~any( check <= 0 )

    % Calculate the logPDF to avoid error in gamma function ( suggestion in Luke et al. 2017)
    logPDF = - log( abs( beta ) ) - gammaln( alpha ) + ( alpha - 1 ).*log( ( X - tau )./beta ) - ( X - tau )./beta;
    
    % PDF not normilized
    PDF = exp( logPDF );
   
else
    PDF = zeros(L,1);
end

end
