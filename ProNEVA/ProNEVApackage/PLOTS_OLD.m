%--------------------------------------------------------------------------
%                                 PLOT ProNEVA                            %
%--------------------------------------------------------------------------
function [ OUT ] = PLOTS(OBS, OUT, RUNspec)

% Define the covariates for the plots if non stationary model. Otherwise,
% only one plot

if strcmp( RUNspec.DISTR.Model, 'NonStat' )
    
    t   = RUNspec.COV.X;         % Covariate
    VC1 = median( t );           % Median 
    VC2 = quantile( t, .95 );    % 95 - quantile

    OUT.RLplot.VC = [VC1, VC2];

    % Add two more value of the covariate in case distribution type is 'Time'
    if strcmp(RUNspec.COV.Type, 'Time')

        VC3 = length(t) + median( t );           % Median beyond time of observations

        OUT.RLplot.VC = [OUT.RLplot.VC, VC3];

    end
end

% Plot Return Level
[ OUT ] = returnLEVEL( OBS, OUT, RUNspec );

if strcmp( RUNspec.DISTR.Model, 'NonStat' )
    % Plot Waiting Time
    [ OUT ] = WATINGtime( OBS, OUT, RUNspec );
    % Plot Effective Return Level
    [ OUT ] = EFFECTIVE_ReturnLevel( OBS, OUT, RUNspec );
end

end


%--------------------------------------------------------------------------
%                                 WAITING TIME                            %
% Reference:
% [1] Salas et al 2014 - "Revisiting the Concepts of Return Period and Risk
% for Nonstationary Hydrologic Extreme Events"
% [2] Cooley 2013 - Extremes in a Changing Climate - Chapter 3
%--------------------------------------------------------------------------

function [ OUT ] = WATINGtime( OBS, OUT, RUNspec )

% OBS: observations
% OUT: parameter estimates
% RUNspec: info about the model
% RLplot: Info about the plot

