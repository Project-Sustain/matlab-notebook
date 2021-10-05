function Rhat = CONVERGENCE(CH)

% References:
% Gelman, Andrew, and Donald B. Rubin. "Inference from iterative simulation using multiple sequences." Statistical science (1992): 457-472.
% Brooks, Stephen P., and Andrew Gelman. "General methods for monitoring convergence of iterative simulations." Journal of computational and graphical statistics 7.4 (1998): 434-455.


% Update n_iter
[n_chain,n_par,n_iter] = size(CH);

% Compute mean and variances of each chain, as well variance of means
MEAN = mean(CH, 3); MEAN_VAR = var(MEAN);
VAR = var(CH, [], 3);

% Compute B (between) and W (within chain variances); following page 436 of ref 2
B = n_iter * MEAN_VAR;
W = mean(VAR);


% Compute sigma^2: first eq of page 437 of ref 2
S2 = (n_iter-1)/n_iter * W + B/n_iter;

% Compute rhat for univariate analysis
Rhat = sqrt( (n_chain+1)/n_chain * S2./W - (n_iter-1)/(n_chain*n_iter) );


