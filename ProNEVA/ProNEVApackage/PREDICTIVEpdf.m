%-------------------------------------------------------------------------
%                                   PREDICTIVE PDF
%-------------------------------------------------------------------------
% REF[1]Renard B., Sun X., Lang M. (2013) Bayesian Methods for Non-stationary 
% Extreme Value Analysis. In: Extremes in a Changing Climate. 
% Water Science and Technology Library, vol 65. Springer, Dordrecht
%-------------------------------------------------------------------------

function [PDFhat, Zhat] = PREDICTIVEpdf(OBS, OUT, RUNspec)

RLplot = OUT.RLplot;

D    = RUNspec.Dim;                  % Problem Dimension
L    = length(OBS);                  % Number of observations
CH   = OUT.CH( :, 1:D, :);              % Sets of Parameter
Nsim = length(CH);                   % Number of Simulations after burn in
LK   = OUT.CH( :, end - 1);          % Log - likelihood
PST  = OUT.CH( :, end);              % Log - Posterior

% Predictive Probability Density

nCurves = size(OUT.PARvc,3);                             % Number of scenarios
Zhat    = linspace(0.9*min(OBS), 1.2*max(OBS), 100)';    % create a grid of data
Lz      = length(Zhat);                                  % Length of grid data
PDFhat  = zeros(Lz,nCurves);                             % inizialize vector PDF

for i = 1:nCurves
    par = OUT.PARvc(:,:,i);
    gk  = zeros(Nsim,1);                                 % inizialize vector temp
    % Define pdf distribution
    switch RUNspec.DISTR.Type
        case 'GEV'
            FUNpdf = @(x,par) gevpdf( x, par(1), par(2), par(3) );
        case 'P3'
            FUNpdf = @(x,par) P3pdf( x, par(1), par(2), par(3) );
        case 'GP'
            FUNpdf = @(x,par) gppdf( x, par(1), par(2) );
    end

    % [REF1]: P(Z_k|OBS) = 1/Nsim ( mean ( g(zk|thata_i) ) ) 

    for k = 1 : Lz
        for s = 1 : Nsim
            gk(s,1) = FUNpdf(Zhat(k),par(s,:));
        end
        PDFhat(k,i) = mean(gk);
    end
end    

%--------------------------------------------------------------------------
%                               PLOT PDF
%--------------------------------------------------------------------------

COLpdfs = [ 88,140,126; ...
          255 204 92; ...
          255,111,105]/255;
figure;
%subplot(5,2, [4,6,8])
%subplot(5,4, [6 7 10 11 14 15])
hold on
box on;

% Plot Histogram of Observations
%HS    = histogram(OBS, 'Normalization','probability');

if strcmp(RUNspec.DISTR.Type, 'P3')
    [N, edge] = histcounts(exp(OBS));
    Zhat  = exp(Zhat);
    dzhat = Zhat(2:end) - Zhat(1:end-1);
    
    A      = PDFhat(2:end,:)'*dzhat;
    PDFhat = PDFhat./A';
else
    [N, edge] = histcounts(OBS);
end

A = trapz(edge(1:end-1),N);

HS = bar(edge(2:end),N/A, 'BarWidth', 1);

set(HS, 'FaceColor', [.5 .5 .5], 'FaceAlpha', .3, 'EdgeColor', [.5 .5 .5] );

% Plot PDF Curves
for j = 1 : nCurves
    hCI = line(Zhat, PDFhat(:,j));
    set( hCI, 'LineStyle', '-', 'Color', COLpdfs(j,:), 'LineWidth', 1.7);
end
% Labels
if strcmp(RUNspec.DISTR.Type, 'GP')
    hXLabel = xlabel( 'Obs. Excesses' );
else
    hXLabel = xlabel( 'Observations' );
end
hYLabel = ylabel( 'PDF' );
% Title
hTitle = title('Predictive Distribution');

% Adjust font
set(gca, 'FontName', 'Helvetica', 'FontSize',12)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'color',[.3 .3 .3], 'fontweight', 'normal')

% Adjust axes properties
set(gca, 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3],...
     'LineWidth', 1);
 
switch nCurves
    case 1
        hLegend = legend('OBS', 'PDF');
    case 2
        hLegend = legend('OBS', ['COV = ', num2str(RLplot.VC(1))], ...
                                ['COV = ', num2str( round( RLplot.VC(2)*10)/10)]);
    case 3
        hLegend = legend('OBS', ['COV = ', num2str(RLplot.VC(1))], ...
                                ['COV = ', num2str(RLplot.VC(2))], ...
                                ['COV = ', num2str(RLplot.VC(3))]);
    
end
 set(hLegend, 'FontSize', 10, 'FontName', 'Helvetica', 'TextColor',[.3 .3 .3], ...
     'location', 'best','EdgeColor', [.3 .3 .3], 'linewidth', 1);
end

%-------------------------------------------------------------------------%
%                         LOG PEARSON TYPE III                            %
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
        