if strcmp( RUNspec.COV.Type, 'Time')
    %--------- Load Dimension of the problem and estimated parameters ---------

    D   = RUNspec.Dim;                  % Problem Dimension
    CH  = OUT.CH( :, 1:D);              % Sets of Parameter
    PST = OUT.CH( :, end);              % Log - Posterior 

    %------------------- Find set of parameters w/ maximum Posterior ---------- 

    % Location Maximum LogPosterior
    [ idxMAX, ~ ] = find( PST == max( PST ), 1, 'last');    

    %------------------------------ Covariates ------------------------------- 
    covX =  0 : RUNspec.RP ;         % Covariate
    NX   =  length(covX);            % Length Covariates
    %----------------------- Vector of Return Periods ------------------------- 

    %TT = ( 2 : RUNspec.RP )';        % Vector of RP including value of ~1    
    %q  = 1 - 1./TT;                % Probability associated w/ R
    q  = ( 0.001 :0.001:0.99 )';
    tt = ( 1./(1-q) );

    % ------------------------------- Extract Parameters ----------------------
    % ------------------------------- Extract Parameters ----------------------
    switch RUNspec.DISTR.Type

        %----------------------------- GEV and P3 ----------------------------- 
        case { 'GEV', 'P3' }       
            % Define vectors mu, si, xi ------------------
            switch RUNspec.DISTR.Model

                case 'Stat'  

                    mu = repmat( CH( idxMAX, 3), NX, 1 ) ;
                    si = repmat( exp( CH( idxMAX, 2) ), NX, 1 ) ;
                    xi = repmat( CH( idxMAX, 1), NX, 1 ) ;

                case 'NonStat'

                    idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;     % First Column containing MU's Coefficients
                    idxS = RUNspec.NS.CoeffXI;                          % First Column containing SI's Coefficients

                    %------------------ MU - Location / Mean ------------------
                    switch RUNspec.NS.MU

                        case 'none'
                            mu  = repmat( CH( idxMAX, idxM + 1 ), NX, 1 ) ;
                        case 'Linear'
                            mu  = repmat( CH( idxMAX, idxM + 1 ), NX, 1 ) + CH( idxMAX, idxM + 2 ).*covX ;
                        case 'Quadratic'
                            mu  = CH( idxMAX, idxM + 3 )*covX.^2 + CH( idxMAX, idxM + 2 )*covX + repmat( CH( idxMAX, idxM + 1 ), NX, 1 );
                        case 'Exponential'
                            mu  = CH( idxMAX, idxM + 1 ).*exp( CH( idxMAX, idxM + 2 )*covX );
                    end

                    %------------------ SI - Scale / Std ----------------------        
                    switch RUNspec.NS.SI 
                        case 'none'
                            si  = exp( repmat( CH( idxMAX, idxS + 1 ), 1, NX )  );
                        case 'Linear'
                            si  = exp( repmat( CH( idxMAX, idxS + 1 ), 1, NX ) + CH( idxMAX, idxS + 2 )*covX );
                        case 'Quadratic'
                            si  = exp( CH( idxMAX, idxS + 3 )*covX.^2 + CH( idxMAX, idxS + 2 )*covX + repmat( CH( idxMAX, idxS + 1 ), 1, NX ) );
                    end

                    %------------------ XI - Shape / Skewness -----------------       
                    switch RUNspec.NS.XI
                        case 'none'
                            xi  = repmat( CH( idxMAX, 1 ), 1, NX );
                        case 'Linear'
                            xi  = repmat( CH( idxMAX, 1 ), 1, NX ) + CH( idxMAX, 2 )*covX ;
                    end
            end
            % Define CDFinv function based on the distribution type
            if strcmp( RUNspec.DISTR.Type, 'GEV' )
                QTLfunc = @( p, xi, si, mu) gevinv( p, xi, si, mu );
                CDFfunc = @( X, xi, si, mu) gevcdf( X, xi, si, mu ); 
            else
                QTLfunc = @( p, xi, si, mu) P3inv( p, xi, si, mu );
                CDFfunc = @( X, xi, si, mu, OBS) P3cdf( X, xi, si, mu, OBS ); 
            end
            
            % Design quantile at time t = 0 (ref [1] pag 550 eq.18)
            % Return Level as a function of the covariate
            Zq0 = zeros( length( q ), 1 );

            for i = 1 : length( q )
                Zq0(i) =  QTLfunc( q( i ), xi( 1 ), si( 1 ), mu( 1 ) );
            end
            
            if strcmp( RUNspec.DISTR.Type, 'GEV' )
                qt( :,1 )      = CDFfunc( Zq0, xi( 2 ), si( 2 ), mu( 2 ) );     % Probability of Zq0 at time t = 1;
                cumPRD( :, 1 ) = qt.*q;                                         % Cumulative Probability
                
                for t = 3 : RUNspec.RP + 1 
                    qt( :, t - 1) = CDFfunc( Zq0, xi( t ), si( t ), mu( t ) );  % Probability of Zq0 at time t
                    cumPRD(:, t - 1 ) = prod(qt,2);                             % Cumulative Probability
                end
                
            else % CASE P3 - cdf calculated via integration of pdf
                qt( :,1 )      = CDFfunc( Zq0, xi( 2 ), si( 2 ), mu( 2 ), OBS );
                cumPRD( :, 1 ) = qt.*q;
                
                for t = 3 : RUNspec.RP + 1
                    qt( :, t - 1) = CDFfunc( Zq0, xi( t ), si( t ), mu( t ), OBS);  
                    cumPRD(:, t - 1 ) = prod(qt,2);                                
                end
            end

            % Expected Waiting Time eq.(8b) ref[1] and ref[2]
            OUT.EWT = 1 + sum(cumPRD,2);
                        

        %----------------------- Generalized Pareto ---------------------------    
        case 'GP'        
            %------------------- Define vectors  si, xi -----------------------
            switch RUNspec.DISTR.Model

                case 'Stat'
                    si = repmat( exp( CH( idxMAX, 2) ), NX, 1 ) ;
                    xi = repmat( CH( idxMAX, 1), NX, 1 ) ;

                case 'NonStat'

                    idxS = RUNspec.NS.CoeffXI;      % First Column containing SI's Coefficients

                    %------------------------------ SI ------------------------                     
                    switch RUNspec.NS.SI 
                        case 'none'
                            si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) );
                        case 'Linear'
                            si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) + CH( idxMAX, idxS + 2 )*covX );
                        case 'Quadratic'
                            si  = exp( CH( idxMAX, idxS + 3 )*covX.^2 + CH( idxMAX, idxS + 2 )*covX + repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) );
                    end

                    %--------------------------- XI ---------------------------       
                    switch RUNspec.NS.XI
                        case 'none'
                            xi  = repmat( CH( idxMAX, 1 ), NX, 1 );
                        case 'Linear'
                            xi  = repmat( CH( idxMAX, 1 ), NX, 1 ) + CH( idxMAX, 2 )*covX ;
                    end
            end
            % RUNspec.NobsY: number of observations in one year: RUNspec.NobsY
            % RUNspec.Fu:= RUNspec.Nex/RUNspec.Nobs Probability of exceess 

            pGP = tt.*RUNspec.NobsY*RUNspec.Fu;

            if strcmp( RUNspec.DISTR.Model, 'NonStat' )
                if strcmp( RUNspec.THtype, 'QR' )
                    U = [ covX ones( NX, 1 ) ]*RUNspec.Bu;
                else
                    U = RUNspec.u.*ones( NX, 1 );
                end
            else
                if strcmp( RUNspec.THtype, 'QR' )
                    U = [ median(RUNspec.Nobs) 1 ]*RUNspec.Bu;
                else
                    U = RUNspec.u.*ones( NX, 1 );

                end
            end
            
            % Design quantile at time t = 0 (ref [1] pag 550 eq.18)
            % Return Level as a function of the covariate
            Zq0 = zeros( length( q ), 1 );

            for i = 1 : length( q )
                Zq0(i) =  U( 1 ) + si( 1 )./xi( 1 ).*( pGP(i).^xi( 1 ) - 1 );
            end
            
            % Probability of Zq0 at time t = 1; 
            qt( :,1 )      = 1 - RUNspec.NobsY*RUNspec.Fu.*( 1 + ( Zq0 - U(2) ).*xi(2)./si(2) ).^(-1./xi(2)); 
            cumPRD( :, 1 ) = qt.*q;
            
            for t = 3 : RUNspec.RP + 1
                % Probability of Zq0 at time t
                qt( :, t - 1) = 1 - RUNspec.NobsY*RUNspec.Fu.*( 1 + ( Zq0 - U(t) ).*xi(t)./si(t) ).^(-1./xi(t));
                % Cumulative Probability
                cumPRD(:, t - 1 ) = prod(qt,2);
            end
            % Expected Waiting Time eq.(8b) ref[1] and ref[2]
            OUT.EWT =  1 + sum(cumPRD,2);

    end
    
    % Save Quantile Zq0 at time t = 0
    if strcmp( RUNspec.DISTR.Type, 'P3' )
        Zq0 = exp( Zq0 );
    end
    
    OUT.Zq0 = Zq0;

    
    %--------------------------------------------------------------------------
    % PLOT Expected Waiting Time
    %--------------------------------------------------------------------------
    figEWT = figure;
    subplot(6,4, 5:20)
    hold on 

    % Axis #1 - Return Period
    hEWT = plot( 1./(1-q), Zq0, 'LineStyle', '-', 'Color', [.15 .15 .15], 'LineWidth', 2);
    % position of first axes
    ax1 = gca; POSax1 = ax1.Position; 
    set(ax1, 'TickDir', 'in', 'TickLength', [.02 .02], ...
        'XMinorTick', 'off', 'YMinorTick', 'off', 'YColor', [.3 .3 .3],'XColor', [0 0 .5], 'LineWidth', 1.7);
    xlabel('Return Period');
    ylabel('Return Level');

    % Axis #2 - Expected Waiting Time
    ax2 = axes('Position',POSax1, 'XAxisLocation','top','YAxisLocation','right',...
                'Color','none');  
    line(OUT.EWT, Zq0, 'Parent', ax2, 'Color','none');
    xlabel('Expected Waiting Time');
    set(ax2, 'TickDir', 'in', 'TickLength', [.02 .02], 'YtickLabel', [], 'YTick', [],...
        'XMinorTick', 'off', 'YMinorTick', 'off', 'YColor', [.3 .3 .3],'XColor', [.8 0 0], 'LineWidth', 1.7 );

    % Adjust font
    set([ax1 ax2], 'FontName', 'Helvetica', 'FontSize', 14)

    % Legend
    hLgnd = legend(hEWT, 'Return Level at t_{0}','Location', 'southeast');
    set(hLgnd, 'FontSize', 12, 'FontName', 'Helvetica', 'TextColor',[.3 .3 .3], 'LineWidth',1)

