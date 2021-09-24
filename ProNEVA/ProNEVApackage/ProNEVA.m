function ProNEVA(OBS, RUNspec, EXTRAS)

% Total Number of Observations
RUNspec.Nobs = length(OBS); 

if strcmp(RUNspec.DISTR.Type, 'P3')
    RUNspec.OBSoriginal = OBS;
    OBS = log(OBS);
end


%--------------------------------------------------------------------------
% DISTRIBUTION TYPE: GEV/GP
% -------------------------------------------------------------------------
% RUNspec.DISTR.Type
% (1) RUNspec.DISTR.Type = 'GEV'     Generalized Extreme Value Distribution
% (2) RUNspec.DISTR.Type = 'GP'      Generalized Pareto Distribution
% (3) RUNspec.DISTR.Type = 'P3'      Pearson Typer III

% In the case of GP - assign threshold
if strcmp(RUNspec.DISTR.Type, 'GP')
    
    % check p in [0 1]
    if RUNspec.THp <= 0 || RUNspec.THp > 1
        disp('Invalide quantile');
        return
    end
    % Define the threshold based on the p-quantile specified
    switch RUNspec.THtype
        
        case 'Const'
            RUNspec.u = quantile(OBS, RUNspec.THp);  
            % Index of the excesses
            RUNspec.IDX_Yex = (OBS > RUNspec.u);
            % Yex are threshold excess conditioned on X > u
            Yex = OBS( RUNspec.IDX_Yex ) - RUNspec.u;
            
        case 'QR'
            [ RUNspec.u, RUNspec.Bu] = REGRquantile(OBS, RUNspec.THp);
            % Index of the excesses
            RUNspec.IDX_Yex = (OBS > RUNspec.u);
            % Yex are threshold excess conditioned on X > u
            Yex = OBS( RUNspec.IDX_Yex ) - RUNspec.u( RUNspec.IDX_Yex ); 
            RUNspec.Yex = Yex;
    end
    
    % Number of excesses
    RUNspec.Nex  = length(Yex);                   

    % Probability of exceess
    RUNspec.Fu = RUNspec.Nex/RUNspec.Nobs;
    
    % Store entire original data set in RUNspec structure
    RUNspec.OBS = OBS;
    
    % Store Exceses
    RUNspec.Yex = Yex;
end

%--------------------------------------------------------------------------
% COVARIATE
%--------------------------------------------------------------------------

