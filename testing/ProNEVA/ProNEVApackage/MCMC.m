function [OUT, RUNspec] = MCMC(OBS, RUNspec)

%% MODIFIED FOR NEVA vers. 2
% Notations
% CH: Parameters ensamble split by chain (3d matrix)
% TPAR: Parametrs ensamble
% PRP: Propsal sample
% N: Number of chains (min 5)
% D: Dimension of the problem
% IT: Number of iterations
% LHS: Latin Hypercube Samples
% LN: Number of LHS
% PDV: Probability density value
% L_PDV: Log of PDV
% MR: Mtropolis ratio
% Z: Past Samples collected every 10 iterations
% Rhat: Rhat convergence diagnostic (every 10 iteration)

% OBS: Observations
% PRIOR (structure): Prior Parameter from user
% RUNspec: info for run

%% References used in this code
%[1] Haario, Heikki, Eero Saksman, and Johanna Tamminen. "Adaptive proposal distribution for random walk Metropolis algorithm." Computational Statistics 14.3 (1999): 375-396.
%[2] Roberts, Gareth O., and Jeffrey S. Rosenthal. "Examples of adaptive MCMC." Journal of Computational and Graphical Statistics 18.2 (2009): 349-367.
%[3] Gilks, Walter R., Gareth O. Roberts, and Edward I. George. "Adaptive direction sampling." The statistician (1994): 179-189.
%[4] Haario, Heikki, Eero Saksman, and Johanna Tamminen. "An adaptive Metropolis algorithm." Bernoulli (2001): 223-242.
%[5] ter Braak, Cajo JF. "A Markov Chain Monte Carlo version of the genetic algorithm Differential Evolution: easy Bayesian computing for real parameter spaces." Statistics and Computing 16.3 (2006): 239-249.
%[6] ter Braak, Cajo JF, and Jasper A. Vrugt. "Differential evolution Markov chain with snooker updater and fewer chains." Statistics and Computing 18.4 (2008): 435-446.
%[7] Roberts, Gareth O., and Sujit K. Sahu. "Updating schemes, correlation structure, blocking and parameterization for the Gibbs sampler." Journal of the Royal Statistical Society: Series B (Statistical Methodology) 59.2 (1997): 291-317.
%[8] Duan, Q. Y., Vijai K. Gupta, and Soroosh Sorooshian. "Shuffled complex evolution approach for effective and efficient global minimization." Journal of optimization theory and applications 76.3 (1993): 501-521.
%[9] Vrugt, J. A., Ter Braak, C. J. F., Diks, C. G. H., Robinson, B. A., Hyman, J. M., & Higdon, D. (2009). Accelerating Markov chain Monte Carlo simulation by differential evolution with self-adaptive randomized subspace sampling. International Journal of Nonlinear Sciences and Numerical Simulation, 10(3), 273-290.
%% end references

% Number of parameters (problem dimension)
D = RUNspec.Dim;
% Number of chains
N = RUNspec.Nchain;
% Initialize Chains with NAN
% rows: different chains; columns: Parameter, Likelihood, Posterior; 3rd dim: iterations
CH = nan(N, D+2, RUNspec.maxIT); 
% Assure LN is multiplicative of N and at least 20*D
LN = max([N, 30*D]);
LN = ceil(LN/N); LN = N * LN;

% First Sample
[ LHS ] = SAMPLE0(LN, RUNspec);

% Cohort of Past Samples
Z = LHS;

%% ----> CHANGE
% Compute the posterior probability
LHS(:, D+1 : D+2 ) = POSTERIOR(LHS, OBS, RUNspec);

% Total Parameter Sets
TPAR = LHS;

% Covariance of LHS
COV = cov(TPAR(:, 1:D));

%% Divide LHS into 5 random complex: Based on SCE of Duan et al, 1993
% Create randomly distributed numbers between 1 & LN
c_idx = randperm(LN);
% Divide indices into N complexes
c_idx = reshape(c_idx, LN/N, N);