end
end


%--------------------------------------------------------------------------
%                       RETURN LEVEL CURVES                               %
% Ref [1]: Coles 2001. An introduction to statistical modeling of extreme
% value
%--------------------------------------------------------------------------
function [ OUT ] = returnLEVEL( OBS, OUT, RUNspec )

% OBS: observations
% OUT: parameter estimates
% RUNspec: info about the model
% RLplot: Info about the plot

%--------- Load Dimension of the problem and estimated parameters ---------

D   = RUNspec.Dim;                  % Problem Dimension
CH  = OUT.CH( :, 1:D);              % Sets of Parameter
PST = OUT.CH( :, end);              % Log - Posterior

%------------------- Find set of parameters w/ maximum Posterior ---------- 

[ idxMAX, ~ ] = find( PST == max( PST ), 1, 'last');    % Location Maximum LogPosterior

%----------------------- Vector of Return Periods ------------------------- 

TT  = ( 2 : RUNspec.RP )';              % Vector of RP including value of ~1
p   = 1 - 1./TT;                     % Probability associated w/ R

%----------------------- Number of Plots ------------------------- 
if strcmp( RUNspec.DISTR.Model, 'NonStat' )
    nVC  = size( OUT.RLplot.VC, 2 );                     
else
    nVC  = 1;
end

