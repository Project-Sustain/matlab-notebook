%--------------------------------------------------------------------------
% QUANTILE REGRESSION
%--------------------------------------------------------------------------
% [REF]: "Regression Quantiles", Roger Koenker and Gilbert Bassett
% The Econometric Society, Vol. 46, No. 1 (Jan., 1978), pp. 33-50
% URL: http://www.jstor.org/stable/1913643

function [ U , B ] = REGRquantile(Yobs, alpha)

% Yobs:  Observations
% alpha: quantile regression

% U: treshold

N    = length(Yobs);                % Number of Obs.
X    = [ (1 : N)' ones(N,1)];        % Matrix of coefficients (Linear)

%--------------------------------------------------------------------------
% alpha - regression quantile:
% Yobs = B*X + e - Find B such that min := [ alpha*res(+) + (1 - alpha)*res(-) ]
%--------------------------------------------------------------------------

% x = fminsearch(fun,x0) 
% x0: starting point - find a local minimum x

% Starting point considering the OLS
B0 = X\Yobs;
% Func (sum residuals): [ alpha*res(+) + (1 - alpha)*abs( res(-) ) ]
FUNmin = @(B) sum( alpha*( ( Yobs - X*B ) > 0 ).*( Yobs - X*B ) + ...
              ( 1 - alpha )*( ( Yobs - X*B ) < 0 ).*abs( ( Yobs - X*B )) );
         
B = fminsearch(FUNmin, B0);            

U = X*B;