% Select best candidate in each complex to be the starting point of each chain
for i = 1:N
    % Find indices of max likelihood in each complex
    [~,id] = max(LHS(c_idx(:,i), end));
    % Assign max likelihood samples to chains
    CH(i, 1:D+2, 1) = LHS(c_idx(id,i), :);
end

% Wait bar
eval(strcat('h = waitbar(0,''Hybrid MCMC is estimating the parameters '');'));

% Initialize accp/rej matrix
acc_rate = [];
n_accp   = [];
n_rjct   = [];

tic

%% Go through time: Based on ter Braak 2006, 2008
for t = 2: RUNspec.maxIT

    % Update waitbar
    waitbar(t/RUNspec.maxIT)
    
    % Initialize jumps for each chain
    dPRP = zeros(N, D);
    PRP  = nan(N, D+2);
    id_CH = nan(N,3);
    
    % Use snooker update with a probability of 0.1: remark 5, page 439 of ter Braak 2008
    Snooker = rand < 0.1;
    
    % Update covariance each 20 iterations: remark 3, page 226 of Haario 2001
    if rem(t,20) == 0
        % Covariance of LHS based on the last 50% of chains
        S_T = floor( size(TPAR, 1) );           % Floor makes S_T even
        COV = cov(TPAR(S_T/2:S_T, 1:D));
    end
    
    %% Go through the loop for different chains: "Algorithm for updating population X" page 438 of ter Braak 2008
    for i = 1:N
        % Determine indices of the chains used for DE: Eq 1 of ter Braak 2008, page 437
        id_CH(i,1:3) = randsample(1:size(Z,1) , 3, 'false');
        %% Parallel update
        if ~Snooker
            %% Perform Subspace Sampling %%
            % Randomly select the subspace for sampling
            SS = find( rand(1, D) <= unifrnd(0, 1) );
            % Shouldn't be empty
            if isempty(SS), SS = randsample(1:D,1); end
            % Size of the subspace
            d = length(SS);
          
            %First chain will follow adaptive metropolis %%
            if i >= 1
                %Create a proposal candidate: Eq.3, page 3 of Roberts 2009
                % Small positive constant
                Beta = unifrnd(0,0.1,1);
                dPRP(i, SS) = (1 - Beta) * mvnrnd( zeros(1, d), (2.38^2/d)*COV(SS,SS) ) + Beta * mvnrnd( zeros(1, d), (0.1^2/d)*eye(d) );
            end
            
            %% Next chains based on DE-MC %%
            if i >= 2
                % Select gamma with 10% probability of gamma = 1 or 0.98 for direct jumps: first line on the right in page 242 & first
                % paragraph on the right in page 248 of ter Braak 2006
                 gamma = randsample([2.38/sqrt(2*d) 0.98], 1, 'true', [0.9 0.1]);
                
                % The difference between the two chains: Eq 2, page 241 of ter Braak 2006
                dCH = Z(id_CH(i, 1), 1:D) - Z(id_CH(i, 2), 1:D);
                
                % Select jump: adopted from Eq 2, page 241 of ter Braak 2006 and E4, page 274 of Vrugt 2009
                dPRP(i, SS) =  unifrnd(gamma-0.1,gamma+0.1) * dCH(SS) + normrnd(0, 1e-12, 1, d);
            end
            %% Snooker Update
        else
            % Find the direction of the update: "Algorithm of DE Snooker update (Fig. 3)", page 438 of ter Braak 2008
            DIR = CH(i, 1:D, t-1) - Z(id_CH(i, 1), 1:D);
            
            % Project vector a onto b (https://en.wikipedia.org/wiki/Vector_projection):
            % a.b/b.b * b
            
            % Difference between z1 and z2 and its length on DIR
            DIF = ( (Z(id_CH(i, 2), 1:D) - Z(id_CH(i, 3), 1:D)) * DIR' ) / ( DIR*DIR' ); DIF = max(DIF, 0);
            % Resize DIR
            dCH = DIR * DIF;
            
            % Select jump: page 439 of ter Braak, 2008
            dPRP(i, 1:D) = unifrnd(1.2,2.2,1) * dCH;
        end

    end
    
    %% Create a proposal candidate: Current + Jump %%
    PRP(1:N, 1:D) = CH(1:N, 1:D, t-1) + dPRP(1:N, 1:D);

    %% Boundary 
    %PRP(1:N , 1:D) = BOUNDS(PRP(1:N, 1:D), RUNspec);


    %% Snooker correction for the metropolis ratio: Eq 4, page 439 of ter Braak, 2008
    C_sn = ones(N,1); % No need to correct if parallel updating
    if Snooker
        DSS = PRP(1:N , 1:D) - Z(id_CH(1:N,1), 1:D); % nominator difference of Eq 4
        DS  = CH(1:N, 1:D, t-1) - Z(id_CH(1:N,1), 1:D); % denominator difference of Eq 4
        % Dot function yields norm of each chain in matrix of all chains
        C_sn = ( dot(DSS,DSS,2) ./ dot(DS,DS,2) ).^((D-1)/2);
    end
    
    %% Calculate Likelihood %%
    % of the proposal (PRP)

    PRP(1:N, D+1 : D+2 ) = POSTERIOR( PRP(1:N , 1:D), OBS, RUNspec);
    
    % Compute Metropolis ratio: a/b = exp( log(a) - log(b) )
    MR = min(1, C_sn .* exp(PRP(1:N, end) - CH(1:N, end, t-1)) );
    % Accept/reject the proposal point
    id_accp = find( MR >= rand(N,1) );
    id_rjct = setdiff(1:N, id_accp);
    
    % store number of chains accepted and rejected
    n_accp = [ n_accp; size(id_accp,2)];
    n_rjct = [ n_rjct; size(id_rjct,2)];
    
    %% Accept proposal and update chain %%
    CH(id_accp, 1:D+2, t) = PRP(id_accp, 1:D+2);
    % Reject proposal and remain at the previous state
    CH(id_rjct, 1:D+2, t) = CH(id_rjct, 1:D+2, t-1);
    
   
    %% Total Parameter Sets
    TPAR = [TPAR; CH(1:N, 1:D+2, t)];
    
    %% Check , every 100 steps
    if rem(t,100) == 0

        % Acceptance Rate
        dummy   = sum(n_accp)/sum( n_accp + n_rjct);
        acc_rate = [acc_rate; [t dummy]];
        
    end
    
    %% Update Z every iterations every 10 steps
    if rem(t,10) == 0
    Z = [Z; CH(1:N, 1:D, t)];
    end
    
end
time = toc;

%% OUTPUT STRUCTURE:
% parameters estimated
OUT.CH = CH;
% acceptance Rate
OUT.acc_rate = acc_rate;
% Elapsed time
OUT.time = time; 

% close wait bar
close(h)

end


%% STARTING SAMPLE

function [ Z ] = SAMPLE0(LN, RUNspec)
%% First Sample drawn from prior
% D: dimention of the problem 
% LN: chains in the first sample
% PRIOR: distributions and parameters

% Z: proposed sample

% SAMPLE 0 BASED ON THE DISTRIBUTION TYPE
switch RUNspec.DISTR.Type
    
%--------------------------------------------------------------------------    
%   CASE GEV distribution - xi, si, mu   
%   CASE PEARSON TYPE III distribution - mean, std, skweness   
%--------------------------------------------------------------------------
    case { 'GEV', 'P3' }
              
        % MU - LOCATION / MEAN
        mu1 = RUNspec.PRIOR.MUparm1;
        mu2 = RUNspec.PRIOR.MUparm2;

        switch RUNspec.PRIOR.MUdistr
            case 'Normal';  MU = normrnd(mu1, mu2, [LN,1]);
            case 'Uniform'; MU = unifrnd(mu1, mu2, [LN,1]);
            case 'Gamma';   MU = gamrnd( mu1, mu2, [LN,1]);
        end

        % SI - SCALE / STD
        si1 = RUNspec.PRIOR.SIparm1;
        si2 = RUNspec.PRIOR.SIparm2;

        switch RUNspec.PRIOR.SIdistr    
            case 'Normal';  SI = normrnd(si1, si2, [LN,1]);
            case 'Uniform'; SI = unifrnd(si1, si2, [LN,1]);
            case 'Gamma';   SI = gamrnd( si1, si2, [LN,1]);
        end

        % XI - SHAPE/SKWENESS
        xi1 = RUNspec.PRIOR.XIparm1;
        xi2 = RUNspec.PRIOR.XIparm2;  

        switch RUNspec.PRIOR.XIdistr    
            case 'Normal';  XI = normrnd(xi1, xi2, [LN,1]);
            case 'Uniform'; XI = unifrnd(xi1, xi2, [LN,1]);
            case 'Gamma';   XI = gamrnd( xi1, xi2, [LN,1]);
        end
        
        switch RUNspec.DISTR.Model
            
            case 'Stat'
                [ Z ] = [XI, SI, MU];

            case 'NonStat'
                
                % STARTING VALUES OF TREND COEFFICIETS 
                switch RUNspec.NS.MU
                    case 'none';        MUns = [];
                    case 'Linear';      MUns = .01 * lhsdesign(LN, 1);
                    case 'Quadratic';   MUns = .01 * lhsdesign(LN, 2);
                    case 'Exponential'; MUns = .01 * lhsdesign(LN, 1);
                end

                switch RUNspec.NS.SI
                    case 'none';        SIns = [];
                    case 'Linear';      SIns = .01  * lhsdesign(LN, 1);
                    case 'Quadratic';   SIns = .001 * lhsdesign(LN, 2);
                end

                switch RUNspec.NS.XI
                    case 'none';        XIns = [];
                    case 'Linear';      XIns = .01   * lhsdesign(LN, 1);
                end

                [ Z ] = [ XI XIns SI SIns MU MUns ];                       
                         
        end
%--------------------------------------------------------------------------    
%   CASE GP distribution - xi, si    
%--------------------------------------------------------------------------
    case 'GP'

        % SCALE (SI)
        si1 = RUNspec.PRIOR.SIparm1;
        si2 = RUNspec.PRIOR.SIparm2;

        switch RUNspec.PRIOR.SIdistr    
            case 'Normal';  SI = normrnd(si1, si2, [LN,1]);
            case 'Uniform'; SI = unifrnd(si1, si2, [LN,1]);
            case 'Gamma';   SI = gamrnd( si1, si2, [LN,1]);
        end

        % SHAPE (XI)
        xi1 = RUNspec.PRIOR.XIparm1;
        xi2 = RUNspec.PRIOR.XIparm2;  

        switch RUNspec.PRIOR.XIdistr    
            case 'Normal';  XI = normrnd(xi1, xi2, [LN,1]);
            case 'Uniform'; XI = unifrnd(xi1, xi2, [LN,1]);
            case 'Gamma';   XI = gamrnd( xi1, xi2, [LN,1]);
        end

        
        switch RUNspec.DISTR.Model
            
            case 'Stat'
                [ Z ] = [ XI SI ];

            case 'NonStat'
                
                % STARTING VALUES OF TREND COEFFICIETS 
                switch RUNspec.NS.SI
                    case 'none';        SIns = [];
                    case 'Linear';      SIns = .01 * lhsdesign(LN, 1);
                    case 'Quadratic';   SIns = .01 * lhsdesign(LN, 2);
                end

                switch RUNspec.NS.XI
                    case 'none';        XIns = [];
                    case 'Linear';      XIns = .01  * lhsdesign(LN, 1);
                end

                [ Z ] = [ XI XIns SI SIns ];                       
                        
        end       
end
end

%% BOUNDS

%--------------------------------------------------------------------------
% BOUNDS
%--------------------------------------------------------------------------
function PRP = BOUNDS(PRP, RUNspec)

switch RUNspec.DISTR.Type

%--------------------------------------------------------------------------    
%   CASE GEV distribution - xi, si, mu   
%   CASE P3 distribution  - mean, std, skewness
%--------------------------------------------------------------------------    
    case { 'GEV', 'P3' }
        % Position of the parameters
        if strcmp(RUNspec.DISTR.Model, 'NonStat') 
            colMU = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;  
            colSI = RUNspec.NS.CoeffXI;    
        else
            colMU = 2;
            colSI = 1;
        end
        
        % MU - Location/Mean  
        switch RUNspec.PRIOR.MUdistr % Bound approach: Fold (Vrugt DREAM 2016)

            case 'Uniform'
                parmMIN   = RUNspec.PRIOR.MUparm1;
                parmMAX   = RUNspec.PRIOR.MUparm2;
                RANGEparm = parmMAX - parmMIN;

                idx = find( PRP( :, colMU + 1) < parmMIN);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colMU + 1) = parmMAX - min( RANGEparm, parmMIN - PRP( idx(i), colMU + 1) );
                    end
                end
                clear idx

                idx = find( PRP( :, colMU + 1) > parmMAX);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colMU + 1) = parmMIN + min( RANGEparm, PRP( idx(i), colMU + 1) - parmMAX );
                    end
                end
                clear idx

            case 'Gamma' % Bound approach: Reflect (Vrugt DREAM 2016)
                idx = find( PRP( :, colMU + 1) < 0);
                if ~isempty(idx) 
                    PRP( idx, colMU + 1) = abs ( PRP( idx, colMU + 1) );   
                end 
                clear idx
        end
        % Case of non stationarity in the location parameters
        % Bound approach: Reflect (Vrugt DREAM 2016)
        if strcmp(RUNspec.DISTR.Model, 'NonStat') && ~strcmp(RUNspec.DISTR.Model, 'none')
            
            switch RUNspec.NS.MU
                case 'Linear'
                    idx = find( PRP( :, colMU + 2) ~= sign( RUNspec.NS.Bmu(1) ) );
                    if ~isempty( idx )
                        PRP( idx, colMU + 2) = sign( RUNspec.NS.Bmu(1) ) * abs( PRP( idx, colMU + 2) );
                    end
                    
                case 'Quadratic'
                    idx = find( PRP( :, colMU + 3) ~= sign( RUNspec.NS.Bmu(1) ) );
                    if ~isempty( idx )
                        PRP( idx, colMU + 3) = sign( RUNspec.NS.Bmu(1) ) * abs( PRP( idx, colMU + 3) );
                    end
                    clear idx  
                    idx = find( PRP( :, colMU + 2) ~= sign( RUNspec.NS.Bmu(2) ) );
                    if ~isempty( idx )
                        PRP( idx, colMU + 2) = sign( RUNspec.NS.Bmu(2) ) * abs( PRP( idx, colMU + 2) );
                    end
                    
                case 'Exponential'
                    idx = find( PRP( :, colMU + 2) ~= sign( RUNspec.NS.Bmu(1) ) );
                    if ~isempty( idx )
                        PRP( idx, colMU + 2) = sign( RUNspec.NS.Bmu(1) ) * abs( PRP( idx, colMU + 2) );
                    end
            end
        end
        
       % SI - Scale/Std 
        switch RUNspec.PRIOR.SIdistr % Bound approach: Fold (Vrugt DREAM 2016)

            case 'Uniform'
                parmMIN   = RUNspec.PRIOR.SIparm1;
                parmMAX   = RUNspec.PRIOR.SIparm2;
                RANGEparm = parmMAX - parmMIN;

                idx = find( PRP( :, colSI + 1) < parmMIN);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colSI + 1) = parmMAX - min( RANGEparm, parmMIN - PRP( idx(i), colSI + 1) );
                    end
                end
                clear idx

                idx = find( PRP( :, colSI + 1) > parmMAX);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colSI + 1) = parmMIN + min( RANGEparm, PRP( idx(i), colSI + 1) - parmMAX );
                    end
                end
                clear idx

            case 'Gamma' % Bound approach: Reflect (Vrugt DREAM 2016)
                idx = find( PRP( :, colSI + 1) < 0);
                if ~isempty(idx) 
                    PRP( idx, colSI + 1) = abs ( PRP( idx, colSI + 1) );   
                end 
                clear idx
        end
        
        % XI - Shape/ Skewness

        switch RUNspec.PRIOR.XIdistr % Bound approach: Fold (Vrugt DREAM 2016)

            case 'Uniform'
                parmMIN   = RUNspec.PRIOR.XIparm1;
                parmMAX   = RUNspec.PRIOR.XIparm2;
                RANGEparm = parmMAX - parmMIN;

                idx = find( PRP( :, 1) < parmMIN);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), 1) = parmMAX - min( RANGEparm, parmMIN - PRP( idx(i), 1) );
                    end
                end
                clear idx

                idx = find( PRP( :, 1) > parmMAX);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), 1) = parmMIN + min( RANGEparm, PRP( idx(i), 1) - parmMAX );
                    end
                end
                clear idx

            case 'Gamma' % Bound approach: Reflect (Vrugt DREAM 2016)
                idx = find( PRP( :,1) < 0);
                if ~isempty(idx) 
                    PRP( idx, 1) = abs ( PRP( idx,1) );   
                end 
                clear idx
        end
            
