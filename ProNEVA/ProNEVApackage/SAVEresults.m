% -------------------------------------------------------------------------
% SAVE RESULTS
% -------------------------------------------------------------------------

function SAVEresults(OBS, RUNspec, OUT, DGN, currentDIR)

%currentDIR = pwd;
cd(currentDIR)

if exist('Results','file') == 0
    % Create a Results folder
    if ispc
        mkdir([currentDIR,'\Results']); % for PC
    else
        mkdir([currentDIR,'/Results']); % for MAC
    end     
end

cd Results

switch RUNspec.DISTR.Model
    
    case 'Stat'
        % Create a StationaryAnalysis folder if it does not exist
        if exist('StationaryAnalysis','file') == 0    
            if ispc
                mkdir([pwd,'\StationaryAnalysis']); % for PC
            else
                mkdir([pwd,'/StationaryAnalysis']); % for MAC
            end      
        end
        % Open folder
        cd StationaryAnalysis
        % Save Workspace 
        save( 'StatAnalysisResults.mat', 'OBS', 'RUNspec', 'OUT', 'DGN');
        % Save Figures
        ListFigure = findobj('type', 'Figure');
        savefig(ListFigure, 'Figures.fig');
        
    case 'NonStat'
        % Create a NonStationaryAnalysis folder if it does not exist
        if exist('NonStationaryAnalysis','file') == 0
            if ispc
                mkdir([pwd,'\NonStationaryAnalysis']); % for PC
            else
                mkdir([pwd,'/NonStationaryAnalysis']); % for MAC
            end  
        end
        % Open Folder
        cd NonStationaryAnalysis
        % Save Workspace
        save( 'NonStatAnalysisResults.mat', 'OBS', 'RUNspec', 'OUT', 'DGN');
        % Save Figures
        ListFigure = findobj('type', 'Figure');
        savefig(ListFigure, 'Figures.fig');

end
% BACK TO ORIGINAL DIRECTORY
cd(currentDIR)