% ------------------------------- Extract Parameters ----------------------
switch RUNspec.DISTR.Type
    
    %----------------------------- GEV and P3 ----------------------------- 
    case { 'GEV', 'P3' }       
        % Define vectors mu, si, xi ------------------
        switch RUNspec.DISTR.Model
            
            case 'Stat'  
                
                mu = repmat( CH( :, 3), 1, nVC ) ;
                si = repmat( exp( CH( :, 2) ), 1, nVC ) ;
                xi = repmat( CH( :, 1), 1, nVC ) ;
            
            case 'NonStat'
                
                idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;     % First Column containing MU's Coefficients
                idxS = RUNspec.NS.CoeffXI;                          % First Column containing SI's Coefficients
                                
                %------------------ MU - Location / Mean ------------------
                switch RUNspec.NS.MU

                    case 'none'
                        mu  = repmat( CH( :, idxM + 1 ), 1, nVC ) ;
                    case 'Linear'
                        mu  = repmat( CH( :, idxM + 1 ), 1, nVC ) + CH( :, idxM + 2 )*OUT.RLplot.VC ;
                    case 'Quadratic'
                        mu  = CH( :, idxM + 3 )*OUT.RLplot.VC.^2 + CH( :, idxM + 2 )*OUT.RLplot.VC + repmat( CH( :, idxM + 1 ), 1, nVC );
                    case 'Exponential'
                        mu  = CH( :, idxM + 1 ).*exp( CH( :, idxM + 2 )*OUT.RLplot.VC );
                end

                %------------------ SI - Scale / Std ----------------------        
                switch RUNspec.NS.SI 
                    case 'none'
                        si  = exp( repmat( CH( :, idxS + 1 ), 1, nVC )  );
                    case 'Linear'
                        si  = exp( repmat( CH( :, idxS + 1 ), 1, nVC)  + CH( :, idxS + 2 )*OUT.RLplot.VC );
                    case 'Quadratic'
                        si  = exp( CH( :, idxS + 3 )*OUT.RLplot.VC.^2 + CH( :, idxS + 2 )*OUT.RLplot.VC + repmat( CH( :, idxS + 1 ), 1, nVC) );
                end

                %------------------ XI - Shape / Skewness -----------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi  = repmat( CH( :, 1 ), 1, nVC );
                    case 'Linear'
                        xi  = repmat( CH( :, 1 ), 1, nVC ) + CH( :, 2 )*OUT.RLplot.VC ;
                end
        end
        
        OUT.PARvc(:, 1, 1:nVC) = xi;
        OUT.PARvc(:, 2, 1:nVC) = si;
        OUT.PARvc(:, 3, 1:nVC) = mu;
        
        % ---------------------- RETURN LEVEL ------------------------
           
        r  = size( mu, 1 );                 % Number sets
        
        RLmax = zeros( length(p), nVC);     % Initialize matrix
        RLmin = zeros( length(p), nVC);     % Initialize matrix 
        
        if strcmp( RUNspec.DISTR.Type, 'GEV' )
            QTLfunc = @( p, xi, si, mu) gevinv( p, xi, si, mu );
        else
            QTLfunc = @( p, xi, si, mu) P3inv( p, xi, si, mu );
        end
            
        for i = 1 : nVC

            temp = zeros(r, length(p) );

            for j = 1 : r
                temp( j, : ) =  QTLfunc( p, xi( j , i ), si( j , i ), mu( j , i ) );
            end

            OUT.RLplot.RL95(:,i)  = quantile(temp, .95)';
            OUT.RLplot.RL05(:,i)  = quantile(temp, .05)';
            OUT.RLplot.RL50(:,i)  = quantile(temp, .50)';
            OUT.RLplot.RLm (:,i)  = temp(idxMAX, :)';

            % For Shaded Area 
            RLmin(:,i) = min(temp);
            RLmax(:,i) = max(temp);

        end
        clear temp   
    %----------------------- Generalized Pareto ---------------------------    
    case 'GP'        
        %------------------- Define vectors  si, xi -----------------------
        switch RUNspec.DISTR.Model
            case 'Stat'
                si = exp( CH( :, 2) );
                xi = CH( :, 1);
            
            case 'NonStat'
                
                idxS = RUNspec.NS.CoeffXI;      % First Column containing SI's Coefficients
                
                %------------------------------ SI ------------------------                     
                switch RUNspec.NS.SI 
                    case 'none'
                        si  = exp( repmat( CH( :, idxS + 1 ), 1, nVC )  );
                    case 'Linear'
                        si  = exp( repmat( CH( :, idxS + 1 ), 1, nVC ) + CH( :, idxS + 2 )*OUT.RLplot.VC );
                    case 'Quadratic'
                        si  = exp( CH( :, idxS + 3 )*OUT.RLplot.VC.^2 + CH( :, idxS + 2 )*OUT.RLplot.VC + repmat( CH( :, idxS + 1 ), 1, nVC ) );
                end

                %--------------------------- XI ---------------------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi  = repmat( CH( :, 1 ), 1, nVC );
                    case 'Linear'
                        xi  = repmat( CH( :, 1 ), 1, nVC ) + CH( :, 2 )*OUT.RLplot.VC ;
                end
        end
        
        OUT.PARvc(:, 1, 1:nVC) = xi;
        OUT.PARvc(:, 2, 1:nVC) = si;
        
        % RUNspec.NobsY: number of observations in one year: RUNspec.NobsY
        % RUNspec.Fu:= RUNspec.Nex/RUNspec.Nobs Probability of exceess 

        pGP = TT.*RUNspec.NobsY*RUNspec.Fu;
        
        if strcmp( RUNspec.DISTR.Model, 'NonStat' )
            if strcmp( RUNspec.THtype, 'QR' )
                U = [ OUT.RLplot.VC' ones( nVC, 1 ) ]*RUNspec.Bu;
            else
                U = RUNspec.u.*ones( nVC, 1 )  ;
            end
        else
            if strcmp( RUNspec.THtype, 'QR' )
                U = [ median(RUNspec.Nobs) 1 ]*RUNspec.Bu;
            else
                U = RUNspec.u  ;
            end
        end
        
        r  = size( si, 1 );                 % Number sets
        RLmax = zeros( length(p), nVC);     % Initialize matrix
        RLmin = zeros( length(p), nVC);     % Initialize matrix 
        
        for i = 1 : nVC

            temp = zeros(r, length(p) );

            for j = 1 : r
                % Ref[1] page 81
                temp( j, : ) =  U(i) + si(j,i)/xi(j,i)*( pGP.^xi( j,i ) - 1 );
            end

            OUT.RLplot.RL95( :,i )  = quantile(temp, .95)';
            OUT.RLplot.RL05( :,i )  = quantile(temp, .05)';
            OUT.RLplot.RL50( :,i )  = quantile(temp, .50)';
            OUT.RLplot.RLm ( :,i )  = temp(idxMAX, :)';

            % For Shaded Area 
            RLmin( :,i ) = min(temp);
            RLmax( :,i ) = max(temp);

        end
        clear temp        
end
%--------------------------------------------------------------------------
%                           EMPIRICAL CDF                                 %
%--------------------------------------------------------------------------
switch RUNspec.DISTR.Type
    case 'GP'
        [fx, x] = ecdf(RUNspec.OBS);        % ECDF entire data
        Tx = ( 1./( 1 - fx ( 1 : end-1 ) ) )./ ( RUNspec.NobsY );    % Removed fx = 1;
        
    case 'GEV'
        [fx, x] = ecdf(OBS);
        Tx = 1./(1-fx(1:end-1));    % Removed fx = 1;
        
    case 'P3'
        [fx, x] = ecdf(exp(OBS));
        Tx = 1./(1-fx(1:end-1));    % Removed fx = 1;
end

x  = x( 1 :end-1 );
 
%--------------------------------------------------------------------------
%                           PLOT RETURN LEVEL                             %
%--------------------------------------------------------------------------
for f = 1 : nVC
    
    figure;
    hold on
    box on
%     % Shaded Grey area
%     mcmc = fill( [ log10(TT') log10(fliplr( TT')) ],  [ RLmax( :, f )' fliplr( RLmin( :, f )' ) ],...
%         [.9 .9 .9], 'EdgeColor', 'none', 'FaceAlpha', .5);

    if strcmp(RUNspec.DISTR.Type, 'P3')
        
        % MPE RL
        hRLmpe = plot( log10(TT), exp(OUT.RLplot.RLm( :, f )), '--', 'Color', [.3 .3 .3], 'LineWidth', 1.5 );

        % Median RL
        hRL50 = plot(  log10(TT), exp(OUT.RLplot.RL50( :, f )), '-', 'Color', [.8 0 0], 'LineWidth', 1.5 );

        % 90% CI
        hCI(1) = line(  log10(TT), exp(OUT.RLplot.RL05( :, f )) );
        hCI(2) = line(  log10(TT), exp(OUT.RLplot.RL95( :, f )) );
    else
        
        % MPE RL
        hRLmpe = plot( log10(TT), OUT.RLplot.RLm( :, f ), '--', 'Color', [.3 .3 .3], 'LineWidth', 1.5 );

        % Median RL
        hRL50 = plot(  log10(TT), OUT.RLplot.RL50( :, f ), '-', 'Color', [.8 0 0], 'LineWidth', 1.5 );

        % 90% CI
        hCI(1) = line(  log10(TT), OUT.RLplot.RL05( :, f ) );
        hCI(2) = line(  log10(TT), OUT.RLplot.RL95( :, f ) );
        
    end

    set( hCI, 'LineStyle', '-.', 'Color', [0 .5 0], 'LineWidth', 1.7)

    % Add labels
    if nVC == 1
        hTitle = title('Return Level: Stationary Case');
    else
        switch f
            case 1; hTitle = title('Return Level: Nonstationary Case 1');
            case 2; hTitle = title('Return Level: Nonstationary Case 2');
            case 3; hTitle = title('Return Level: Nonstationary Case 3');
        end
    end
    hXLabel = xlabel( 'Return Period' );
    hYLabel = ylabel( 'Return Level' );
    
    if f == 1

        % Empirical CDF
        try
            hObs = scatter( log10(Tx), x, 25, 'MarkerEdgeColor',[0 0 .8],'MarkerEdgeAlpha', .4,...
                      'MarkerFaceColor',[0 0 1], 'MarkerFaceAlpha', .4, 'LineWidth',1);
        catch
            hObs = scatter( log10(Tx), x, 25, 'MarkerEdgeColor',[0 0 .8],...
                'MarkerFaceColor',[0 0 1],'LineWidth',1);
        end
         % Add legend