if strcmp(RUNspec.DISTR.Model, 'NonStat' )
    % Define vector of Covariate
    switch RUNspec.COV.Type

        case 'Time'
            if strcmp(RUNspec.DISTR.Type, 'GP')
                RUNspec.COV.X  = (1 : length(Yex))';
            else 
                RUNspec.COV.X   = (1 : length(OBS))';
                RUNspec.COV.MX1 = [ ( 1 : length(OBS) )' ones( length(OBS), 1 ) ];                               % Linear regression Matrix
                RUNspec.COV.MX2 = [ ( ( 1 : length(OBS) ).^2 )' ( 1 : length(OBS) )' ones( length(OBS), 1 ) ];   % Linear regression Matrix
            end

        case 'User'
            % Check that the two vectors are consistent
            if ~( length(RUNspec.COV.X) == RUNspec.Nobs ) 
                disp('The covariate vector should have the same size of the observation');
                return
            end
            % Prepare vectors for boundaries
            if strcmp(RUNspec.DISTR.Type, 'GP')
                RUNspec.COV.Xobs  = RUNspec.COV.X;                      % Original Vector of Covariates
                RUNspec.COV.X     = RUNspec.COV.Xobs(RUNspec.IDX_Yex);  % Vector of covariates associated to excesses         
            else 
                RUNspec.COV.MX1 = [ RUNspec.COV.X ones( length(OBS), 1 ) ];                     % Linear regression Matrix
                RUNspec.COV.MX2 = [ RUNspec.COV.X.^2 RUNspec.COV.X ones( length(OBS), 1 ) ];    % Linear regression Matrix
            end

    end
    RUNspec.COV.Xp = median(RUNspec.COV.X);
else % Stationary case: Vector X for MannKendall and White Test
    if strcmp(RUNspec.DISTR.Type, 'GP')
        RUNspec.COV.X  = (1 : length(Yex))';          
    else 
        RUNspec.COV.X   = (1 : length(OBS))';   
    end
end

%----------------------------------------------------------------------
% DIMENTIONALITY OF THE PROBLEM
%----------------------------------------------------------------------
if strcmp(RUNspec.DISTR.Model, 'NonStat')
    
    switch RUNspec.DISTR.Type
        
        case { 'GEV', 'P3' }
            
            % In the case of Trend = 'none', switch to 'Stat' model
            if strcmp( RUNspec.NS.MU, 'none') && ...
               strcmp( RUNspec.NS.SI, 'none') && ...
               strcmp( RUNspec.NS.XI, 'none')

                RUNspec.DISTR.Model = 'Stat';
                
            else
                % TREND:
                % 'none' | 'Linear' | 'Quadratic' | 'Exponential'

                % MU - Location/Mean           
                switch RUNspec.NS.MU
                    case 'none'
                        RUNspec.NS.CoeffMU = 1;
                    
                    case 'Linear'      
                        RUNspec.NS.CoeffMU = 2;                         % Number of Coefficients 
                        RUNspec.NS.Bmu     = RUNspec.COV.MX1\OBS;       % Coefficients using LR
                    
                    case 'Quadratic'
                        RUNspec.NS.CoeffMU = 3;                         % Number of Coefficients 
                        RUNspec.NS.Bmu     = RUNspec.COV.MX2\OBS;       % Coefficients using LR
                    
                    case 'Exponential'
                        % Yobs = A*exp(B*t) --> log(Yobs) = log( A*exp( B*t ) )
                        % Bmu  = [B log(A)] --> Transform Bmu(2)
                        RUNspec.NS.CoeffMU = 2;                         % Number of Coefficients 
                        RUNspec.NS.Bmu     = RUNspec.COV.MX1\log(OBS);	% Coefficients using LR
                        RUNspec.NS.Bmu(2)  = exp( RUNspec.NS.Bmu(2) );  % Transform back
                end

                % SI - Scale / Std          
                switch RUNspec.NS.SI 
                    case 'none';        RUNspec.NS.CoeffSI = 1;
                    case 'Linear';      RUNspec.NS.CoeffSI = 2;
                    case 'Quadratic';   RUNspec.NS.CoeffSI = 3;
                end

                % XI - Shape/Skewness          
                switch RUNspec.NS.XI 
                    case 'none';        RUNspec.NS.CoeffXI = 1;
                    case 'Linear';      RUNspec.NS.CoeffXI = 2;
                end

                % Dimensionality of the problem
                RUNspec.Dim = RUNspec.NS.CoeffXI + ...
                              RUNspec.NS.CoeffSI + ...
                              RUNspec.NS.CoeffMU;
            end
        
    case 'GP'
        
        % In the case of Trend = 'none', switch to 'Stat' model
        if strcmp( RUNspec.NS.SI, 'none') && ...
           strcmp( RUNspec.NS.XI, 'none')

           RUNspec.DISTR.Model = 'Stat';
                
        else
            % TREND:
            % 'none' | 'Linear' | 'Quadratic' | 'Exponential'
            % Scale - si
            switch RUNspec.NS.SI 
                case 'none';        RUNspec.NS.CoeffSI = 1;
                case 'Linear';      RUNspec.NS.CoeffSI = 2;
                case 'Quadratic';   RUNspec.NS.CoeffSI = 3;
            end

            switch RUNspec.NS.XI 
                case 'none';        RUNspec.NS.CoeffXI = 1;
                case 'Linear';      RUNspec.NS.CoeffXI = 2;
            end
        % Dimensionality of the problem
        RUNspec.Dim = RUNspec.NS.CoeffXI + ...
                      RUNspec.NS.CoeffSI;
        end
        
    end

end

if strcmp(RUNspec.DISTR.Model, 'Stat')
    
    switch RUNspec.DISTR.Type
        
        case { 'GEV', 'P3' }
            RUNspec.Dim = 3;
        case 'GP'
            RUNspec.Dim = 2;          
            
    end
    
end
%--------------------------------------------------------------------------
% PRIOR
%--------------------------------------------------------------------------  
if strcmp(RUNspec.DISTR.Model, 'NonStat')
    
    % Coefficients are Normal Distributed - Specify Mean and Std
    RUNspec.PRIOR.COEFFparm1 =  0;
    RUNspec.PRIOR.COEFFparm2 = 10;

end
        
%--------------------------------------------------------------------------
% PARAMETER ESTIMATION - MCMC
%--------------------------------------------------------------------------

disp('SOLVE MCMC')
switch RUNspec.DISTR.Type
    case { 'GEV', 'P3' }
        [OUT, RUNspec] = MCMC(OBS, RUNspec);
    case 'GP'
        [OUT, RUNspec] = MCMC(Yex, RUNspec);
end

% Save only chains after burn in period
OUT.CH = OUT.CH(:,:, RUNspec.brn + 1 : end );

OUT.RhatCH = CONVERGENCE(OUT.CH(:,1:end-2,:));

% Warning if there is no convergence
if sum( OUT.RhatCH >= 1.2 ) ~= 0
    disp('Poor Convergence (R > 1.2)');
    disp('Try:');
    disp('change priors');
    disp('re-run MCMC');
    disp('increase n. of iterations');
    disp('increase n. of chains')
    return
elseif any( reshape( OUT.CH( : , end, : ), [], 1) == -Inf  ) || ...
       any( isnan( reshape( OUT.CH( : , end, : ), [], 1) ) ) || ...  
       any( reshape( OUT.CH( : , end, : ), [], 1) ==  Inf  )
   disp(' Invalid Posterior Values');
   return
end

% Reshape 3D array in a 2D array
% row: N_chains * N_iteration after burn-in
% col: Parameters | LogLikelihood | Posterior
OUT.CH = reshape( permute( OUT.CH, [ 2 1 3 ] ), size( OUT.CH, 2 ), [] )';

%--------------------------------------------------------------------------
% DIAGNOSTIC
%--------------------------------------------------------------------------
disp('DIAGNOSTIC')

switch RUNspec.DISTR.Type
    case { 'GEV'}
        [OUT, DGN] = DIAGNOSTIC(OBS, OUT, RUNspec);
    case {'P3'}
        if ~(strcmp(RUNspec.DISTR.Model, 'NonStat') && strcmp(RUNspec.NS.XI, 'Linear') )
        [OUT, DGN] = DIAGNOSTIC(OBS, OUT, RUNspec);
        else
            DGN = NaN;
        end
        
    case 'GP'
        [OUT, DGN] = DIAGNOSTIC(Yex, OUT, RUNspec);
end

%--------------------------------------------------------------------------
% PLOT
%--------------------------------------------------------------------------

if strcmp( EXTRAS.PlotRL, 'Y' )

    disp('PLOTS')
    if strcmp(RUNspec.DISTR.Type, 'GP') % Test applied to the excess
        % RETURN LEVELS BASED ON DIFFERENT APPROCHES
        [ OUT ] = PLOTS(Yex, OUT, RUNspec);
        % PREDICTIVE DISTRIBUTION
        [PDFhat, Zhat] = PREDICTIVEpdf(Yex, OUT, RUNspec);
    else
        % RETURN LEVELS BASED ON DIFFERENT APPROCHES
        [ OUT ] = PLOTS(OBS, OUT, RUNspec);
        % PREDICTIVE DISTRIBUTION
        [PDFhat, Zhat] = PREDICTIVEpdf(OBS, OUT, RUNspec);
    end

end

%--------------------------------------------------------------------------
% STATISTICAL TESTS - Significance Level 5 %
%--------------------------------------------------------------------------

if strcmp(EXTRAS.RunTests, 'Y')
    disp('TEST')

    if strcmp(RUNspec.DISTR.Type, 'GP') % Test applied to the excess
        [ TST ] = TEST( RUNspec.COV.X, Yex, RUNspec );
    else
        [ TST ] = TEST( RUNspec.COV.X, OBS, RUNspec );
    end
    OUT.TST = TST;
end


% -------------------------------------------------------------------------
% SAVE RESULTS
% -------------------------------------------------------------------------
load('currentDIR.mat');

if strcmp(EXTRAS.saveRES, 'Y')
    
    SAVEresults(OBS, RUNspec, OUT, DGN, currentDIR);

end

end