%--------------------------------------------------------------------------    
%   CASE GP distribution - xi, si    
%--------------------------------------------------------------------------   
    case 'GP'
       % SCALE
        if strcmp(RUNspec.DISTR.Model, 'NonStat') 
            colSI = RUNspec.NS.CoeffXI;    
        else
            colSI = 1;
        end

        switch RUNspec.PRIOR.SIdistr % Bound approach: Fold (Vrugt DREAM 2016)

            case 'Uniform'
                parmMIN   = RUNspec.PRIOR.SIparm1;
                parmMAX   = RUNspec.PRIOR.SIparm2;
                RANGEparm = parmMAX - parmMIN;

                idx = find( PRP( :, colSI + 1) < parmMIN);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colSI + 1) = parmMAX - min( RANGEparm, parmMIN - PRP( idx(i), colSI + 1) );
                    end
                end
                clear idx

                idx = find( PRP( :, colSI + 1) > parmMAX);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), colSI + 1) = parmMIN + min( RANGEparm, PRP( idx(i), colSI + 1) - parmMAX );
                    end
                end
                clear idx

            case 'Gamma' % Bound approach: Reflect (Vrugt DREAM 2016)
                idx = find( PRP( :, colSI + 1) < 0);
                if ~isempty(idx) 
                    PRP( idx, colSI + 1) = abs ( PRP( idx, colSI + 1) );   
                end 
                clear idx
        end
        
        %  SHAPE 

        switch RUNspec.PRIOR.XIdistr % Bound approach: Fold (Vrugt DREAM 2016)

            case 'Uniform'
                parmMIN   = RUNspec.PRIOR.XIparm1;
                parmMAX   = RUNspec.PRIOR.XIparm2;
                RANGEparm = parmMAX - parmMIN;

                idx = find( PRP( :, 1) < parmMIN);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), 1) = parmMAX - min( RANGEparm, parmMIN - PRP( idx(i), 1) );
                    end
                end
                clear idx

                idx = find( PRP( :, 1) > parmMAX);
                if ~isempty(idx)
                    for i = 1 : length(idx)
                        PRP( idx(i), 1) = parmMIN + min( RANGEparm, PRP( idx(i), 1) - parmMAX );
                    end
                end
                clear idx

            case 'Gamma' % Bound approach: Reflect (Vrugt DREAM 2016)
                idx = find( PRP( :,1) < 0);
                if ~isempty(idx) 
                    PRP( idx, 1) = abs ( PRP( idx,1) );   
                end 
                clear idx
        end        

end
end