%          hLegend = legend([hObs, hRLmpe, hRL50, hCI(1), mcmc], ...
%         'Data', 'MLE','Median', '90% CI', 'MCMC', ...
%         'Location', 'best');
         hLegend = legend([hObs, hRLmpe, hRL50, hCI(1)], ...
        'Data', 'MLE','Median', '90% CI',...
        'Location', 'best');
    else
%          hLegend = legend([hRLmpe, hRL50, hCI(1) mcmc], ...
%         'MLE','Median', '90% CI', 'MCMC',...
%         'Location', 'best');
        hLegend = legend([hRLmpe, hRL50, hCI(1)], ...
        'MLE','Median', '90% CI',...
        'Location', 'best');
    end

    % Adjust font
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14)
    set(hLegend, 'FontSize', 12, 'FontName', 'Helvetica', 'TextColor',[.3 .3 .3])
    set([hXLabel, hYLabel], 'FontSize', 14)
    set(hTitle, 'FontSize', 14, 'color',[.3 .3 .3], 'fontweight', 'normal')

    % Adjust axes properties
    set(gca, 'TickDir', 'in', 'TickLength', [.02 .02], ...
        'XMinorTick', 'on', 'YMinorTick', 'on',...
        'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'LineWidth', 1, ...
         'Xtick',  ( log10( [2 10 20 50 100 ])), 'Xticklabel', {'2' '10' '20' '50' '100'} );
     
     xlim([log10(TT(1)) log10( TT(end) ) ]);
     
