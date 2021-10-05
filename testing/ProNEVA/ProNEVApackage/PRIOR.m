%--------------------------------------------------------------------------
% PRIOR DISTRIBUTION 
%--------------------------------------------------------------------------

function [PR] = PRIOR( RUNspec, Z)

% RUNspec:  Info about distributions
% Z: one set of parameters - number of columns depend on the type of analysis 

switch RUNspec.DISTR.Type
%--------------------------------------------------------------------------    
%   CASE GEV distribution - xi, si, mu   
%   CASE PEARSON TYPE III distribution - mean, std, skweness  
%--------------------------------------------------------------------------    
    case { 'GEV', 'P3' }
        % Position of the parameters
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
            % Position of each coefficient
            idxM = RUNspec.NS.CoeffXI + RUNspec.NS.CoeffSI;  
            idxS = RUNspec.NS.CoeffXI;    
            % Prior of the non stationary coefficients
            prm1  = RUNspec.PRIOR.COEFFparm2;
            prm2  = RUNspec.PRIOR.COEFFparm2;
          
        else
            idxM = 2;
            idxS = 1;
        end
        
        % LOCATION (MU)
        mu1 = RUNspec.PRIOR.MUparm1;
        mu2 = RUNspec.PRIOR.MUparm2;
        mu  = Z(1, idxM + 1);

        switch RUNspec.PRIOR.MUdistr
            case 'Normal';  pMU = normpdf(mu, mu1, mu2);
            case 'Uniform'; pMU = unifpdf(mu, mu1, mu2);
            case 'Gamma';   pMU = gampdf( mu, mu1, mu2);
        end
        % Prior of non stationary coefficients
        pMUns = []; 
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
        switch RUNspec.NS.MU                                    
            case 'Linear'
                pMUns = normpdf( Z(1,idxM + 2), prm1, prm2) ;
            case 'Quadratic'
                pMUns(1) = normpdf( Z(1,idxM + 2), prm1, prm2);
                pMUns(2) = normpdf( Z(1,idxM + 3), prm1, prm2/10);
            case 'Exponential'
                pMUns = normpdf( Z(1,idxM + 2), prm1, prm2);
        end
        end

        % SCALE (SI)
        si1 = RUNspec.PRIOR.SIparm1;
        si2 = RUNspec.PRIOR.SIparm2;
        si  = Z(1, idxS + 1);

        switch RUNspec.PRIOR.SIdistr    
            case 'Normal';  pSI = normpdf(si, si1, si2);
            case 'Uniform'; pSI = unifpdf(si, si1, si2);
            case 'Gamma';   pSI = gampdf( si, si1, si2);
        end
        
        % Prior of non stationary coefficients
        pSIns = []; 
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
        switch RUNspec.NS.SI                                    
            case 'Linear'
                pSIns = normpdf( Z(1,idxS + 2), prm1, prm2) ;
            case 'Quadratic'
                pSIns(1) = normpdf( Z(1,idxS + 2) , prm1, prm2);
                pSIns(2) = normpdf( Z(1,idxS + 3) , prm1, prm2/10);
        end
        end

        % SHAPE (XI)
        xi1 = RUNspec.PRIOR.XIparm1;
        xi2 = RUNspec.PRIOR.XIparm2; 
        xi  = Z(1, 1);

        switch RUNspec.PRIOR.XIdistr    
            case 'Normal';  pXI = normpdf(xi, xi1, xi2);
            case 'Uniform'; pXI = unifpdf(xi, xi1, xi2);
            case 'Gamma';   pXI = gampdf( xi, xi1, xi2);
        end
        % Prior of non stationary coefficients
        pXIns = []; 
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
        switch RUNspec.NS.XI                                    
            case 'Linear'
                pXIns = normpdf( Z( 1, 2 ), prm1, prm2/10) ;
        end
        end
        
        PR = [ pXI pXIns pSI pSIns pMU pMUns ];
         
%--------------------------------------------------------------------------    
%   CASE GP distribution - xi, si    
%--------------------------------------------------------------------------        
    case 'GP'
        % Position of the parameters
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
            % Position of each coefficient
            idxS = RUNspec.NS.CoeffXI;    
            % Prior of the non stationary coefficients
            prm1  = RUNspec.PRIOR.COEFFparm2;
            prm2  = RUNspec.PRIOR.COEFFparm2;
          
        else
            idxS = 1;
        end
        % SCALE (SI)
        si1 = RUNspec.PRIOR.SIparm1;
        si2 = RUNspec.PRIOR.SIparm2;
        si  = Z(1, idxS + 1);

        switch RUNspec.PRIOR.SIdistr    
            case 'Normal';  pSI = normpdf(si, si1, si2);
            case 'Uniform'; pSI = unifpdf(si, si1, si2);
            case 'Gamma';   pSI = gampdf( si, si1, si2);
        end
        
        % Prior of non stationary coefficients
        pSIns = []; 
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
        switch RUNspec.NS.SI                                    
            case 'Linear'
                pSIns = normpdf( Z(1,idxS + 2), prm1, prm2) ;
            case 'Quadratic'
                pSIns(1) = normpdf( Z(1,idxS + 2) , prm1, prm2);
                pSIns(2) = normpdf( Z(1,idxS + 3) , prm1, prm2/10);
        end
        
        end
        % SHAPE (XI)
        xi1 = RUNspec.PRIOR.XIparm1;
        xi2 = RUNspec.PRIOR.XIparm2; 
        xi  = Z(1, 1);

        switch RUNspec.PRIOR.XIdistr    
            case 'Normal';  pXI = normpdf(xi, xi1, xi2);
            case 'Uniform'; pXI = unifpdf(xi, xi1, xi2);
            case 'Gamma';   pXI = gampdf( xi, xi1, xi2);
        end
        
        % Prior of non stationary coefficients
        pXIns = []; 
        if strcmp(RUNspec.DISTR.Model, 'NonStat')
        switch RUNspec.NS.XI                                    
            case 'Linear'
                pXIns = normpdf( Z( 1, 2 ), prm1, prm2/10) ;
        end
        end
        
        PR = [ pXI pXIns pSI pSIns ];
        
end
     