%    xticks( log10( [2 10 20 50 100 ]) );
%    xticklabels( {'2' '10' '20' '50' '100'} );
end

end

%--------------------------------------------------------------------------
%                        EFFECTIVE RETURN LEVEL                           %
% REF[1]: Katz, R.W. Climatic Change (2010), "Statistics in Extremes in 
% Hydrology", 100: 71. https://doi.org/10.1007/s10584-010-9834-5
%--------------------------------------------------------------------------

function [ OUT ] = EFFECTIVE_ReturnLevel( OBS, OUT, RUNspec )

% OBS: observations
% OUT: parameter estimates
% RUNspec: info about the model
% RLplot: Info about the plot

%--------- Load Dimension of the problem and estimated parameters ---------

D   = RUNspec.Dim;                  % Problem Dimension
L   = RUNspec.Nobs;
CH  = OUT.CH( :, 1:D);              % Sets of Parameter
PST = OUT.CH( :, end);              % Log - Posterior 

%------------------- Find set of parameters w/ maximum Posterior ---------- 

% Location Maximum LogPosterior
[ idxMAX, ~ ] = find( PST == max( PST ), 1, 'last');    

%------------------------------ Covariates ------------------------------- 

covX = RUNspec.COV.X;           % Covariate
% covX = 1:100;                   % Covariate
NX   = length(covX);            % Length Covariates

%----------------------- Vector of Return Periods ------------------------- 

TT = [2 10 25 50 100]';             % Vector of RP including value of ~1    
p  = 1 - 1./TT;                     % Probability associated w/ R

% ------------------------------- Extract Parameters ----------------------
switch RUNspec.DISTR.Type
    
    %----------------------------- GEV and P3 ----------------------------- 
    case { 'GEV', 'P3' }       
        % Define vectors mu, si, xi ------------------
        switch RUNspec.DISTR.Model
            
            case 'Stat'  
                
                mu = repmat( CH( idxMAX, 3), NX, 1 ) ;
                si = repmat( exp( CH( idxMAX, 2) ), NX, 1 ) ;
                xi = repmat( CH( idxMAX, 1), NX, 1 ) ;
            
            case 'NonStat'
                
                idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;     % First Column containing MU's Coefficients
                idxS = RUNspec.NS.CoeffXI;                          % First Column containing SI's Coefficients
                                
                %------------------ MU - Location / Mean ------------------
                switch RUNspec.NS.MU

                    case 'none'
                        mu  = repmat( CH( idxMAX, idxM + 1 ), NX, 1 ) ;
                    case 'Linear'
                        mu  = repmat( CH( idxMAX, idxM + 1 ), NX, 1 ) + CH( idxMAX, idxM + 2 )*covX ;
                    case 'Quadratic'
                        mu  = CH( idxMAX, idxM + 3 )*covX.^2 + CH( idxMAX, idxM + 2 )*covX + repmat( CH( idxMAX, idxM + 1 ), NX, 1 );
                    case 'Exponential'
                        mu  = CH( idxMAX, idxM + 1 ).*exp( CH( idxMAX, idxM + 2 )*covX );
                end

                %------------------ SI - Scale / Std ----------------------        
                switch RUNspec.NS.SI 
                    case 'none'
                        si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX,1 )  );
                    case 'Linear'
                        si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX,1 ) + CH( idxMAX, idxS + 2 )*covX );
                    case 'Quadratic'
                        si  = exp( CH( idxMAX, idxS + 3 )*covX.^2 + CH( idxMAX, idxS + 2 )*covX + repmat( CH( idxMAX, idxS + 1 ), NX,1 ) );
                end

                %------------------ XI - Shape / Skewness -----------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi  = repmat( CH( idxMAX, 1 ), NX,1 );
                    case 'Linear'
                        xi  = repmat( CH( idxMAX, 1 ), NX,1 ) + CH( idxMAX, 2 )*covX ;
                end
        end
        % Define CDFinv function based on the distribution type
        if strcmp( RUNspec.DISTR.Type, 'GEV' )
            QTLfunc = @( p, xi, si, mu) gevinv( p, xi, si, mu );
        else
            QTLfunc = @( p, xi, si, mu) P3inv( p, xi, si, mu );
        end
        
        % Return Level as a function of the covariate
        Xp = zeros( length(p), NX );
        
        for i = 1 : length(p)            
            for j = 1 : NX                
                Xp(i,j) =  QTLfunc( p( i ), xi( j ), si( j ), mu( j ) );
            end
        end
        
        if strcmp( RUNspec.DISTR.Type, 'P3' ) % Transform back in case of P3
            Xp = exp(Xp);
        end
        
    %----------------------- Generalized Pareto ---------------------------    
    case 'GP'        
        %------------------- Define vectors  si, xi -----------------------
        switch RUNspec.DISTR.Model
            
            case 'Stat'
                si = repmat( exp( CH( idxMAX, 2) ), NX, 1 ) ;
                xi = repmat( CH( idxMAX, 1), NX, 1 ) ;
            
            case 'NonStat'
                
                idxS = RUNspec.NS.CoeffXI;      % First Column containing SI's Coefficients
                
                %------------------------------ SI ------------------------                     
                switch RUNspec.NS.SI 
                    case 'none'
                        si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) );
                    case 'Linear'
                        si  = exp( repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) + CH( idxMAX, idxS + 2)*covX );
                    case 'Quadratic'
                        si  = exp( CH( idxMAX, idxS + 3 )*covX.^2 + CH( idxMAX, idxS + 2 )*covX + repmat( CH( idxMAX, idxS + 1 ), NX, 1 ) );
                end

                %--------------------------- XI ---------------------------       
                switch RUNspec.NS.XI
                    case 'none'
                        xi  = repmat( CH( idxMAX, 1 ), NX, 1 );
                    case 'Linear'
                        xi  = repmat( CH( idxMAX, 1 ), NX, 1 ) + CH( idxMAX, 2 )*covX ;
                end
        end
        % RUNspec.NobsY: number of observations in one year: RUNspec.NobsY
        % RUNspec.Fu:= RUNspec.Nex/RUNspec.Nobs Probability of exceess 

        pGP = TT.*RUNspec.NobsY*RUNspec.Fu;
        
        if strcmp( RUNspec.DISTR.Model, 'NonStat' )
            if strcmp( RUNspec.THtype, 'QR' )
                U = [ covX ones( NX, 1 ) ]*RUNspec.Bu;
            else
                U = RUNspec.u.*ones( NX, 1 );              
            end

        else
            if strcmp( RUNspec.THtype, 'QR' )
                U = ([ median(RUNspec.Nx) 1 ]*RUNspec.Bu)*ones( NX, 1 );
            else
                U = RUNspec.u.*ones( NX, 1 );
                
            end
        end
        % Return Level as a function of the covariate
        Xp = zeros( length(TT), NX );
        
        for i = 1 : length(TT)            
            for j = 1:NX                
                Xp( i,j ) =  U( j ) + si( j )/xi( j )*( pGP(i).^xi( j ) - 1 );
            end
        end        
      
end

OUT.ERP.TT = TT;     % Save return Periods
OUT.RLeff  = Xp;     % Save Effective Return Level    

%--------------------------------------------------------------------------
%                               FIGURE                                    %
%--------------------------------------------------------------------------
figure;
hold on
box on

% Plot Observations
if strcmp(RUNspec.DISTR.Type, 'P3')
    hOBS = scatter( covX, exp(OBS)', 50, 'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceAlpha', .4,...
                      'MarkerFaceColor',[.3 .3 .3], 'MarkerFaceAlpha', .3, 'LineWidth',1);
else
    hOBS = scatter( covX, OBS', 50, 'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceAlpha', .4,...
                      'MarkerFaceColor',[.3 .3 .3], 'MarkerFaceAlpha', .3, 'LineWidth',1);
end

CLR = [ 153  153  102;... 
        255  204    0;...
          0  153  153;...
        153  204   51;...
        255  153    0];

CLR  = CLR/255; 

for j = 1:size( Xp, 1 )

    hEFF( j ) = line( covX, Xp( j, : ) );
    set( hEFF( j ), 'LineStyle', '-', 'Color', CLR( j, : ), 'LineWidth', 2);
end

% Add legend
hL = legend([hOBS, hEFF(1), hEFF(2), hEFF(3), hEFF(4),hEFF(5)],...
                 'Data', 'T = 2 yr', 'T = 10 yr', 'T = 25 yr', 'T = 50 yr', 'T = 100 yr',...
                 'Location', 'best');

% Label
hX = xlabel('Covariate');
hY = ylabel('Return Level');
hT = title('Effective Return Level');

% Adjust font
set( gca, 'FontName', 'Helvetica', 'FontSize', 14)
set( hL, 'FontSize', 12, 'FontName', 'Helvetica', 'TextColor',[.3 .3 .3])
set( [hX, hY], 'FontSize', 14);
set( hT, 'FontSize', 14, 'color',[.3 .3 .3], 'fontweight', 'normal');

% Adjust axes properties
set(gca, 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3],...
     'LineWidth', 1);
%xlim( [ min(covX) max(covX) ]);
end
%--------------------------------------------------------------------------
%                           QUANTILE P3                                   %
%--------------------------------------------------------------------------
% References
% [1] Kirby, William. "Computer oriented Wilson Hilferty transformation that preserves the first three moments and the lower bound of the Pearson type 3 distribution." 
% Water Resources Research 8.5 (1972): 1251-1254
% [2] Reis, Dirceu S., and Jery R. Stedinger. "Bayesian MCMC flood frequency analysis with historical information." Journal of hydrology 313.1 (2005): 97-116.
% [3] Luke, Adam, et al. "Predicting nonstationary flood frequencies: Evidence supports an updated stationarity thesis in the United States." Water Resources Research 53.7 (2017): 5469-5494.

function [ Xp ] = P3inv(p, gammaX, sigmaX, muX)

% gammaX : skewness
% sigmaX : standard deviation
% muX    : mean
% p      : probability of occurrance

np = norminv(p);           % Associated N(0,1) quantile 

% Xp QUANTILE - Xp = log(Q) --> Xp  = mu + sigma * Kp( gamma )
% 
% Kp: Frenquncy Factor based on Wilson – Hilferty transformation 
% Kp  = 2/gamma( 1 + gamma*np/6 - gamma^2/36 )^3 - 2/gamma [1], [2], [3]
% For |gamma| < 2 ( Ref [2] ) and np normal inverse
Kp = @(gammaX, np) 2/gammaX * ( 1 + gammaX.*np/6 - gammaX^2/36 ).^3 - 2/gammaX;

% Theoretical Quantile
Xp  = muX + sigmaX .* Kp( gammaX, np );

end

%-------------------------------------------------------------------------%
%                        PDF - PEARSON TYPE III                           %
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


%-------------------------------------------------------------------------%
%                         CDF PEARSON TYPE III                            %
%-------------------------------------------------------------------------%
% Numerical integration of the PDF  to avoid gamma function going
% to infinity for gamma very small

function [ CDF ] = P3cdf( X0, gammaX, sigmaX, muX, X )

dx = mean( (X(2:end) - X(1:end-1)) )/100;           % Average distance btw points
x  =  .2*min(X) : dx : 1.2*X(end);                  % Vector to evaluate PDF

PDF           = P3pdf( x, gammaX, sigmaX, muX );	% Calculate PDF
[sortX, idxX] = sort(x);                            % Sort Observation
sortPDF       = PDF(idxX);                          % Sort PDF

Apdf = trapz(sortX, sortPDF);                       % Area under the curve

for i = 1:length(X0)
    idxX0 = find( sortX <= X0(i), 1, 'last');                              % Find the correpsonding X0

    CDF(i,1) = trapz(sortX(1:idxX0), sortPDF(1:idxX0))/Apdf;               % CDF
end

end